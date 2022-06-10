local Parser = require"parser"
local Coder = require"coder"
local Pretty = require'pretty'

describe("Testing #abnfparser", function()	

    test("Example  based on ABNF Grammar", function()
        local g = Parser.match[[
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
__rep_001       <-  repetition __rep_001  /  repetition &(')'  /  '/'  /  ']'  /  EOF  /  ID)
__IdBegin <- LETTER
__IdRest <- LETTER  /  DIGIT  /  '-'
ZLex_001 <- '='
ZLex_002 <- '/'
ZLex_003 <- '*'
ZLex_004 <- '('
ZLex_005 <- ')'
ZLex_006 <- '['
ZLex_007 <- ']'
]]

		assert(g)
		local pretty = Pretty.new()
		print(pretty:printg(g, nil, true))

		local lpegParser = Coder.makeg(g)
		
		-- From grammarinator/tests_04/test_2878153605691131279435791100517606654.abnf
		-- Original input has invalid ProseValue '<>>'
        -- Changed it to '<>'
        local originalInput = [[
p-8k = * 464  %b10.01   [ v    / %b1   "ప﶐"   <>    / "῿"   9  i316A   ( <>   72 * 0  O    / 3 * 177  [ 0  %s"🃀"   9 * 9  %i"൅ව𞸩₏ⴭ"   %i"𝉆"     ]    *  ( *  [ 63  <฻>    / ( *  %i"﹓"   ( AG   *  ( %xc-AC     )      )     / 1  <>   ( * 42  "ಎ𞹬ໆ"   %s""    / %x0d-D   <𑍝>    / *  s6O   [ *  ( 40  %xb.C    / * 8000  %i""     )      ]    59  %i""     )    * 82  <>   S    / [ 5  ""     ]    %i""   7117  u-     )    94  ""   21  ( %x2F-A6eeD7     )    %b0-010     ]      )    08 *  %d1.5   ( 31  <>    / 5  g   ( 84  %b10.000110.0     )      )    <>   [ 5915017  <ጘ>     ]    4  <>   %i""   0  [ * 0  <>     ]    4  [ *  %i""   8  %d1    / *  <>   <¡>   * 501  %s""   79  fb-6l-i   %s"🥀"     ]    %b111010    / %i""   <>    / 761  %xf    / H    / nX   %xb4-f     )      ]    <⭶>       f = *  [ 1  [ ( ( 4917  [ 83426 * 3  %xd-db1    / 7  <ጘ኱𝍠￼𐘀🜀𐭳>    / *  %i"𝕇"    / 059 *  %x9.A3   *  ( 2311  <ኸ>   * 92  %d1.29   ( %s"ꭰ౤"     )     / %d1    / [ A   52  ""   1 * 627  %b1-11     ]      )    %xA   ""    / %xF.D   0 * 8140  <𒑯𐦼𑜬>    / 42  ""   <𐠊𐨌𓐯>     ]    %b001111.00     )      )      ]      ]    ( ( 741  d27    / 5  %d9.16.5.6350     )    *  %x6d89-D   <>>     )     / Ge   <꥽⿼>   2  ""       L = / <>   8  %b11    / L-    / * 9  [ "！꓇"   [ %b1.0    / %b10     ]      ]    04426 * 2  ( u93-   <ₐ>   oLT    / %i""   71 * 2  ""   7088  f   4  ( 1402  h7-k18-    / *  [ <প𑍅>     ]      )     / [ "𞹃﹔꩜🢈𑋰఍ኸ𑊪𞻲𐕤Ὓ"   160 *  %b0-00110   jJ--J     ]      )    7 *  %xf2.c3   <>   113 *  ""
]]
        local r, lab, errpos = lpegParser:match(originalInput)
        print(r, lab, errpos)
        assert.equal(lpegParser:match(originalInput), nil)

        local smallInput = [[ p-8k =    <>> ]]
        local r, lab, errpos = lpegParser:match(smallInput)
        print(r, lab, errpos)
        assert.equal(lpegParser:match(smallInput), nil)
        
        local fixed = [[ p-8k =    <> ]]
        local r, lab, errpos = lpegParser:match(fixed)
        print(r, lab, errpos)
        assert.equal(lpegParser:match(fixed), #fixed + 1)

    end)


end)
