local Cfg2Peg = require'cfg2peg'
local Parser = require'parser'
local Pretty = require'pretty'
local Util = require'util'


local function checkConversionToPeg (stringG, stringPeg, config)
	local g = Parser.match(stringG)
	assert.is_not_nil(g)
	
	config = config or {}
	
	print("Tokens: ")
	for k, v in pairs(g.tokenSet) do
		io.write(k .. '; ')
	end
	io.write('\n')
	
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


    test("Converting ABNF grammar - Dealing with reserved words", function()
        local g = [[
rulelist   <-   rule_* EOF 
rule_   <-   ID '=' '/'? elements 
elements   <-   alternation 
alternation   <-   concatenation ('/' concatenation )* 
concatenation   <-   repetition+ 
repetition   <-   repeat? element 
repeat   <-   INT   /  (INT? '*' INT? ) 
element   <-   ID   /  group   /  option   /  STRING   /  NumberValue   /  ProseValue 
group   <-   '(' alternation ')' 
option   <-   '[' alternation ']' 
NumberValue   <-   '%' (BinaryValue  /  DecimalValue  /  HexValue)
fragment BinaryValue   <-   'b' BIT+ (('.' BIT+)+  /  ('-' BIT+))?
fragment DecimalValue   <-   'd' DIGIT+ (('.' DIGIT+)+  /  ('-' DIGIT+))?
fragment HexValue   <-   'x' HEX_DIGIT+ (('.' HEX_DIGIT+)+  /  ('-' HEX_DIGIT+))?
ProseValue   <-   '<' ((!'>' .))* '>'
ID   <-   LETTER (LETTER  /  DIGIT  /  '-')*
INT   <-   [0-9]+
COMMENT   <-   ';' (!('\n'  /  '\r') .)* '\r'? '\n'
WS   <-   (' '  /  '\t'  /  '\r'  /  '\n')
STRING   <-   ('%s'  /  '%i')? '"' ((!'"' .))* '"'
fragment LETTER   <-   [a-z]  /  [A-Z]
fragment BIT   <-   [0-1]
fragment DIGIT   <-   [0-9]
fragment HEX_DIGIT   <-   ([0-9]  /  [a-f]  /  [A-F])
]]

	local peg = [[
rulelist   <-   rule_* EOF 
rule_   <-   ID ZLex_001 ZLex_002? elements 
elements   <-   alternation 
alternation   <-   concatenation (ZLex_002 concatenation )* 
concatenation   <-   __rep_001
repetition   <-   repeat? element 
repeat   <-   INT? ZLex_003 INT? /  INT 
element   <-   ID   /  group   /  option   /  STRING   /  NumberValue   /  ProseValue 
group   <-   ZLex_004 alternation ZLex_005
option   <-   ZLex_006 alternation ZLex_007
NumberValue   <-   '%' (BinaryValue  /  DecimalValue  /  HexValue)
BinaryValue   <-   'b' BIT+ (('.' BIT+)+  /  '-' BIT+)?
DecimalValue   <-   'd' DIGIT+ (('.' DIGIT+)+  /  '-' DIGIT+)?
HexValue   <-   'x' HEX_DIGIT+ (('.' HEX_DIGIT+)+  /  '-' HEX_DIGIT+)?
ProseValue   <-   '<' (!'>' .)* '>'
ID   <-   LETTER (LETTER  /  DIGIT  /  '-')*
INT   <-   [0-9]+
COMMENT   <-   ';' (!('\n'  /  '\r') .)* '\r'? '\n'
WS   <-   ' '  /  '\t'  /  '\r'  /  '\n'
STRING   <-   ('%s'  /  '%i')? '"' (!'"' .)* '"'
LETTER   <-   [a-z]  /  [A-Z]
BIT   <-   [0-1]
DIGIT   <-   [0-9]
HEX_DIGIT   <-   [0-9]  /  [a-f]  /  [A-F]
EOF <- !.
ZLex_001 <- '='
ZLex_002 <- '/'
ZLex_003 <- '*'
ZLex_004 <- '('
ZLex_005 <- ')'
ZLex_006 <- '['
ZLex_007 <- ']'
__rep_001       <-  repetition __rep_001  /  repetition &(')'  /  '/'  /  ']'  /  EOF  /  ID)
__IdBegin <- LETTER
__IdRest <- LETTER  /  DIGIT  /  '-'
]]
	checkConversionToPeg(g, peg, {prefix = true, reserved = true, idRule = 'ID'})

    end)
end)
