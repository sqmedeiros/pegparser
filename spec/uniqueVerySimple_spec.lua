local UVerySimple = require"uniqueVerySimple"
local Parser = require"parser"
local Set = require"set"
local Pretty = require"pretty"
local Util = require"util"

local pretty = Pretty.new()

local function checkPrint (s)
    local g, msg = Parser.match(s)
    assert.is_not_nil(g)
    local pretty = Pretty.new()
    return Util.sameWithoutSpace(pretty:printg(g), s)
end


local function sameListMap(list, map)
	local copyMap = {}
	for k, v in pairs(map) do
		copyMap[k] = v
	end

	for i, v in ipairs(list) do
		assert.True(map[v], "Absent key " .. tostring(v))
		copyMap[v] = nil
	end
	
	assert.True(next(copyMap) == nil)
end


describe("Testing #unique", function()
	test("Calculating unique tokens", function()
	  --The right-hand side of a lexical rule does not influence unique tokens
		local g = Parser.match[[
			s <- 'a' 'b' / A / b   
			A <- 'a' / 'c'        --lexical rule
			b <- 'b' / 'c' / 'd' / 'A']]
			
		local unique = UVerySimple.new(g)

		local tabUnique = unique:uniqueTk()
		
		sameListMap({"'a'", "A", "'c'", "'d'", "'A'"}, tabUnique)
	end)
	
end)
			
