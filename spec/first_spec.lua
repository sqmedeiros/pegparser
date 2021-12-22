local Set = require'set'
local Parser = require'parser'
local First = require'first'

local empty = First.empty
local any = First.any
local endInput = First.endInput
local beginInput = First.beginInput

describe("Testing #first", function()
	
	test("FIRST set of lexical rules", function()
		local g = Parser.match[[
			A   <- 'a'
			B   <- 'b'
			XYZ <- 'w']]
					
		local objFst = First.new(g)
		objFst:calcFirstG()
		
		local setFirst = {}
		for i, v in ipairs(g:getVars()) do
			setFirst[v] = Set.new( { objFst:lexKey(v) } )
		end
		
		assert.same(objFst.FIRST, setFirst)
	end)
		
		
	test("FIRST set of simple syntactical rules", function()
		local g = Parser.match[[
			s   <- 'a'
			a   <- 'b'
			xyz <- .]]
					
		local objFst = First.new(g)
		objFst:calcFirstG()
		
		local setFirst = {}
		setFirst['s'] = Set.new { 'a' }
		setFirst['a'] = Set.new { 'b' }
		setFirst['xyz'] = Set.new { any }
		
		assert.same(objFst.FIRST, setFirst)
	end)
	
	test("FIRST set of concatenation", function()
		local g = Parser.match[[
			s   <- 'a' a
			a   <- xyz 'b'
			b   <- y xyz s
			xyz <- ''
			y   <- '']]
					
		local objFst = First.new(g)
		objFst:calcFirstG()
		
		local setFirst = {}
		setFirst['s'] = Set.new { 'a' }
		setFirst['a'] = Set.new { 'b' }
		setFirst['b'] = Set.new { 'a' }
		setFirst['xyz'] = Set.new { empty }
		setFirst['y'] = Set.new { empty }
		
		assert.same(objFst.FIRST, setFirst)
	end)
	
	test("FIRST set of choice", function()
		local g = Parser.match[[
			s   <- 'a' a / 'x'
			a   <- xyz 'b' / 'otherA'
			b   <- y xyz s / 'otherB1' / xyz a / y
			xyz <- 'X' / ''
			y   <- '' / 'Y']]
					
		local objFst = First.new(g)
		objFst:calcFirstG()
		
		local setFirst = {}
		setFirst['s'] = Set.new { 'a', 'x' }
		setFirst['a'] = Set.new { 'X', 'b', 'otherA' }
		setFirst['b'] = Set.new { 'Y', 'X', 'a', 'x', 'otherB1', 'b', 'otherA', empty }
		setFirst['xyz'] = Set.new { 'X', empty }
		setFirst['y'] = Set.new { empty, 'Y' }
		
		assert.same(objFst.FIRST, setFirst)
	end)
	
	test("FIRST set of repetitions", function()
		local g = Parser.match[[
			s   <- ('a' / 'b')*
			a   <- b?
			b   <- 'c' 'd' / 'e' / 'x'+]]
					
		local objFst = First.new(g)
		objFst:calcFirstG()
		
		local setFirst = {}
		setFirst['s'] = Set.new { 'a', 'b', empty }
		setFirst['a'] = Set.new { 'c', 'e', 'x', empty }
		setFirst['b'] = Set.new { 'c', 'e', 'x' }
		
		assert.same(objFst.FIRST, setFirst)
	end)
	
	--TODO: tests related to &exp, !exp, exp^lab, [a-zA-Z]

	test("Calculating FIRST of a DOT grammar", function()	
		local g = Parser.match[[
			graph             <-   'strict'? ('graph'   /  'digraph') id? '{' stmt_list '}' 
			stmt_list         <-   (stmt ';'? )* 
			stmt              <-   id '=' id   /  edge_stmt   /  node_stmt  /  attr_stmt   /   subgraph 
			attr_stmt         <-   ('graph'   /  'node'   /  'edge' ) attr_list 
			attr_list         <-   ('[' a_list? ']' )+ 
			a_list            <-   (id ('=' id )? ','? )+ 
			edge_stmt         <-   (node_id   /  subgraph ) edgeRHS attr_list? 
			edgeRHS           <-   (edgeop (node_id   /  subgraph ) )+ 
			edgeop            <-   '->'   /  '--' 
			node_stmt         <-   node_id attr_list? 
			node_id           <-   id port? 
			port              <-   ':' id (':' id )? 
			subgraph          <-   ('subgraph' id? )? '{' stmt_list '}'
			id                <-   'a'   /  '"a"'   /  '<a>'   /  '1'
    ]]
    
		local objFst = First.new(g)
		objFst:calcFirstG()
		
		local setFirst = {}
		setFirst['graph'] = Set.new { 'strict', 'graph', 'digraph' }
		setFirst['stmt_list'] = Set.new { 'a', '"a"', '<a>', '1', 'subgraph', '{', 'graph', 'node', 'edge', empty }
		setFirst['stmt'] = Set.new { 'a', '"a"', '<a>', '1', 'subgraph', '{', 'graph', 'node', 'edge' }
		setFirst['attr_stmt'] = Set.new { 'graph', 'node', 'edge' }
		setFirst['attr_list'] = Set.new { '[' }
		setFirst['a_list'] = Set.new { 'a', '"a"', '<a>', '1' }
		setFirst['edge_stmt'] = Set.new { 'a', '"a"', '<a>', '1', 'subgraph', '{' }
		setFirst['edgeRHS'] = Set.new { '->', '--' }
		setFirst['edgeop'] = Set.new { '->', '--' }
		setFirst['node_stmt'] = Set.new { 'a', '"a"', '<a>', '1' }
		setFirst['node_id'] = Set.new { 'a', '"a"', '<a>', '1' }
		setFirst['port'] = Set.new { ':' }
		setFirst['subgraph'] = Set.new { 'subgraph', '{' }
		setFirst['id'] = Set.new { 'a', '"a"', '<a>', '1' }
		
		assert.same(objFst.FIRST, setFirst)    
	end)	
end)


