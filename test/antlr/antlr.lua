local m = require 'pegparser.parser'
local pretty = require 'pegparser.pretty'
local coder = require 'pegparser.coder'
local recovery = require 'pegparser.recovery'
local ast = require'pegparser.ast'
local util = require'pegparser.util'

local s = [[
grammarSpec <- grammarDecl prequelConstruct* rules modeSpec* EOF

grammarDecl <- grammarType identifier SEMI

grammarType <- (LEXER GRAMMAR / PARSER GRAMMAR / GRAMMAR)
   
prequelConstruct <- optionsSpec / delegateGrammars / tokensSpec / channelsSpec / action_
   
optionsSpec <- OPTIONS LBRACE (option SEMI)* RBRACE

option <- identifier ASSIGN optionValue

optionValue <- identifier (DOT identifier)* / STRING_LITERAL / actionBlock / INT
   
delegateGrammars <- IMPORT delegateGrammar (COMMA delegateGrammar)* SEMI

delegateGrammar <- identifier ASSIGN identifier / identifier
   
tokensSpec <- TOKENS LBRACE idList? RBRACE

channelsSpec <- CHANNELS LBRACE idList? RBRACE

idList <- identifier (COMMA identifier)* COMMA?
   
action_ <- AT (actionScopeName COLONCOLON)? identifier actionBlock

actionScopeName <- identifier / LEXER / PARSER
   
actionBlock <- BEGIN_ACTION ACTION_CONTENT* END_ACTION

argActionBlock <- BEGIN_ARGUMENT ARGUMENT_CONTENT* END_ARGUMENT

modeSpec <- MODE identifier SEMI lexerRuleSpec*

rules <- ruleSpec*

ruleSpec <- parserRuleSpec / lexerRuleSpec

parserRuleSpec <- ruleModifiers? RULE_REF argActionBlock? ruleReturns? throwsSpec? localsSpec? rulePrequel* COLON ruleBlock SEMI exceptionGroup
   
exceptionGroup <- exceptionHandler* finallyClause?

exceptionHandler <- CATCH argActionBlock actionBlock

finallyClause <- FINALLY actionBlock

rulePrequel <- optionsSpec / ruleAction

ruleReturns <- RETURNS argActionBlock

throwsSpec <- THROWS identifier (COMMA identifier)*
   
localsSpec <- LOCALS argActionBlock

ruleAction <- AT identifier actionBlock
   
ruleModifiers <- ruleModifier+

ruleModifier <- PUBLIC / PRIVATE / PROTECTED / FRAGMENT
   
ruleBlock <- ruleAltList
   
ruleAltList <- labeledAlt (OR labeledAlt)*
   
labeledAlt <- alternative (POUND identifier)?
   
lexerRuleSpec <- FRAGMENT? TOKEN_REF COLON lexerRuleBlock SEMI
   
lexerRuleBlock <- lexerAltList
   
lexerAltList <- lexerAlt (OR lexerAlt)*
   
lexerAlt <- lexerElements lexerCommands?  /  ''

lexerElements <- lexerElement+
   
lexerElement <- labeledLexerElement ebnfSuffix?
   / lexerAtom ebnfSuffix?
   / lexerBlock ebnfSuffix?
   / actionBlock QUESTION?
   
labeledLexerElement <- identifier (ASSIGN / PLUS_ASSIGN) (lexerAtom / lexerBlock)
   
lexerBlock <- LPAREN lexerAltList RPAREN
   
lexerCommands <- RARROW lexerCommand (COMMA lexerCommand)*

lexerCommand <- lexerCommandName LPAREN lexerCommandExpr RPAREN / lexerCommandName
   
lexerCommandName <- identifier / MODE
   
lexerCommandExpr <- identifier / INT
   
altList <- alternative (OR alternative)*

alternative <- elementOptions? element+ / ''

element
  <- labeledElement (ebnfSuffix / '')
   / atom (ebnfSuffix / '')
   / ebnf
   / actionBlock QUESTION?

labeledElement <- identifier (ASSIGN / PLUS_ASSIGN) (atom / block)
   
ebnf <- block blockSuffix?
 
blockSuffix <- ebnfSuffix
 
ebnfSuffix <- QUESTION QUESTION? / STAR QUESTION? / PLUS QUESTION?
  
lexerAtom <- characterRange / terminal / notSet / LEXER_CHAR_SET / DOT elementOptions?
   
atom <- terminal / ruleref / notSet / DOT elementOptions?
   
notSet <- NOT setElement / NOT blockSet
   
blockSet <- LPAREN setElement (OR setElement)* RPAREN
   
setElement
  <- TOKEN_REF elementOptions?
   / STRING_LITERAL elementOptions?
   / characterRange
   / LEXER_CHAR_SET

block <- LPAREN (optionsSpec? ruleAction* COLON)? altList RPAREN
   
ruleref <- RULE_REF argActionBlock? elementOptions?
   
characterRange <- STRING_LITERAL RANGE STRING_LITERAL
  
terminal <- TOKEN_REF elementOptions? / STRING_LITERAL elementOptions?

elementOptions <- LT elementOption (COMMA elementOption)* GT

elementOption <- identifier / identifier ASSIGN (identifier / STRING_LITERAL)

-- New: criei as regras RULE_REF e TOKEN_REF   
RULE_REF <- [a-z] NameChar*

TOKEN_REF <- [A-Z] NameChar*

   
identifier <- RULE_REF / TOKEN_REF

-- Change: Added EOF
EOF <- !.

-- LexBasic.g4

Ws <- Hws / Vws
   
Hws <- [ \t]
   
Vws <- [\r\n\f]

BlockComment <- '/*' .*? ('*/' / EOF)
   
DocComment <- '/**' .*? ('*/' / EOF)

LineComment <- '//' (![\r\n] .)*

EscSeq <- Esc ([btnfr"'\\] / UnicodeEsc / . / EOF)

EscAny <- Esc .

UnicodeEsc <- 'u' (HexDigit (HexDigit (HexDigit HexDigit?)?)?)?
   
DecimalNumeral <- '0' / [1-9] DecDigit*
   
HexDigit <- [0-9a-fA-F]
   
DecDigit <- [0-9]
   
BoolLiteral <- 'true' / 'false'

CharLiteral <- SQuote (EscSeq / (!['\r\n\\] .)) SQuote
   
SQuoteLiteral <- SQuote (EscSeq / (!['\r\n\\] .))* SQuote

DQuoteLiteral <- DQuote (EscSeq / (!["\r\n\\] .))* DQuote

USQuoteLiteral <- SQuote (EscSeq / (!['\r\n\\] .))*
   
NameChar <- NameStartChar / [0-9] / Underscore / '\u00B7' / '\u0300' .. '\u036F' / '\u203F' .. '\u2040'
   

NameStartChar
  <- [A-Z]
   / [a-z]
   / '\u00C0' .. '\u00D6'
   / '\u00D8' .. '\u00F6'
   / '\u00F8' .. '\u02FF'
   / '\u0370' .. '\u037D'
   / '\u037F' .. '\u1FFF'
   / '\u200C' .. '\u200D'
   / '\u2070' .. '\u218F'
   / '\u2C00' .. '\u2FEF'
   / '\u3001' .. '\uD7FF'
   / '\uF900' .. '\uFDCF'
   / '\uFDF0' .. '\uFFFD'
   
Int <- 'int'
   
Esc <- '\\'

Colon <- ':'

DColon <- '::'
   
--SQuote <- '\''
SQuote <- "'"   
   
DQuote <- '"'
   
LParen <- '('
   
RParen <- ')'
   
LBrace <- '{'
   
RBrace <- '}'
   
LBrack <- '['

RBrack <- ']'

RArrow <- '->'
   
Lt <- '<'

Gt <- '>'

Equal <- '='

Question <- '?'

Star <- '*'
   
Plus <- '+'

PlusAssign <- '+='

Underscore <- '_'

Pipe <- '|'

Dollar <- '$'

Comma <- ','
   
Semi <- ';'

Dot <- '.'

Range <- '..'

At <- '@'

Pound <- '#'
   
Tilde <- '~'

-- ANTLRv4Lexer

DOC_COMMENT <- DocComment 
   
BLOCK_COMMENT <- BlockComment

LINE_COMMENT <- LineComment 
   
INT <- DecimalNumeral
   
STRING_LITERAL <- SQuoteLiteral
   
UNTERMINATED_STRING_LITERAL <- USQuoteLiteral
   
BEGIN_ARGUMENT <- LBrack
  
BEGIN_ACTION <- LBrace 
   
OPTIONS <- 'options'
   
TOKENS <- 'tokens'

CHANNELS <- 'channels'

IMPORT <- 'import'
   
FRAGMENT <- 'fragment'

LEXER <- 'lexer'

PARSER <- 'parser'

GRAMMAR <- 'grammar'

PROTECTED <- 'protected'

PUBLIC <- 'public'

PRIVATE <- 'private'

RETURNS <- 'returns'

LOCALS <- 'locals'

THROWS <- 'throws'

CATCH <- 'catch'

FINALLY <- 'finally'

MODE <- 'mode'
   
COLON <- Colon

COLONCOLON <- DColon

COMMA <- Comma

SEMI <- Semi

LPAREN <- LParen

RPAREN <- RParen

LBRACE <- LBrace

RBRACE <- RBrace

RARROW <- RArrow

LT <- Lt

GT <- Gt

ASSIGN <- Equal

QUESTION <- Question

STAR <- Star

PLUS_ASSIGN <- PlusAssign

PLUS <- Plus

OR <- Pipe

DOLLAR <- Dollar

RANGE <- Range

DOT <- Dot

AT <- At

POUND <- Pound

NOT <- Tilde

ID <- Id
   
WS <- Ws+ 

ERRCHAR <- .

-- Erased Lexer modes and Target Language Actions


--mode Argument;
NESTED_ARGUMENT <- LBrack 

ARGUMENT_ESCAPE <- EscAny

ARGUMENT_STRING_LITERAL <- DQuoteLiteral

ARGUMENT_CHAR_LITERAL <- SQuoteLiteral 

END_ARGUMENT <- RBrack

UNTERMINATED_ARGUMENT <- EOF

ARGUMENT_CONTENT <- .
   
--mode TargetLanguageAction;
NESTED_ACTION <- LBrace

ACTION_ESCAPE <- EscAny

ACTION_STRING_LITERAL <- DQuoteLiteral

ACTION_CHAR_LITERAL <- SQuoteLiteral

ACTION_DOC_COMMENT <- DocComment

ACTION_BLOCK_COMMENT <- BlockComment

ACTION_LINE_COMMENT <- LineComment

END_ACTION <- RBrace

UNTERMINATED_ACTION <- EOF

ACTION_CONTENT <- .
   
--mode Options;
OPT_DOC_COMMENT <- DocComment

OPT_BLOCK_COMMENT <- BlockComment

OPT_LINE_COMMENT <- LineComment

OPT_LBRACE <- LBrace
   
OPT_RBRACE <- RBrace

OPT_ID <- Id

OPT_DOT <- Dot

OPT_ASSIGN <- Equal

OPT_STRING_LITERAL <- SQuoteLiteral

OPT_INT <- DecimalNumeral

OPT_STAR <- Star

OPT_SEMI <- Semi

OPT_WS <- Ws+ 

--mode Tokens;
TOK_DOC_COMMENT <- DocComment

TOK_BLOCK_COMMENT <- BlockComment

TOK_LINE_COMMENT <- LineComment

TOK_LBRACE <- LBrace

TOK_RBRACE <- RBrace

TOK_ID <- Id

TOK_DOT <- Dot

TOK_COMMA <- Comma

TOK_WS <- Ws+ 


--mode Channels;
CHN_DOC_COMMENT <- DocComment

CHN_BLOCK_COMMENT <- BlockComment

CHN_LINE_COMMENT <- LineComment

CHN_LBRACE <- LBrace

CHN_RBRACE <- RBrace

CHN_ID <- Id

CHN_DOT <- Dot

CHN_COMMA <- Comma

CHN_WS <- Ws+ 

--mode LexerCharSet;
--LEXER_CHAR_SET_BODY <- (!([\]\\] .) / EscAny)+ 

--LEXER_CHAR_SET <- RBrack
LEXER_CHAR_SET <- LBrack (!']' .)* ']'

UNTERMINATED_CHAR_SET <- EOF

Id <- NameStartChar NameChar*
]]

print("Unique Path (UPath)")
g = m.match(s)
print(m.match(s))


local gupath = recovery.putlabels(g, 'upath', false)
print(pretty.printg(gupath, true), '\n')
--print(pretty.printg(gupath, true, 'unique'), '\n')
--print(pretty.printg(gupath, true, 'uniqueEq'), '\n')
pretty.printToFile(g, nil, 'g4', 'rec')

print("End UPath\n")


g = m.match(s)
local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0])

util.testYes(dir .. '/yes/', 'g4', p)

--util.testNo(dir .. '/test/no/', 'titan', p)

--util.testNoRecDist(dir .. '/test/no/', 'titan', p)

   