describe("Testing #calcUniquePath", function()
	
    test("The matching of the start rule must succeed", function()
        local g = Parser.match[[
            s <- 'a' 'b'
        ]]
        
        local unique = UVerySimple.new(g)
        unique:calcUniquePath()
            
        local g_unique = [[
            s <- 'a'_unique 'b'_unique
        ]]
        assert.is_true(Util.checkProperty(g, g_unique, "unique"))
    
        local g_label = [[
            s <- 'a' 'b'_label
        ]]
        assert.is_true(Util.checkProperty(g, g_label, "label"))
    end)


    test([[The alternatives of this choice are disjoint.
           The choice must succeed, since that the start rule must succeed.
           After matching a symbol in the FIRST set of the the first
           alternative, a later failure while matching this alternative is an error.
           As the choice must succeed, the last alternative must succeed
           when we try to match it (the last choice alternative optimization,
           not tested here, should put a label on 'c']], function()
           
		local g = Parser.match[[
                s <- 'a' 'b' / 'c' 'd'
        ]]
        
        local unique = UVerySimple.new(g)
		unique:calcUniquePath()

        local g_unique = [[
            s <- 'a'_unique 'b'_unique / 'c'_unique 'd'_unique
        ]]
        assert.is_true(Util.checkProperty(g, g_unique, "unique"))
		
        local g_label = [[
            s <- 'a' 'b'_label / 'c' 'd'_label
        ]]
        assert.is_true(Util.checkProperty(g, g_label, "label"))
	end)

    
	test("The right-hand side of a lexical rule does not influence unique tokens", function()

		local g = Parser.match[[
			s <- 'a' 'b' / A / b   
			A <- 'a' / 'c'        --lexical rule
			b <- 'b' / 'c' / 'd' / 'A']]
			
		local unique = UVerySimple.new(g)
		unique:calcUniquePath()
        
        local g_unique = [[
			s <- 'a'_unique 'b' / A_unique / b   
			b <- 'b' / 'c'_unique / 'd'_unique / 'A'_unique
        ]]
        assert.is_true(Util.checkProperty(g, g_unique, "unique"))
        
        local g_label = [[
			s <- 'a' 'b'_label / A / b   
			b <- 'b' / 'c' / 'd' / 'A'
        ]]
        assert.is_true(Util.checkProperty(g, g_label, "label"))
	end)


    test([[The alternatives of this choice are not disjoint.,
          As the start rule must succeed, the choice must succeed. Thus,
          the last alternative of this choice must succeed.]], function()
        
        local g = Parser.match[[
            s <- 'a' 'b' / 'a' 'c'
        ]]
        
        local unique = UVerySimple.new(g)
        unique:calcUniquePath()
            
        local g_unique = [[
            s <- 'a' 'b'_unique / 'a' 'c'_unique
        ]]
        assert.is_true(Util.checkProperty(g, g_unique, "unique"))
    
        local g_label = [[
            s <- 'a' 'b' / 'a' 'c'
        ]]
        assert.is_true(Util.checkProperty(g, g_label, "label"))
    end)
    
    test([[The alternatives of the choice in the start rule are disjoint.
           This choice must succeed, so we can annotate the whole choice as also
           as its second alternative. The choice in rule x is disjoint, but we can not annotate,
           because it is used in the first alternative of rule s where the context is not unique
        (the parser can backtrack after failing to match x here)]], function()
        
        local g = Parser.match[[
            s <- x 'b' / 'c' 'd'
            x <- 'a' / 'A'
        ]]
        
        local unique = UVerySimple.new(g)
        unique:calcUniquePath()
            
        local g_unique = [[
            s <- x 'b'_unique / 'c'_unique 'd'_unique
            x <- 'a'_unique / 'A'_unique
        ]]
        assert.is_true(Util.checkProperty(g, g_unique, "unique"))
    
        local g_label = [[
            s <- x 'b' / 'c' 'd'_label
            x <- 'a' / 'A'
        ]]
        assert.is_true(Util.checkProperty(g, g_label, "label"))
    end)
    
    
    test([[]], function()
        
        local g = Parser.match[[
            s <- (x  / y)*
            x <- 'a' 'b'
            y <- 'a' 'c' 'd'
        ]]
        
        local unique = UVerySimple.new(g)
        unique:calcUniquePath()
            
        local g_unique = [[
            s <- (x  / y)*
            x <- 'a' 'b'_unique
            y <- 'a' 'c'_unique 'd'_unique
        ]]
        assert.is_true(Util.checkProperty(g, g_unique, "unique"))
    
        local g_label = [[
            s <- (x  / y)*
            x <- 'a' 'b'
            y <- 'a' 'c' 'd'_label
        ]]
        assert.is_true(Util.checkProperty(g, g_label, "label"))
    end)
    
    test([[]], function()
        
        local g = Parser.match[[
            program         <-  (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* 
            toplevelfunc    <-  localopt 'function' 'name' '(' ')' 'return' 'end'
            toplevelvar     <-  localopt 'name' '=' 'x'
            toplevelrecord  <-  'record' 'name' '{' '}' 'end'
            localopt        <-  'local'?
            import          <-  'local' 'name' '=' 'import' ('(' 'string' ')'  /  'string')
            foreign         <-  'local' 'name' '=' 'foreign' 'import' ('(' 'string' ')'  /  'string')
        ]]
        
        local unique = UVerySimple.new(g)
        unique:calcUniquePath()
            
        local g_unique = [[
            program         <-  (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* 
            toplevelfunc    <-  localopt 'function'_unique 'name' '(' ')' 'return'_unique 'end'
            toplevelvar     <-  localopt 'name' '=' 'x'_unique
            toplevelrecord  <-  'record'_unique 'name' '{'_unique '}'_unique 'end'
            localopt        <-  'local'?
            import          <-  'local' 'name' '=' 'import' ('(' 'string' ')'  /  'string')
            foreign         <-  'local' 'name' '=' 'foreign'_unique 'import' ('(' 'string' ')'  /  'string')
        ]]
        assert.is_true(Util.checkProperty(g, g_unique, "unique"))
    
        local g_label = [[
            program         <-  (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* 
            toplevelfunc    <-  localopt 'function' 'name'_label '('_label ')'_label 'return'_label 'end'_label
            toplevelvar     <-  localopt 'name' '=' 'x'
            toplevelrecord  <-  'record' 'name'_label '{'_label '}'_label 'end'_label
            localopt        <-  'local'?
            import          <-  'local' 'name' '=' 'import' ('(' 'string' ')'  /  'string')
            foreign         <-  'local' 'name' '=' 'foreign' 'import'_label ('(' 'string' ')'  /  'string')
        ]]
        assert.is_true(Util.checkProperty(g, g_label, "label"))
    end)

	
end)
