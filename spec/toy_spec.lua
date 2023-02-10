local Parser = require 'pegparser.parser'
local Pretty = require 'pegparser.pretty'
local Util = require'pegparser.util'
local Cfg2Peg = require'pegparser.cfg2peg'
local Coder = require'pegparser.coder'

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


    test("Converting DOT grammar - Dealing with reserved words", function()
        local g = [[
init   <-   a b 
a   <-   'x'* 'x'
b   <-   'x' 
ID  <-   [a-z][a-z]*
]]

	local peg = [[
init   <-   a b
a   <-   __rep_001 ZLex_001
b   <-   ZLex_001 
ID  <-   !__Keywords [a-z][a-z]*
ZLex_001 <- 'x' !__IdRest
__rep_001 <- ZLex_001 __rep_001 / &ZLex_001
__IdBegin <- [a-z]
__IdRest <- [a-z]
__Keywords <- ZLex_001
]]
	checkConversionToPeg(g, peg, {unique = true, idRule = "ID", reserved = "true"})

    end)
end)
