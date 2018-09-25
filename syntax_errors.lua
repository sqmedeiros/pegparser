local errinfo = {
  Extra = "unexpected characters after grammar definition",
  ExpRule = "expected an expression after '<-'",
  Rule = "grammar must have at least one rule",
  Arrow = "expected '<-' after rule's name",
  SeqExp = "expected an expression after '/'",
  AndPred = "expected an expression after '&'",
  NotPred = "expected an expression after '!'",
  ExpPri = "expected an expression after '('",
  RParPri = "expected ')'",
  SingQuote = [[expected "'" to close string]],
  DoubQuote = [[expected '"' to close string]],
  RBraClass = "expected ']' to close character class",
  NameThrow = "expected a name after '%{'",
  RCurlyThrow = "expected '}' to close throw expression",
}

return errinfo
