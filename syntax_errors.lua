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
  ExpTabCap = "expected an expression after '{|'",
  RCurTabCap = "expected '|}' to close table capture",
  RCurCap = "expected '}' to close capture",
  SingQuote = [[expected "'" to close string]],
  DoubQuote = [[expected '"' to close string]],
  EmptyClass = [[a character class can not be empty]],
  RBraClass = "expected ']' to close character class",
  NameThrow = "expected a name after '%{'",
  RCurThrow = "expected '}' to close throw expression",
}

return errinfo
