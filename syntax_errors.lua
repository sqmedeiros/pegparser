local errinfo = {
  Extra = "unexpected characters after grammar definition",
  ExpRule = "expected a pattern after '<-'",
  Rule = "grammar must have at least one rule",
  Arrow = "expected '<-' after rule's name",
  SeqExp = "expected a pattern after '/'",
  AndPred = "expected a pattern after '&'",
  NotPred = "expected a pattern after '!'",
}

return errinfo
