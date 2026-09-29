-- Chains inside parentheses align on the dot, which nvim-treesitter's
-- delimiter-based @indent.align can't express: it can only align to a
-- delimiter that is a direct child of a node on the cursor's ancestor path.
local LINKS = { attribute = true, call = true, subscript = true }

local function dot_col(attr)
  for child in attr:iter_children() do
    if child:type() == '.' then
      return select(2, child:start())
    end
  end
end

-- Column of the last dot in a chain link: "foo.bar", "foo.bar(1)",
-- "foo.bar[0]" all give the dot before "bar".
local function last_dot(node)
  while node do
    local ntype = node:type()
    if ntype == 'attribute' then
      return dot_col(node)
    elseif ntype == 'call' then
      node = node:field('function')[1]
    elseif ntype == 'subscript' then
      node = node:field('value')[1]
    else
      return nil
    end
  end
end

local function same_start(a, b)
  local ar, ac = a:start()
  local br, bc = b:start()
  return ar == br and ac == bc
end

-- Only chains that start right after an open "(" get dot alignment, so a
-- link inside a larger expression keeps the normal delimiter alignment.
-- Walking up only through nodes the link starts (or an "await") keeps a
-- call inside a subscript's brackets from counting as the chain.
local function opens_paren(node)
  local parent = node:parent()
  while parent and ((LINKS[parent:type()] and same_start(parent, node))
      or parent:type() == 'await') do
    node, parent = parent, parent:parent()
  end
  if not parent then
    return false
  end
  local prev = node:prev_sibling()
  -- Mid-edit, "await" can end up as a bare token beside the call.
  if prev and prev:type() == 'await' then
    prev = prev:prev_sibling()
  end
  local ptype = parent:type()
  return prev ~= nil and prev:type() == '('
    and (ptype == 'parenthesized_expression' or ptype == 'ERROR')
end

