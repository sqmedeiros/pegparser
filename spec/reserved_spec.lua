local Cfg2Peg = require'cfg2peg'
local Parser = require'parser'
local Pretty = require'pretty'
local Util = require'util'


local function checkConversionToPeg (stringG, stringPeg, config)
	local g = Parser.match(stringG)
	assert.is_not_nil(g)
	
	config = config or {}
	
	local c2p = Cfg2Peg.new(g)
	c2p:setUsePrefix(config.prefix)
	c2p:setUseUnique(config.unique)
	c2p:convert(config.idRule, config.reserved)
	
	local peg = c2p.peg
    local pretty = Pretty.new()
    local equal = Util.sameWithoutSpace(pretty:printg(peg, nil, true), stringPeg)
    
    if not equal then
		print("---- Different ----\n")
		print(">>>> Generated PEG <<<<")
		print(pretty:printg(peg, nil, true))
		print("\n**** Expected PEG ****")
		print(stringPeg)
		print("")
    end
    
    assert.is_true(equal)
end


describe("Transforming a CFG into an equivalent PEG\n", function()

    local pretty = Pretty.new()

	test("Identifying the rule that matches an identifier", function()
		local g = [[
			Id  <- [a-z] [a-z0-9]*
		]]

		-- I'm favoring readability here, so I used __IdRest directly instead of Cfg2Peg.IdRest
        local peg = [[
			Id  <- [a-z] [a-z0-9]*
			__IdBegin <- [a-z]
			__IdRest <- [a-z0-9]*
        ]] 

		checkConversionToPeg(g, peg, { idRule = 'Id', reserved = true})
	end)
	
    
	test([[Extra checks to not mismatch identifiers and reserved words]], function()
		local g = [[
			a   <- 'a' / 'y'
            b   <- 'a' / 'a''y'
			Id  <- [a-z] [a-z0-9]*
		]]

		-- I'm favoring readability here, so I used __IdRest directly instead of Cfg2Peg.IdRest
        local peg = [[
			a   <-  ZLex_001 / ZLex_002
            b   <- ZLex_001 / ZLex_001 ZLex_002
			Id  <- !__Keywords [a-z] [a-z0-9]*
			__IdBegin <- [a-z]
			__IdRest <- [a-z0-9]*
			ZLex_001 <- 'a' !__IdRest
			ZLex_002 <- 'y' !__IdRest
			__Keywords <- ZLex_001 / ZLex_002
        ]]

		checkConversionToPeg(g, peg, {idRule = 'Id', reserved = true})
	end)
	
	test("Not matching keywords as identifiers", function()
        local g = [[
            s <- 'there' 'AB'
            x <- 'x9' '3' y
            y <- ('bb' z)*
            z <- id
            Number <- ('x' / 'X') [0-9]+
            id  <- [a-z] [a-z0-9]*
		]]

        local peg = [[
            s <- ZLex_001 ZLex_002
            x <- ZLex_003  ZLex_004 y
            y <- (ZLex_005 z)*
            z <- id
            Number <- ('x' / 'X') [0-9]+ !__IdRest
            id  <- !__Keywords [a-z] [a-z0-9]*
            __IdBegin <- [a-z]
            __IdRest <- [a-z0-9]*
            ZLex_001 <- 'there' !__IdRest
            ZLex_002 <- 'AB' !__IdRest
            ZLex_003 <- 'x9' !__IdRest
            ZLex_004 <- '3'
            ZLex_005 <- 'bb' !__IdRest
            __Keywords <- Number / ZLex_001 / ZLex_002 / ZLex_003 / ZLex_005
        ]]

		checkConversionToPeg(g, peg, {idRule = 'id', reserved = true})
	end)
	
	test([[Keywords defined in lexical rules via char set]], function()
		local g = [[
			a   <- DO / END
            DO  <- [Dd] [Oo]
            END <- 'end'
			Id  <- [a-z] [a-z0-9]*
		]]

        local peg = [[
			a   <- DO / END
            DO  <- [Dd] [Oo] !__IdRest
            END <- 'end' !__IdRest
			Id  <- !__Keywords [a-z] [a-z0-9]*
			__IdBegin <- [a-z]
			__IdRest <- [a-z0-9]*
			__Keywords <- DO / END
        ]]

		checkConversionToPeg(g, peg, {idRule = 'Id', reserved = true})
	end)
	
	
end)
