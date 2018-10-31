local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'

g = [[
  program         <-  SKIP* (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import / foreign)* !.
  toplevelfunc    <-  localopt 'function' NAME '(' paramlist ')' rettypeopt block 'end'
  ]]--predicate in 'toplevalvar' is related to the use of labels
  --toplevelvar     <-  <localopt> <decl> '=' !('import' / 'foreign') <exp>
  ..[[
  toplevelvar     <-  localopt decl '=' exp
  toplevelrecord  <-  'record' NAME recordfields 'end'
  localopt        <-  'local'?
  ]]--predicate in 'import' is related to the use of labels
  --import          <-  'local' <NAME> '=' !'foreign' 'import' ('(' <STRINGLIT> ')' / <STRINGLIT>)
  ..[[
  import          <-  'local' NAME '=' 'import' ('(' STRINGLIT ')' / STRINGLIT)
  foreign         <-  'local' NAME '=' 'foreign' ('(' STRINGLIT ')' / STRINGLIT)
  rettypeopt      <-  (':' rettype)?
  paramlist       <-  (param (',' param)*)?
  param           <-  NAME ':' type
  decl            <-  NAME (':' type)?
  decllist        <-  decl (',' decl)*
  simpletype      <-  'nil' / 'boolean' / 'integer' / 'float' / 'string' / 'value' / NAME / '{' type '}'
  typelist        <-  '(' (type (',' type)*)? ')'
  rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
  type            <-  typelist '->' rettype  /  simpletype '->' rettype  /  simpletype
  recordfields    <-  recordfield+
  recordfield     <-  NAME ':' type ';'?
  block           <-  statement* returnstat?
  statement       <-  ';'  /  'do' block 'end'  /  'while' exp 'do' block 'end'  /  'repeat' block 'until' exp  /  'if' exp 'then' block elseifstats elseopt 'end'  /  'for' decl '=' exp ',' exp (',' exp)? 'do' block 'end'  /  'local' decllist '=' explist  /  varlist '=' explist  /  suffixedexp
  elseifstats     <-  elseifstat*
  elseifstat      <-  'elseif' exp 'then' block
  elseopt         <-  ('else' block)?
  returnstat      <-  'return' explist? ';'?
  exp             <-  e1
  e1              <-  e2  ('or'  e2)*
  e2              <-  e3  ('and' e3)*
  e3              <-  e4  (('==' / '~=' / '<' / '>' / '<=' / '>=') e4)*
  e4              <-  e5  ('|'   e5)*
  e5              <-  e6  ('~'   e6)*
  e6              <-  e7  ('&'   e7)*
  e7              <-  e8  (('<<' / '>>') e8)*
  e8              <-  e9  ('..'  e8)?
  e9              <-  e10 (('+' / '-') e10)*
  e10             <-  e11 (('*' / '%%' / '/' / '//') e11)*
  e11             <-  ('not' / '#' / '-' / '~')* e12
  e12             <-  castexp ('^' e11)? 
  suffixedexp     <-  prefixexp expsuffix+
  expsuffix       <-  funcargs  /  ':' NAME funcargs  /  '[' exp ']'  /  '.' NAME
  prefixexp       <-  NAME  /  '(' exp ')'
  castexp         <-  simpleexp 'as' type  /  simpleexp
  simpleexp       <-  'nil' / 'false' / 'true' / NUMBER / STRINGLIT / initlist / suffixedexp / prefixexp
  var             <-  suffixedexp  /  NAME !expsuffix
  varlist         <-  var (',' var)*               
  funcargs        <-  '(' explist? ')'  /  initlist  /  STRINGLIT
  explist         <-  exp (',' exp)*
  initlist        <-  '{' fieldlist? '}' 
  ]]--predicate in 'fieldlist' is related to the use of labels
  --fieldlist       <-  <field> (<fieldsep> (<field> / !'}' %ExpFieldList)* <fieldsep>?
  ..[[fieldlist       <-  field (fieldsep field)* fieldsep?
  field           <-  (NAME '=')? exp
  fieldsep        <-  ';' / ','
  STRINGLIT       <-  '"' (!'"' .)* '"'
  RESERVED        <- 'repeat' 
  NAME            <-  !RESERVED 'X' ('a' / 'b' / 'c' / NUMBER)*
  NUMBER          <- ('0' /  '1' / '2' / '3' / '4' / '5' / '6' / '7' / '8' / '9')+
  SKIP            <-  ' ']]


local tree, r1 = m.match(g)
print(pretty.printg(tree, r1))
print()

print("Regular Annotation")
local glab, r2 = recovery.addlab(tree, r1, true, false)
print(pretty.printg(glab, r2))
print()


print("Conservative Annotation (Hard)")
local glab, r2 = recovery.addlab(tree, r1, false, true)
print(pretty.printg(glab, r2))
print()


print("Conservative Annotation (Soft)")
local glab, r2 = recovery.addlab(tree, r1, false, 'soft')
print(pretty.printg(glab, r2))
print()
