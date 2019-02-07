local m = require 'init'
local pretty = require 'pretty'
local coder = require 'coder'
local recovery = require 'recovery'
local ast = require'ast'
local util = require'util'


local g = [[
  blockstmt  <-  '{' stmt* '}'
  stmt       <-  ifstmt / whilestmt / printstmt / decstmt / assignstmt / blockstmt
  ifstmt     <-  'if' '(' exp ')' stmt ('elsee' stmt / '') 
  whilestmt  <-   'while' '(' exp ')' stmt 
  decstmt    <-  'int' NAME ('=' exp / '') ';'
  assignstmt <-  NAME '='!'=' exp ';'
  printstmt  <-  'System.out.println' '(' exp ')' ';'
  exp        <-  relexp ('==' relexp)*
  relexp     <-  addexp ('<' addexp)*
  addexp     <-  mulexp (ADDOP mulexp)*
  ADDOP      <-  '+' / '-'
  mulexp     <-  atomexp (MULOP atomexp)*
  MULOP      <-  '*' / '/' 
  atomexp    <-  '(' exp ')' / NUMBER / NAME
  NUMBER     <-  ('-' / '') [0-9]+
  KEYWORDS   <-  ('if' / 'while' / 'public' / 'class' / 'static' / 'else' / 'void' / 'int') ![a-z0-9]*
  NAME       <-  !KEYWORDS [a-z][a-z0-9]*]]


local g = m.match(g)
print("Original Grammar")
print(pretty.printg(g), '\n')


local first = require'first'
first.calcFst(g)
first.calcFlw(g)
print("FIRST")
first.printfirst(g)
print("FOLLOW")
first.printfollow(g)

print("Regular Annotation (SBLP paper)")
local glabRegular = recovery.addlab(g, true, false)
print(pretty.printg(glabRegular, true), '\n')

print("Conservative Annotation (Hard)")
local glabHard = recovery.addlab(g, true, true)
print(pretty.printg(glabHard, true), '\n')

print("Conservative Annotation (Soft)")
local glabSoft = recovery.addlab(g, true, 'soft')
print(pretty.printg(glabSoft, true), '\n')


