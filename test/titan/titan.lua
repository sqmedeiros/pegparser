local m = require 'init'
local pretty = require 'pretty'
local coder = require 'coder'
local recovery = require 'recovery'
local ast = require'ast'
local util = require'util'

g = [[
  program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import / foreign)* !.
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
  foreign         <-  'local' NAME '=' 'foreign' 'import' ('(' STRINGLIT ')' / STRINGLIT)
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
  e3              <-  e4  (('==' / '~=' / '<=' / '>=' / '<' / '>') e4)*
  e4              <-  e5  ('|'   e5)*
  e5              <-  e6  ('~'!'='   e6)*
  e6              <-  e7  ('&'   e7)*
  e7              <-  e8  (('<<' / '>>') e8)*
  e8              <-  e9  ('..'  e8)?
  e9              <-  e10 (('+' / '-') e10)*
  e10             <-  e11 (('*' / '%%' / '/' / '//') e11)*
  e11             <-  ('not' / '#' / '-' / '~')* e12
  e12             <-  castexp ('^' e11)? 
  suffixedexp     <-  prefixexp expsuffix+
  expsuffix       <-  funcargs  /  ':' NAME funcargs  /  '[' exp ']'  /  '.'!'.' NAME
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
  STRINGLIT       <-  '"' (!'"' .)* '"'  /  "'" (!"'" .)* "'"
  RESERVED        <-  ('and'  / 'as' / 'boolean' / 'break' / 'do' / 'elseif' / 'else' / 'end' / 'float' / 'foreign' / 'for' / 'false'
                     / 'function' / 'goto' / 'if' / 'import' / 'integer' / 'in' / 'local' / 'nil' / 'not' / 'or'
                     / 'record' / 'repeat' / 'return' / 'string' / 'then' / 'true' / 'until' / 'value' / 'while') ![a-zA-Z_0-9]
  NAME            <-  !RESERVED [a-zA-Z_] [a-zA-Z_0-9]*
  NUMBER          <- [0-9]+ ('.'!'.' [0-9]*)?
  COMMENT         <- '--' (!%nl .)* ]]


local g = m.match(g)
print("Original Grammar")
print(pretty.printg(g), '\n')

--local gast = ast.buildAST(g)
--print("With annotations to build AST")
--print(pretty.printg(gast), '\n')

print("Regular Annotation (SBLP paper)")
local glabRegular = recovery.addlab(g, true, false)
print(pretty.printg(glabRegular, true), '\n')

print("Conservative Annotation (Hard)")
local glabHard = recovery.addlab(g, true, true)
print(pretty.printg(glabHard, true), '\n')

print("Conservative Annotation Alt)")
local glab = recovery.addlab(g, true, 'alt')
print(pretty.printg(glab, true), '\n')

--print("Conservative Annotation AltSeq)")
--local glab = recovery.addlab(g, true, 'altseq')
--print(pretty.printg(glab, true), '\n')


local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/titan/test/yes/'
util.testYes(dir, 'titan', p)

local dir = lfs.currentdir() .. '/test/titan/test/no/'
util.testNo(dir, 'titan', p)

