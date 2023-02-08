local Parser = require'parser'
local Node = require"node"

describe("Testing #parser", function()
	
  test("Testing a grammar with all the expressions (not including captures)", function()
    local s = [[ d <- [0-9a-z] ]]

    local g, msg = Parser.match(s)

    assert.not_nil(g)

    local ruleMap = {
      d = Node.set{"0-9", "a-z"},
    }

    assert.same(g:getRules(), ruleMap)
    assert.same(g:getVars(), {"d"})

    -- adds the string literals and the lexical rules to the set of tokens
    -- does not add symbols in the right-hand side of a lexical rule to set list of tokens
    assert.same(g:getTokens(), {})

    assert.same(g:getStartRule(), "d")
  end) 
end)
