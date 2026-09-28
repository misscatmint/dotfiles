; Bodies that indent their contents
[
  (block)
  (enum_entries)
  (enum_struct)
  (struct)
  (struct_constructor)
  (methodmap)
  (methodmap_property)
  (typeset)
  (funcenum)
  (switch_statement)
  (array_literal)
] @indent.begin

; Closing braces/parens line up with the line that opened them
[
  "}"
  ")"
] @indent.branch

; Allman-style opening braces on their own line for declarations
; (not for (block), whose "{" starts the node itself)
(enum_struct "{" @indent.branch)
(struct "{" @indent.branch)
(methodmap "{" @indent.branch)
(methodmap_property "{" @indent.branch)
(typeset "{" @indent.branch)
(funcenum "{" @indent.branch)
(switch_statement "{" @indent.branch)

(block "}" @indent.end)

; Statements continued over several lines
(expression_statement
  (_) @indent.begin
  ";" @indent.end)

(return_statement
  (_) @indent.begin
  ";" @indent.end)

(variable_declaration_statement
  (_) @indent.begin
  ";" @indent.end)

; Unbraced loop bodies
((for_statement
  body: (_) @_body) @indent.begin
  (#not-kind-eq? @_body "block"))

((while_statement
  body: (_) @_body) @indent.begin
  (#not-kind-eq? @_body "block"))

((do_while_statement
  body: (_) @_body) @indent.begin
  (#not-kind-eq? @_body "block"))

(do_while_statement "while" @indent.branch)

; Unbraced case bodies (a braced one indents through its block)
((switch_case
  body: (_) @_body) @indent.begin
  (#not-kind-eq? @_body "block"))

; if / else
(condition_statement
  condition: (_) @indent.begin)

((condition_statement
  truePath: (_) @_true) @indent.begin
  (#not-kind-eq? @_true "block"))

(condition_statement "else" @indent.branch)

; `else if` / `else {` after an unbraced if: don't stack another level
((condition_statement
  truePath: (_) @_true
  falsePath: [
    (condition_statement)
    (block)
  ] @indent.dedent)
  (#not-kind-eq? @_true "block"))

; Unbraced else after a braced if
((condition_statement
  truePath: (block)
  falsePath: (_) @_false) @indent.begin
  (#not-kind-eq? @_false "block")
  (#not-kind-eq? @_false "condition_statement"))

; Argument lists, parameter lists and parenthesized expressions
; align with the opening paren
([
  (call_arguments)
  (parameter_declarations)
  (parenthesized_expression)
] @indent.align
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")"))

; Preprocessor directives always start in column 0
[
  (preproc_include)
  (preproc_tryinclude)
  (preproc_define)
  (preproc_macro)
  (preproc_undefine)
  (preproc_if)
  (preproc_elseif)
  (preproc_else)
  (preproc_endif)
  (preproc_endinput)
  (preproc_pragma)
  (preproc_error)
  (preproc_warning)
  (preproc_assert)
] @indent.zero

[
  (preproc_arg)
  (string_literal)
] @indent.ignore

(comment) @indent.auto
