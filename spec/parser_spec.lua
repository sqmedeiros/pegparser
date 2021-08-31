local Parser = require'parser'
local ErrMsg = require'syntax_errors'
local Node = require"node"


local function assertlab (g, lab)
  local r, msg, pos = Parser.match(g)
  local errMsg = ErrMsg[lab]
  assert.is_not_nil(errMsg, "InvalidLabel '" .. lab .. "'")
  assert.is_nil(r)
  assert.True(string.find(msg, errMsg, 1, true) ~= nil, "Expected label '" .. lab .. "'")
end


describe("Testing #parser", function()

  test("Grammar with syntax errors: checking the error label", function()

    assertlab([[a <- 'b'  3 ]], 'Extra')

    assertlab([[]], 'Rule')

    assertlab([[a <- ]], 'ExpRule')

    assertlab([[a ]], 'Arrow')

    assertlab([[a <- 'b' / 3]], 'SeqExp')

    assertlab([[a <- 'b'& ]], 'AndPred')

    assertlab([[a <- ! ]], 'NotPred')

    assertlab([[a <- () ]], 'ExpPri')

    assertlab([[a <- ( 'b' ]], 'RParPri')

    assertlab([[a <- ( 'b" ]], 'SingQuote')

    assertlab([[a <- ( "b' ]], 'DoubQuote')

    assertlab([[a <- []], 'EmptyClass')

    assertlab([[a <- [a-z]], 'RBraClass')

    assertlab([[a <- %{ } ]], 'NameThrow')

    assertlab([[a <- %{ ops ]], 'RCurThrow')
  end)


  test("Grammar with undefined nonterminal", function()

    local r, msg = pcall(Parser.match, [[a <- 'a' b]])

    assert(not r and string.find(msg, "'b' was not defined", 1, true))
  end)


  test("Testing a Simple Valid Grammar", function()
    local s = [[a <- 'a' b / C
                b <- 'b'*
                C <- 'c']]

    local g, msg = Parser.match(s)

    assert.not_nil(g)

    local ruleMap = {
      a = Node.choice(Node.con(Node.char"'a'", Node.var"b"), Node.var"C"),
      b = Node.star(Node.char"'b'"),
      C = Node.char"'c'"
    }

    assert.same(g:getRules(), ruleMap)
    assert.same(g:getVars(), { "a", "b", "C" })

    -- adds the string literals and the lexical rules to the set of tokens
    -- does not add symbols in the right-hand side of a lexical rule to set list of tokens
    assert.same(g:getTokens(), { ["'a'"] = true, ["'b'"] = true, C = true })

    assert.same(g:getStartRule(), "a")
  end)


  test("Testing the use of a nonterminal in lexical and syntactical rules", function()
    local s = [[x <- 'a' B / 'c'
                B <- x / 'd'
                C <- B]]

    local g, msg = Parser.match(s)

     assert.not_nil(g)

     local ruleMap = {
      x = Node.choice(Node.con(Node.char"'a'", Node.var"B"), Node.char"'c'"),
      B = Node.choice(Node.var"x", Node.char"'d'"),
      C = Node.var"B"
    }

    assert.same(g:getRules(), ruleMap)
    assert.same(g:getVars(), { "x", "B", "C" })

    -- adds the string literals and the lexical rules to the set of tokens
    -- does not add symbols in the right-hand side of a lexical rule to set list of tokens
    assert.same(g:getTokens(), { ["'a'"] = true, B = true, ["'c'"] = true, C = true })

    assert.same(g:getStartRule(), "x")
  end)


  test("Testing a grammar with all the expressions (not including captures)", function()
    local s = [[ x <- '' B / !.
                 B <- C? 'c'*
                 C <- ('d' %{foo})+
                 d <- &[0-9a-z] .
                 e <- 'a'^bola]]

    local g, msg = Parser.match(s)

     assert.not_nil(g)

     local ruleMap = {
      x = Node.choice(Node.con(Node.empty(), Node.var"B"), Node.nott(Node.any())),
      B = Node.con(Node.opt(Node.var"C"), Node.star(Node.char"'c'")),
      C = Node.plus(Node.con(Node.char"'d'", Node.throw"foo")),
      d = Node.con(Node.andd(Node.set("0-9", "a-z")), Node.any()),
      e = Node.choice(Node.char"'a'", Node.throw"bola")
    }

    assert.same(g:getRules(), ruleMap)
    assert.same(g:getVars(), { "x", "B", "C", "d", "e" })

    -- adds the string literals and the lexical rules to the set of tokens
    -- does not add symbols in the right-hand side of a lexical rule to set list of tokens
    assert.same(g:getTokens(), { B = true, C = true, ["'a'"] = true,  })

    assert.same(g:getStartRule(), "x")
  end)


--]==]

--[==[

local r, l, pos =  m.match[[a <- 'b' / 'c'  d <- 'a'^bola]]
print(pretty.printg(r, l))

local r, l, pos =  m.match[[a <- 'bc' 'd' 'c' [a-zA-Z0-9_] ]]
print(pretty.printg(r, l))


local r, l, pos = m.match([[a <- 'b' ('c' / 'd') / 'e']])
print(pretty.printg(r, l))

local r, l, pos = m.match([[new <- 'x' ('c' / 'd') / 'e' %{Nada}]])
print(pretty.printg(r, l))

local r, l, pos = m.match([[
Start <- X ('c' / 'd') / 'e' %{Nada}
X     <- &'a' !'b' {.} {} {| [a-z]* |} Z
Z     <- 'a'? 'b'* 'c'+]])
print(pretty.printg(r, l))
]==]

end)
