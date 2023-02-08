local Parser = require"parser"
local Coder = require"coder"
local Pretty = require'pretty'

describe("Testing #parser and #coder handling escape sequences", function()

  test("Grammar with special chars \n, \t, \r \"", function()

    local g = Parser.match[[
      S  <- ID X Y / '\"' / '\\"'
      ID <- 'a' '\n' 'b'
      X  <- '\t'
      Y  <- '\r'
    ]]

    assert(g)

    local lpegParser = Coder.makeg(g)
    s = "a\nb\t\r"
    assert.equal(lpegParser:match(s), #s + 1)
    s = '\"'
    assert.equal(lpegParser:match(s), #s + 1)
    s = '\\"'
    assert.equal(lpegParser:match(s), #s + 1)
  end)

  
	test("Escape sequence '\t' in a char set", function()

    local g = Parser.match[[
      S  <- [\t]
    ]]

    assert(g)

    local lpegParser = Coder.makeg(g)
    s = "\t"
  end)
  
  test("Several #escape sequences in char set", function()

    local g = Parser.match[[
      S  <- ID X Y / [\"] / [\'] / [\\][\"] / [\\]
      ID <- 'a' [\n] 'b'
      X  <- [\t]
      Y  <- [\r]
    ]]

    assert(g)

    local lpegParser = Coder.makeg(g)
    s = "a\nb\t\r"
    assert.equal(lpegParser:match(s), #s + 1)
    s = '\"'
    assert.equal(lpegParser:match(s), #s + 1)
    s = '\\'
    assert.equal(lpegParser:match(s), #s + 1)
		s = '"'
    assert.equal(lpegParser:match(s), #s + 1)
		s = '"'
    assert.equal(lpegParser:match(s), #s + 1)
    s = '\\"'
    assert.equal(lpegParser:match(s), #s + 1)
  end)

  test("Grammar with comments", function()

    local g = Parser.match[[
      s  <- ('a' / 'b' / 'c')*
      COMMENT <- ';' (!'\n' .)* '\n'
    ]]

    assert(g)
  end)
  
end)
