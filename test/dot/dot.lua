local m = require 'pegparser.parser'
local pretty = require 'pegparser.pretty'
local coder = require 'pegparser.coder'
local recovery = require 'pegparser.recovery'
local ast = require'pegparser.ast'
local util = require'pegparser.util'

local s = [[
graph <- STRICT? ( GRAPH / DIGRAPH ) id? '{' stmt_list '}'

-- why changing stmt below to 'a' causes an error?
stmt_list <- ( stmt ';'? )*

--original rule
stmt <- node_stmt / edge_stmt / attr_stmt / id '=' id / subgraph
--putting alternatives "id '=' id" and "edge_stmt" before "node_stmt"
stmt <- id '=' id / edge_stmt / node_stmt / attr_stmt / subgraph



attr_stmt <-  ( GRAPH / NODE / EDGE ) attr_list

attr_list <- ( '[' a_list? ']' )+

a_list <- ( id ( '=' id )? ','? )+

edge_stmt <- ( node_id / subgraph ) edgeRHS attr_list?

edgeRHS <- ( edgeop ( node_id / subgraph ) )+

edgeop <- '->' / '--'

node_stmt <- node_id attr_list?
   
node_id <- id port?

port <- ':' id ( ':' id )?

subgraph <- ( SUBGRAPH id? )? '{' stmt_list '}'

id <- ID / STRING / HTML_STRING / NUMBER


STRICT <- [Ss] [Tt] [Rr] [Ii] [Cc] [Tt]

GRAPH <- [Gg] [Rr] [Aa] [Pp] [Hh]

DIGRAPH <- [Dd] [Ii] [Gg] [Rr] [Aa] [Pp] [Hh]

NODE <- [Nn] [Oo] [Dd] [Ee]

EDGE <- [Ee] [Dd] [Gg] [Ee]

SUBGRAPH <- [Ss] [Uu] [Bb] [Gg] [Rr] [Aa] [Pp] [Hh]

NUMBER <-  '-'? ( '.' DIGIT+ / DIGIT+ ( '.' DIGIT* )? )

DIGIT <- [0-9]

STRING     <-  '"' (!'"' .)* '"'  /  "'" (!"'" .)* "'"

ID <- (LETTER / '_') ( LETTER / DIGIT / '_')*
   
LETTER <- [a-zA-Z]

--original rule
-- HTML_STRING: '<' ( TAG | ~ [<>] )* '>'
   
HTML_STRING <- '<' ( TAG / ![<>] .)* '>'

TAG <- '<' .*? '>'

--original rule 
--COMMENT <-  '/*' .*? '*/' 
COMMENT <-  '/*' (!'*/' .)* '*/'    

--original rule
--LINE_COMMENT <- '//' .*? '\r'? '\n' 
LINE_COMMENT <- '//' (!('\r'? '\n') .)* '\r'? '\n' 


-- "a '#' character is considered a line output from a C preprocessor (e.g.,
--  # 34 to indicate line 34 ) and discarded"
  
PREPROC <- '#' ![\r\n]*

--  STRING         <-  '"' (!'"' .)* '"'  /  "'" (!"'" .)* "'"
  NUMBER          <- [0-9]+ ('.'!'.' [0-9]*)?
  EOF            <- !.
]]


print("Unique Path (UPath)")
g = m.match(s)
print(m.match(s))
local gupath = recovery.putlabels(g, 'upath', true)
print(pretty.printg(gupath, true), '\n')
--print(pretty.printg(gupath, true, 'unique'), '\n')
--print(pretty.printg(gupath, true, 'uniqueEq'), '\n')
pretty.printToFile(g, nil, 'dot', 'rec')

print("End UPath\n")


g = m.match(s)
local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0])

util.testYes(dir .. '/yes/', 'dot', p)

--util.testNo(dir .. '/test/no/', 'titan', p)

--util.testNoRecDist(dir .. '/test/no/', 'titan', p)