describe("Testing #follow", function()

	test("FOLLOW set of start rule", function()
		local g = Parser.match[[
			s   <- 'a'
		]]

		local objFst = First.new(g)
		objFst:calcFirstG()
		objFst:calcFollowG()

		local setFlw = {}
		setFlw['s'] = Set.new{ endInput }

		assert.same(objFst.FOLLOW, setFlw)
	end)

	test("Grammar with concatenation 1", function()
		local g = Parser.match[[
			s   <- A 'a' A B
			A   <- 'x'
			B   <- 'B' / A
		]]

		local objFst = First.new(g)
		objFst:calcFirstG()
		objFst:calcFollowG()

		local setFlw = {}
		setFlw['s'] = Set.new{ endInput }
		setFlw['A'] = Set.new{ 'a', objFst:lexKey('B') }
		setFlw['B'] = Set.new{ endInput }

		assert.same(objFst.FOLLOW, setFlw)
	end)


	test("Grammar with choice", function()
		local g = Parser.match[[
			s   <- a 'a' a b
			a   <- 'x'
			b   <- 'B' / a b a
		]]

		local objFst = First.new(g)
		objFst:calcFirstG()
		objFst:calcFollowG()

		local setFlw = {}
		setFlw['s'] = Set.new{ endInput }
		setFlw['a'] = Set.new{ 'a', 'B', 'x', endInput }
		setFlw['b'] = Set.new{ endInput, 'x' }

		assert.same(objFst.FOLLOW, setFlw)
	end)


	test("Grammar with empty string", function()
		local g = Parser.match[[
			s   <- a b c
			a   <- 'a'
			b   <- 'b'
			c   <- 'c' / ''
		]]

		local objFst = First.new(g)
		objFst:calcFirstG()
		objFst:calcFollowG()

		local setFlw = {}
		setFlw['s'] = Set.new{ endInput }
		setFlw['a'] = Set.new{ 'b' }
		setFlw['b'] = Set.new{ 'c', endInput }
		setFlw['c'] = Set.new{ endInput }

		assert.same(objFst.FOLLOW, setFlw)
	end)


	test("Grammar with empty string 2", function()
		local g = Parser.match[[
			s   <- a b c d
			a   <- 'a'
			b   <- 'b'
			c   <- 'c' / ''
			d   <- 'd' / ''
		]]

		local objFst = First.new(g)
		objFst:calcFirstG()
		objFst:calcFollowG()

		local setFlw = {}
		setFlw['s'] = Set.new{ endInput }
		setFlw['a'] = Set.new{ 'b' }
		setFlw['b'] = Set.new{ 'c', 'd', endInput }
		setFlw['c'] = Set.new{ 'd', endInput }
		setFlw['d'] = Set.new{ endInput }

		assert.same(objFst.FOLLOW, setFlw)
	end)


	test("Grammar repetition: star", function()
		local g = Parser.match[[
			s   <- a* 'A' b* c*
			a   <- 'x' / 'y'
			b   <- 'b'
			c   <- 'c'
		]]

		local objFst = First.new(g)
		objFst:calcFirstG()
		objFst:calcFollowG()

		local setFlw = {}
		setFlw['s'] = Set.new{ endInput }
		setFlw['a'] = Set.new{ 'x', 'y', 'A' }
		setFlw['b'] = Set.new{ endInput, 'b', 'c' }
		setFlw['c'] = Set.new{ endInput, 'c' }

		assert.same(objFst.FOLLOW, setFlw)
	end)

	test("Grammar repetition: plus", function()
		local g = Parser.match[[
			s   <- a+ 'A' b+ c+
			a   <- 'x' / 'y'
			b   <- 'b'
			c   <- 'c'
		]]

		local objFst = First.new(g)
		objFst:calcFirstG()
		objFst:calcFollowG()

		local setFlw = {}
		setFlw['s'] = Set.new{ endInput }
		setFlw['a'] = Set.new{ 'x', 'y', 'A' }
		setFlw['b'] = Set.new{ 'b', 'c' }
		setFlw['c'] = Set.new{ endInput, 'c' }

		assert.same(objFst.FOLLOW, setFlw)
	end)


	test("Grammar repetition: question/optional", function()
		local g = Parser.match[[
			s   <- a? 'A' b? c?
			a   <- 'x' / 'y'
			b   <- 'b'
			c   <- 'c'
		]]

		local objFst = First.new(g)
		objFst:calcFirstG()
		objFst:calcFollowG()

		local setFlw = {}
		setFlw['s'] = Set.new{ endInput }
		setFlw['a'] = Set.new{ 'A' }
		setFlw['b'] = Set.new{ 'c', endInput}
		setFlw['c'] = Set.new{ endInput }

		assert.same(objFst.FOLLOW, setFlw)
	end)


	test("Grammar repetition", function()
		local g = Parser.match[[
			s   <- a* 'A'
			a   <- b / 'o' c 'd'
			b   <- 'B'? 'x' c+ 'u'
			c   <- 'y' a 'z'?
		]]

		local objFst = First.new(g)
		objFst:calcFirstG()
		objFst:calcFollowG()

		local setFlw = {}
		setFlw['s'] = Set.new{ endInput }
		setFlw['a'] = Set.new{ 'B', 'x', 'o', 'A', 'z', 'd', 'u', 'y' }
		setFlw['b'] = Set.new{ 'B', 'x', 'o', 'A', 'z', 'd', 'u', 'y' }
		setFlw['c'] = Set.new{ 'y', 'u', 'd' }

		assert.same(objFst.FOLLOW, setFlw)
	end)

	test("Calculating FOLLOW of a DOT grammar", function()
		local g = Parser.match[[
			graph             <-   'strict'? ('graph'   /  'digraph') id? '{' stmt_list '}'
			stmt_list         <-   (stmt ';'? )*
			stmt              <-   id '=' id   /  edge_stmt   /  node_stmt  /  attr_stmt   /   subgraph
			attr_stmt         <-   ('graph'   /  'node'   /  'edge' ) attr_list
			attr_list         <-   ('[' a_list? ']' )+
			a_list            <-   (id ('=' id )? ','? )+
			edge_stmt         <-   (node_id   /  subgraph ) edgeRHS attr_list?
			edgeRHS           <-   (edgeop (node_id   /  subgraph ) )+
			edgeop            <-   '->'   /  '--'
			node_stmt         <-   node_id attr_list?
			node_id           <-   id port?
			port              <-   ':' id (':' id )?
			subgraph          <-   ('subgraph' id? )? '{' stmt_list '}'
			id                <-   'a'   /  '"a"'   /  '<a>'   /  '1'
    ]]

		local objFst = First.new(g)
		objFst:calcFirstG()
		objFst:calcFollowG()

		local setFlw = {}
		setFlw['graph'] = Set.new { endInput  }
		setFlw['stmt_list'] = Set.new { '}' }
		setFlw['stmt'] = Set.new      { 'a', '"a"', '<a>', '1', 'subgraph', '{', 'graph', 'node', 'edge', ';', '}' }
		setFlw['attr_stmt'] = Set.new { 'a', '"a"', '<a>', '1', 'subgraph', '{', 'graph', 'node', 'edge', ';', '}' }
		setFlw['attr_list'] = Set.new { 'a', '"a"', '<a>', '1', 'subgraph', '{', 'graph', 'node', 'edge', ';', '}' }
		setFlw['a_list'] = Set.new    { ']' }
		setFlw['edge_stmt'] = Set.new { 'a', '"a"', '<a>', '1', 'subgraph', '{', 'graph', 'node', 'edge', ';', '}' }
		setFlw['edgeRHS'] = Set.new   { 'a', '"a"', '<a>', '1', 'subgraph', '{', 'graph', 'node', 'edge', ';', '}', '[' }
		setFlw['edgeop'] = Set.new    { 'a', '"a"', '<a>', '1', 'subgraph', '{' }
		setFlw['node_stmt'] = Set.new { 'a', '"a"', '<a>', '1', 'subgraph', '{', 'graph', 'node', 'edge', ';', '}' }
		setFlw['node_id'] = Set.new   { 'a', '"a"', '<a>', '1', 'subgraph', '{', 'graph', 'node', 'edge', ';', '}', '[', '->', '--' }
		setFlw['port'] = Set.new      { 'a', '"a"', '<a>', '1', 'subgraph', '{', 'graph', 'node', 'edge', ';', '}', '[', '->', '--' }
		setFlw['subgraph'] = Set.new  { 'a', '"a"', '<a>', '1', 'subgraph', '{', 'graph', 'node', 'edge', ';', '}', '[', '->', '--', '{' }
		setFlw['id'] = Set.new        { 'a', '"a"', '<a>', '1', 'subgraph', '{', 'graph', 'node', 'edge', ';', '}', '=', ',', '->', '--', ':' , '[', ']'}

		assert.same(objFst.FOLLOW, setFlw)
	end)
end)

