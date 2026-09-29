; Backslash continuations are indented by after/indent/python.lua: while
; typing, the "\" parses as a node outside the statement (and outside any
; enclosing function), so no capture here can place the next line.

([(list) (list_comprehension) (list_pattern) (subscript) (type_parameter)] @indent.align
  (#set! indent.open_delimiter "[")
  (#set! indent.close_delimiter "]"))

([(dictionary) (dictionary_comprehension) (dict_pattern)] @indent.align
  (#set! indent.open_delimiter "{")
  (#set! indent.close_delimiter "}"))

([(set) (set_comprehension)] @indent.align
  (#set! indent.open_delimiter "{")
  (#set! indent.close_delimiter "}"))

([(parenthesized_expression) (generator_expression) (tuple_pattern) (class_pattern)
  (with_clause) (import_from_statement)] @indent.align
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")"))

((for_statement) @indent.begin
  (#set! indent.immediate 1))

((if_statement) @indent.begin
  (#set! indent.immediate 1))

((while_statement) @indent.begin
  (#set! indent.immediate 1))

((try_statement) @indent.begin
  (#set! indent.immediate 1))

(ERROR
  "try"
  .
  ":"
  (#set! indent.immediate 1)) @indent.begin

(ERROR
  "try"
  .
  ":"
  (ERROR
    (block
      (expression_statement
        (identifier) @_except) @indent.branch))
  (#eq? @_except "except"))

((function_definition) @indent.begin
  (#set! indent.immediate 1))

((class_definition) @indent.begin
  (#set! indent.immediate 1))

((with_statement) @indent.begin
  (#set! indent.immediate 1))

((match_statement) @indent.begin
  (#set! indent.immediate 1))

((case_clause) @indent.begin
  (#set! indent.immediate 1))

; if (cond1
;     or cond2
;         or cond3):
;     pass
;
(if_statement
  condition: (parenthesized_expression) @indent.align
  (#lua-match? @indent.align "^%([^\n]")
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")")
  (#set! indent.avoid_last_matching_next 1))

; while (
;     cond1
;     or cond2
;         or cond3):
;     pass
;
(while_statement
  condition: (parenthesized_expression) @indent.align
  (#lua-match? @indent.align "[^\n ]%)$")
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")")
  (#set! indent.avoid_last_matching_next 1))

; if (
;     cond1
;     or cond2
;         or cond3):
;     pass
;
(if_statement
  condition: (parenthesized_expression) @indent.align
  (#lua-match? @indent.align "[^\n ]%)$")
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")")
  (#set! indent.avoid_last_matching_next 1))

(ERROR
  "(" @indent.align
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")")
  .
  (_))

((argument_list) @indent.align
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")"))

((parameters) @indent.align
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")"))

((parameters) @indent.align
  (#lua-match? @indent.align "[^\n ]%)$")
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")")
  (#set! indent.avoid_last_matching_next 1))

((tuple) @indent.align
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")"))

(ERROR
  "[" @indent.align
  (#set! indent.open_delimiter "[")
  (#set! indent.close_delimiter "]")
  .
  (_))

(ERROR
  "{" @indent.align
  (#set! indent.open_delimiter "{")
  (#set! indent.close_delimiter "}")
  .
  (_))

[
  (break_statement)
  (continue_statement)
] @indent.dedent

(ERROR
  (_) @indent.branch
  ":"
  .
  (#lua-match? @indent.branch "^else"))

(ERROR
  (_) @indent.branch @indent.dedent
  ":"
  .
  (#lua-match? @indent.branch "^elif"))

(generator_expression
  ")" @indent.end)

(list_comprehension
  "]" @indent.end)

(set_comprehension
  "}" @indent.end)

(dictionary_comprehension
  "}" @indent.end)

(tuple_pattern
  ")" @indent.end)

(list_pattern
  "]" @indent.end)

(return_statement
  [
    (_) @indent.end
    (_
      [
        (_)
        ")"
        "}"
        "]"
      ] @indent.end .)
    (attribute
      attribute: (_) @indent.end)
    (call
      arguments: (_
        ")" @indent.end))
    "return" @indent.end
  ] .)

; As with return, code after raise can't run and code after pass is rare, so
; the next line leaves the block.
(raise_statement
  [
    (_) @indent.end
    (_
      [
        (_)
        ")"
        "}"
        "]"
      ] @indent.end .)
    (attribute
      attribute: (_) @indent.end)
    (call
      arguments: (_
        ")" @indent.end))
    "raise" @indent.end
  ] .)

(pass_statement
  "pass" @indent.end)

[
  ")"
  "]"
  "}"
  (elif_clause)
  (else_clause)
  (except_clause)
  (finally_clause)
] @indent.branch

(string) @indent.auto