-- Column of the last dot in the chain link that ends the previous line, when
-- that link is part of a parenthesized chain, else nil. The previous line is
-- used because the line being indented is still only "." and doesn't parse
-- yet.
local function chain_indent(lnum)
  local prev = vim.fn.prevnonblank(lnum - 1)
  if prev == 0 then
    return nil
  end
  local text = vim.fn.getline(prev):gsub('%s+$', '')
  local node = vim.treesitter.get_node({ pos = { prev - 1, #text - 1 } })
  if node and node:type() == 'comment' then
    text = text:sub(1, select(2, node:start())):gsub('%s+$', '')
    node = #text > 0 and vim.treesitter.get_node({ pos = { prev - 1, #text - 1 } }) or nil
  end
  if not node then
    return nil
  end
  -- Widen from the last token to the link it ends: ")" to its call, "bar" to
  -- "foo.bar". A parent ending elsewhere means the line doesn't end a link.
  local erow, ecol = node:end_()
  while not LINKS[node:type()] do
    node = node:parent()
    if not node then
      return nil
    end
    local row, col = node:end_()
    if row ~= erow or col ~= ecol then
      return nil
    end
  end
  return opens_paren(node) and last_dot(node) or nil
end

-- Statements each keyword can continue, as fixed by Python's grammar.
local CONTINUES = {
  case = { case_clause = true },
  elif = { if_statement = true },
  ['else'] = { if_statement = true, for_statement = true,
               while_statement = true, try_statement = true },
  except = { try_statement = true },
  finally = { try_statement = true },
}

-- Column of the statement a half-typed continuation keyword belongs to, else
-- nil. Until the line parses as a clause, the tree puts it inside the
-- previous block's body, and @indent.branch can only dedent one level from
-- there. The previous line parses cleanly, so its ancestors give the
-- statement; the nearest one wins, as in "for ... else" inside an "if".
local function continuation_indent(lnum, line)
  local targets = CONTINUES[line:match('^%s*([%w_]+)')]
  local prev = vim.fn.prevnonblank(lnum - 1)
  -- Only a finished header: "else d)" can continue a conditional expression.
  -- Before the colon, nvim-treesitter's one-level dedent stands in, and
  -- typing ":" reindents again.
  if not targets or not line:gsub('%s*#.*$', ''):find(':$') or prev == 0 then
    return nil
  end
  -- Only a keyword the parser couldn't place yet: a line that parses has
  -- its statement in the tree already (an "else" after a nested "if"), or
  -- isn't a clause at all ("case = 1", "else c)" in a conditional).
  local own = vim.treesitter.get_node({ pos = { lnum - 1, #line:match('^%s*') } })
  local parent = own and own:parent()
  if not own or (own:type() ~= 'ERROR' and not (parent and parent:type() == 'ERROR')) then
    return nil
  end
  local node = vim.treesitter.get_node({ pos = { prev - 1, vim.fn.indent(prev) } })
  while node do
    if targets[node:type()] then
      return select(2, node:start())
    end
    node = node:parent()
  end
end

-- Whether line l ends with a backslash continuation (not one inside a string
-- or comment).
local function continued(l)
  local text = vim.fn.getline(l):gsub('%s+$', '')
  if l < 1 or text:sub(-1) ~= '\\' then
    return false
  end
  local node = vim.treesitter.get_node({ pos = { l - 1, #text - 1 } })
  return node ~= nil and node:type() == 'line_continuation'
end

-- Indent after a "\": one shiftwidth past the statement's first line, then
-- level with the previous continuation line. While typing, the "\" parses as
-- a node outside the statement (and outside any enclosing function), so the
-- query can't place the next line.
local function backslash_indent(lnum)
  if not continued(lnum - 1) then
    return nil
  end
  if continued(lnum - 2) then
    return vim.fn.indent(lnum - 1)
  end
  return vim.fn.indent(lnum - 1) + vim.fn.shiftwidth()
end

local CLOSERS = { [')'] = true, [']'] = true, ['}'] = true }

-- Indent inside the innermost bracket still open before this line, when the
-- previous line ends inside an ERROR node, else nil. For an ERROR,
-- nvim-treesitter aligns to its first bracket, which is wrong once another
-- opens inside it: "(await foo(a," puts the next line under "await".
local function bracket_indent(lnum, line)
  local prev = vim.fn.prevnonblank(lnum - 1)
  if prev == 0 then
    return nil
  end
  local text = vim.fn.getline(prev):gsub('%s+$', '')
  local err = vim.treesitter.get_node({ pos = { prev - 1, #text - 1 } })
  while err and err:type() ~= 'ERROR' do
    err = err:parent()
  end
  if not err then
    return nil
  end
  -- Match bracket tokens up to the end of the previous line; brackets in
  -- strings and comments aren't tokens, so they can't unbalance this.
  local open = {}
  local function scan(node)
    for child in node:iter_children() do
      if child:start() > prev - 1 then
        return false
      end
      local ctype = child:type()
      if child:child_count() > 0 then
        if scan(child) == false then
          return false
        end
      elseif ctype == '(' or ctype == '[' or ctype == '{' then
        table.insert(open, child)
      elseif CLOSERS[ctype] then
        table.remove(open)
      end
    end
  end
  scan(err)
  local bracket = open[#open]
  if not bracket then
    return nil
  end
  local row, col = bracket:start()
  local rest = vim.fn.getline(row + 1):sub(col + 2)
  if rest:find('^%s*$') or rest:find('^%s*#') then
    -- Hanging: the closer goes back to the opening line's indent.
    local base = vim.fn.indent(row + 1)
    return CLOSERS[line:match('^%s*(.)')] and base or base + vim.fn.shiftwidth()
  end
  return col + 1
end

--- indentexpr for Python: aligns a line starting with "." on the previous
--- call's dot, lines up continuation keywords (else, except, case, ...) with
--- their statement, indents backslash continuations and lines inside
--- half-typed brackets, and otherwise defers to nvim-treesitter.
function _G.python_indentexpr()
  local parser = vim.treesitter.get_parser()
  if not parser then
    return -1
  end
  -- get_node doesn't parse, and highlighting only parses asynchronously.
  parser:parse()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)
  local col = line:find('^%s*%.') and chain_indent(lnum)
    or continuation_indent(lnum, line) or backslash_indent(lnum)
    or bracket_indent(lnum, line)
  if col then
    return col
  end

  local indent = require('nvim-treesitter').indentexpr()
  -- Mid-edit, nvim-treesitter can align a line to a bracket on that same
  -- line: when an ERROR node starting on an earlier line holds the bracket
  -- as a direct child, the engine aligns to it without checking its row.
  -- Keep the current indent instead. A bracket that merely sits at that
  -- column (as in "isinstance(" under a "[") belongs to a parsed node.
  if indent > 0 then
    local bracket = vim.treesitter.get_node({
      pos = { lnum - 1, indent - 1 }, include_anonymous = true })
    local parent = bracket and bracket:parent()
    if parent and parent:type() == 'ERROR' and parent:start() < lnum - 1
        and bracket:type():find('^[%(%[{]$')
        and select(2, bracket:start()) == indent - 1 then
      return -1
    end
  end
  return indent
end

vim.bo.indentexpr = 'v:lua.python_indentexpr()'
-- Reindent when "." is typed as the first character of a line.
vim.opt_local.indentkeys:append('0.')