--[==[
describe("Testing #last", function()

	test("LAST set of simple expresions", function()
		local g = parser.match[[
			s   <- 'a'
			a   <- .
			b   <- ''
			C   <- 'c'
		]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcLastG()

		local setLst = {}
		setLst['s'] = set.new{ 'a' }
		setLst['a'] = set.new{ first.any }
		setLst['b'] = set.new{ first.empty }
		setLst['C'] = set.new{ objFst:lexKey('C') }

		assert.same(objFst.LAST, setLst)
	end)

	test("LAST set of choice expresion", function()
		local g = parser.match[[
			s   <- a / b
			a   <- b / c
			b   <- 'b' / 'B'
			c   <- '' / 'c'
		]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcLastG()

		local setLst = {}
		setLst['s'] = set.new{ 'b', 'B', empty, 'c', }
		setLst['a'] = set.new{ 'b', 'B', empty, 'c' }
		setLst['b'] = set.new{ 'b', 'B' }
		setLst['c'] = set.new{ empty, 'c' }

		assert.same(objFst.LAST, setLst)
	end)

	test("LAST set of choice expresion", function()
		local g = parser.match[[
			id                <-   'a'   /  '"a"'   /  '<a>'   /  '1'
		]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcLastG()

		local setLst = {}
		setLst['id'] = set.new{ 'a', '"a"', '<a>', '1' }

		assert.same(objFst.LAST, setLst)
	end)


	test("LAST set of concatenation", function()
		local g = parser.match[[
			s   <- a c / b d
			a   <- 'a' / 'A'
			b   <- 'b' / 'B'
			c   <- '' / 'c'
			d   <- '' 'e' 'f' / 'e' ''
		]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcLastG()

		local setLst = {}
		setLst['s'] = set.new{ 'a',  'A', 'c', 'f', 'e' }
		setLst['a'] = set.new{ 'a', 'A' }
		setLst['b'] = set.new{ 'b', 'B' }
		setLst['c'] = set.new{ empty, 'c' }
		setLst['d'] = set.new{ 'f', 'e' }

		assert.same(objFst.LAST, setLst)
	end)


	test("LAST set of concatenation 2", function()
		local g = parser.match[[
			x   <- y '' / z ''
			y   <- 'a' / 'A' / z
			z   <- 'b' / 'B'
		]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcLastG()

		local setLst = {}
		setLst['x'] = set.new{ 'a',  'A', 'b', 'B' }
		setLst['y'] = set.new{ 'a', 'A', 'b', 'B' }
		setLst['z'] = set.new{ 'b', 'B' }

		assert.same(objFst.LAST, setLst)
	end)


	test("LAST set of concatenation 3", function()
		local g = parser.match[[
			s   <- x
			x   <- '' y
			y   <- z
			z   <- w
			w   <- 'w'
		]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcLastG()

		local setLst = {}
		setLst['s'] = set.new{ 'w' }
		setLst['x'] = set.new{ 'w' }
		setLst['y'] = set.new{ 'w' }
		setLst['z'] = set.new{ 'w' }
		setLst['w'] = set.new{ 'w' }

		assert.same(objFst.LAST, setLst)
	end)


	test("LAST set of repetition", function()
		local g = parser.match[[
			s   <- 'b' 'a'*
			a   <- 'B'+
			b   <- ('c' / 'C')?
		]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcLastG()

		local setLst = {}
		setLst['s'] = set.new{ 'a', 'b' }
		setLst['a'] = set.new{ 'B' }
		setLst['b'] = set.new{ 'c', 'C', empty }

		assert.same(objFst.LAST, setLst)
	end)


	test("Calculating LAST of id", function()
		local g = parser.match[[
			a_list            <-   ('=' id)?
			id                <-   'a'   /  '"a"'   /  '<a>'   /  '1'
    ]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcLastG()

		local setLst = {}
		setLst['a_list'] = set.new    { 'a', '"a"', '<a>', '1', empty }
		setLst['id'] = set.new        { 'a', '"a"', '<a>', '1' }

		assert.same(objFst.LAST, setLst)
	end)


	test("Calculating LAST of a DOT grammar", function()
		local g = parser.match[[
			graph             <-   'strict'? ('graph'   /  'digraph') id? '{' stmt_list '}'
			stmt_list         <-   (stmt ';'? )*
			stmt              <-   id '=' id   /  edge_stmt   /  node_stmt  /  attr_stmt   /   subgraph
			attr_stmt         <-   ('graph'   /  'node'   /  'edge' ) attr_list
			attr_list         <-   ('[' a_list? ']' )+
			a_list            <-   (id ('=' id )? ','? )+
			edge_stmt         <-   (node_id   /  subgraph ) edgeRHS attr_list?
			edgeRHS           <-   (edgeop (node_id   /  subgraph ) )+
			edgeop            <-   '->'   /  '--'
			node_stmt         <-   node_id attr_list?
			node_id           <-   id port?
			port              <-   ':' id (':' id )?
			subgraph          <-   ('subgraph' id? )? '{' stmt_list '}'
			id                <-   'a'   /  '"a"'   /  '<a>'   /  '1'
    ]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcLastG()


		local setLst = {}
		setLst['graph'] = set.new { '}'  }
		setLst['stmt_list'] = set.new { empty, ';', 'a', '"a"', '<a>', '1', ']', '}' }
		setLst['stmt'] = set.new      { 'a', '"a"', '<a>', '1', ']', '}' }
		setLst['attr_stmt'] = set.new { ']' }
		setLst['attr_list'] = set.new { ']' }
		setLst['a_list'] = set.new    { 'a', '"a"', '<a>', '1', ',' }
		setLst['edge_stmt'] = set.new { ']', 'a', '"a"', '<a>', '1', '}' }
		setLst['edgeRHS'] = set.new   { 'a', '"a"', '<a>', '1', '}' }
		setLst['edgeop'] = set.new    { '->', '--' }
		setLst['node_stmt'] = set.new { 'a', '"a"', '<a>', '1', ']' }
		setLst['node_id'] = set.new   { 'a', '"a"', '<a>', '1' }
		setLst['port'] = set.new      { 'a', '"a"', '<a>', '1' }
		setLst['subgraph'] = set.new  { '}' }
		setLst['id'] = set.new        { 'a', '"a"', '<a>', '1' }

		assert.same(objFst.LAST, setLst)
	end)
end)

describe("Testing #precede", function()

	test("PRECEDE set of the start non-terminal", function()
		local g = parser.match[[
			s   <- 'a'
		]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcLastG()
		objFst:calcPrecedeG()

		local setPre = {}
		setPre['s'] = set.new{ beginInput }

		assert.same(objFst.PRECEDE, setPre)
	end)


	test("PRECEDE set of concatenation", function()
		local g = parser.match[[
			s   <- '' a c
			a   <- 'a' b
			b   <- ''
			c   <- b d e
			d   <- 'd'
			e   <- 'e'
		]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcLastG()
		objFst:calcPrecedeG()

		local setPre = {}
		setPre['s'] = set.new{ beginInput }
		setPre['a'] = set.new{ beginInput }
		setPre['b'] = set.new{ 'a' }
		setPre['c'] = set.new{ 'a' }
		setPre['d'] = set.new{ 'a' }
		setPre['e'] = set.new{ 'd' }

		assert.same(objFst.PRECEDE, setPre)
	end)

	test("PRECEDE set of choice and concatenation", function()
		local g = parser.match[[
			s   <- a / b / c b d
			a   <- A 'c'
			b   <- 'b' b / '' / B
			A   <- 'A'
			B   <- 'B'
			c   <- 'c' c / ''
			d   <- 'd'
		]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcLastG()
		objFst:calcPrecedeG()

		local setPre = {}
		setPre['s'] = set.new{ beginInput }
		setPre['a'] = set.new{ beginInput }
		setPre['b'] = set.new{ beginInput, 'c', 'b' }
		setPre['A'] = set.new{ beginInput }
		setPre['B'] = set.new{ beginInput, 'c', 'b' }
		setPre['c'] = set.new{ beginInput, 'c' }
		setPre['d'] = set.new{ beginInput, 'c', 'b', objFst:lexKey'B' }

		assert.same(objFst.PRECEDE, setPre)
	end)

	test("PRECEDE set of repetitions", function()
		local g = parser.match[[
			s   <- a+ b* c
			a   <- 'a' 'A'? c
			b   <- 'b'
			c   <- 'c'
		]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcLastG()
		objFst:calcPrecedeG()

		local setPre = {}
		setPre['s'] = set.new{ beginInput }
		setPre['a'] = set.new{ beginInput, 'c' }
		setPre['b'] = set.new{ 'c', 'b' }
		setPre['c'] = set.new{ 'c', 'b', 'a', 'A' }

		assert.same(objFst.PRECEDE, setPre)
	end)

	test("Calculating PRECEDE of a DOT grammar", function()
		local g = parser.match[[
			graph             <-   'strict'? ('graph'   /  'digraph') id? '{' stmt_list '}'
			stmt_list         <-   (stmt ';'? )*
			stmt              <-   id '=' id   /  edge_stmt   /  node_stmt  /  attr_stmt  /  subgraph
			attr_stmt         <-   ('graph'   /  'node'   /  'edge' ) attr_list
			attr_list         <-   ('[' a_list? ']' )+
			a_list            <-   (id ('=' id )? ','? )+
			edge_stmt         <-   (node_id   /  subgraph ) edgeRHS attr_list?
			edgeRHS           <-   (edgeop (node_id   /  subgraph ) )+
			edgeop            <-   '->'   /  '--'
			node_stmt         <-   node_id attr_list?
			node_id           <-   id port?
			port              <-   ':' id (':' id )?
			subgraph          <-   ('subgraph' id? )? '{' stmt_list '}'
			id                <-   'a'   /  '"a"'   /  '<a>'   /  '1'
    ]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcLastG()
		objFst:calcPrecedeG()

		local setPre = {}
		setPre['graph'] = set.new { beginInput }
		setPre['stmt_list'] = set.new { '{' }
		setPre['stmt'] = set.new      { '{', ';', 'a', '"a"', '<a>', '1', ']', '}' }
		setPre['attr_stmt'] = set.new { '{', ';', 'a', '"a"', '<a>', '1', ']', '}' }
		setPre['attr_list'] = set.new { 'graph', 'node', 'edge', 'a', '"a"', '<a>', '1', '}' }
		setPre['a_list'] = set.new    { '[' }
		setPre['edge_stmt'] = set.new { '{', ';', 'a', '"a"', '<a>', '1', ']', '}' }
		setPre['edgeRHS'] = set.new   { 'a', '"a"', '<a>', '1', '}' }
		setPre['edgeop'] = set.new    { 'a', '"a"', '<a>', '1', '}' }
		setPre['node_stmt'] = set.new { '{', ';', 'a', '"a"', '<a>', '1', ']', '}' }
		setPre['node_id'] = set.new   { '{', ';', 'a', '"a"', '<a>', '1', ']', '}', '->', '--' }
		setPre['port'] = set.new      { 'a', '"a"', '<a>', '1' }
		setPre['subgraph'] = set.new  { '{', ';', 'a', '"a"', '<a>', '1', ']', '}', '->', '--' }
		setPre['id'] = set.new        { '{', ';', 'a', '"a"', '<a>', '1', ']', '}', '->', '--', ':', '=', ',', '[', 'subgraph', 'graph', 'digraph' }

		assert.same(objFst.PRECEDE, setPre)
	end)

end)


describe("Testing #left", function()

	test("LEFT set of a BNF grammar 1", function()
		local g = parser.match[[
			s   <- a 'b' / 'c' 'd'
			a   <- 'a' 'b'
		]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcFollowG()
		objFst:calcLastG()
		objFst:calcPrecedeG()
		objFst:calcLeftG()

		local setLeft = {}
		setLeft["s:__a"] = set.new{ beginInput }
		setLeft["s:__a__'b'"] = set.new{ 'b' }
		setLeft["s:__'c'"] = set.new{ beginInput }
		setLeft["s:__'c'__'d'"] = set.new{ 'c' }
		setLeft["a:__'a'"] = set.new{ beginInput }
		setLeft["a:__'a'__'b'"] = set.new{ 'a' }

		assert.same(objFst.LEFT, setLeft)

	end)

	test("LEFT set of a BNF grammar 2", function()
		local g = parser.match[[
			s   <- a '' b / a 'b' a 'y'
			a   <- 'a' / ''
			b   <- 'b'
		]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcFollowG()
		objFst:calcLastG()
		objFst:calcPrecedeG()
		objFst:calcLeftG()

		local setLeft = {}
		setLeft["s:__a"] = set.new{ beginInput }
		setLeft["s:__a__''"] = set.new{ beginInput, 'a' }
		setLeft["s:__a__''__b"] = set.new{ 'a', beginInput }
		setLeft["s:__a__'b'"] = set.new{ 'a', beginInput }
		setLeft["s:__a__'b'__a"] = set.new{ 'b' }
		setLeft["s:__a__'b'__a__'y'"] = set.new{ 'a', 'b' }
		setLeft["a:__'a'"] = set.new{ beginInput, 'b' }
		setLeft["a:__''"] = set.new{ beginInput, 'b' }
		setLeft["b:__'b'"] = set.new{ 'a', beginInput }
		assert.same(objFst.LEFT, setLeft)
	end)


	test("LEFT set of a BNF grammar 3", function()
		local g = parser.match[[
			s   <- a '' b / a 'b' c 'y'
			a   <- 'a' a / ''
			b   <- 'b' a
			c   <- 'c' / ''
		]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcFollowG()
		objFst:calcLastG()
		objFst:calcPrecedeG()
		objFst:calcLeftG()

		local setLeft = {}
		setLeft["s:__a"] = set.new{ beginInput }
		setLeft["s:__a__''"] = set.new{ 'a', beginInput }
		setLeft["s:__a__''__b"] = set.new{ 'a', beginInput }
		setLeft["s:__a__'b'"] = set.new{ 'a', beginInput }
		setLeft["s:__a__'b'__c"] = set.new{ 'b' }
		setLeft["s:__a__'b'__c__'y'"] = set.new{ 'c', 'b' }
		setLeft["a:__'a'"] = set.new{ beginInput, 'b', 'a' }
		setLeft["a:__'a'__a"] = set.new{ 'a' }
		setLeft["a:__''"] = set.new{ beginInput, 'b', 'a' }
		setLeft["b:__'b'"] = set.new{ 'a', beginInput }
		setLeft["b:__'b'__a"] = set.new{ 'b' }
		setLeft["c:__'c'"] = set.new{ 'b' }
		setLeft["c:__''"] = set.new{ 'b' }
		assert.same(objFst.LEFT, setLeft)
	end)

end)

describe("Testing #right", function()

	test("RIGHT set of a BNF grammar 1", function()
		local g = parser.match[[
			s   <- a 'b' / 'c' 'd'
			a   <- 'a' 'b'
		]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcFollowG()
		objFst:calcLastG()
		objFst:calcPrecedeG()
		objFst:calcRightG()

		local setRight = {}
		setRight["s:__a"] = set.new{ 'b' }
		setRight["s:__a__'b'"] = set.new{ endInput }
		setRight["s:__'c'"] = set.new{ 'd' }
		setRight["s:__'c'__'d'"] = set.new{ endInput }
		setRight["a:__'a'"] = set.new{ 'b' }
		setRight["a:__'a'__'b'"] = set.new{ 'b' }

		assert.same(objFst.RIGHT, setRight)

	end)
	
	test("RIGHT set of a BNF grammar 2", function()
		local g = parser.match[[
			s   <- 'b' a / 'c' '' 'd'
			a   <- 'a' a / ''
		]]

		local objFst = first.new(g)
		objFst:calcFirstG()
		objFst:calcFollowG()
		objFst:calcLastG()
		objFst:calcPrecedeG()
		objFst:calcRightG()

		local setRight = {}
		setRight["s:__'b'"] = set.new{ 'a', endInput }
		setRight["s:__'b'__a"] = set.new{ endInput }
		setRight["s:__'c'"] = set.new{ 'd' }
		setRight["s:__'c'__''"] = set.new{ 'd' }
		setRight["s:__'c'__''__'d'"] = set.new{ endInput }
		setRight["a:__'a'"] = set.new{ 'a', endInput }
		setRight["a:__'a'__a"] = set.new{ endInput }
		setRight["a:__''"] = set.new{ endInput }

		assert.same(objFst.RIGHT, setRight)

	end)
end)

]==]