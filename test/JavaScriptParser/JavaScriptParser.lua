local m = require 'pegparser/parser'
local coder = require 'pegparser/coder'
local util = require'pegparser/util'
local lfs = require'lfs'

local parser = [[
    parser                      <-      statement EOF
    statement                   <-      (block / variableStatement / importStatement / exportStatement / emptyStatement / 
                                        classDeclaration / expressionStatement / ifStatement / iterationStatement /
                                        continueStatement / breakStatment / returnStatement / yieldStatement / withStatement /
                                        labelledStatement / switchStatement / throwStatement / tryStatement / debuggerStatement /
                                        functionDeclaration / generatorFunctionDeclaration)
    block                       <-      '{' statementList? '}'
    statementList               <-      statement
    variableStatement           <-      varModifier variableDeclarationList eos
    varModifier                 <-      Var / Let / Const
    variableDeclarationList     <-      variableDeclaration (',' variableDeclaration)*
    variableDeclaration         <-      (Identifier / arrayLiteral) ('=' singleExpression)?
    arrayLiteral                <-      ('[' elementList? ']')
    elementList                 <-      singleExpression (','+ singleExpression)* (','+ lastElement)?  /  lastElement
    singleExpression            <-      simpleSingleExpression/
                                        recursiveSingleExpression
    simpleSingleExpression      <-      '(' expressionSequence ')' /
                                        Function Identifier? '(' formalParameterList? ')' '{' functionBody '}' /
                                        Class Identifier? classTail /
                                        iteratorBlock /
                                        generatorBlock /
                                        generatorFunctionDeclaration / 
                                        yieldStatement /
                                        This /
                                        Identifier / 
                                        Super / 
                                        literal /
                                        arrayLiteral / 
                                        objectLiteral / 
                                        '(' expressionSequence ')' /
                                        arrowFunctionParameters '=>' arrowFunctionBody
    recursiveSingleExpression   <-      simpleSingleExpression '[' expressionSequence ']' /
                                        simpleSingleExpression '++' /
                                        simpleSingleExpression '--' /
                                        Delete singleExpression /
                                        Void singleExpression /
                                        Typeof singleExpression /
                                        '++' singleExpression /
                                        '--' singleExpression /
                                        '+' singleExpression /
                                        '-' singleExpression /
                                        '~' singleExpression /
                                        '!' singleExpression /
                                        simpleSingleExpression ('*' / '/' / '%') singleExpression /
                                        simpleSingleExpression ('+' / '-') singleExpression /
                                        simpleSingleExpression ('<<' / '>>' / '>>>') singleExpression /
                                        simpleSingleExpression ('<' / '>' / '<=' / '>=') singleExpression /
                                        simpleSingleExpression Instanceof singleExpression /
                                        simpleSingleExpression In singleExpression /
                                        simpleSingleExpression ('==' / '!=' / '===' / '!==') singleExpression /
                                        simpleSingleExpression '&' singleExpression /                   
                                        simpleSingleExpression '^' singleExpression /                                
                                        simpleSingleExpression '|' singleExpression /                                 
                                        simpleSingleExpression '&&' singleExpression /                                
                                        simpleSingleExpression '||' singleExpression /                                
                                        simpleSingleExpression '?' singleExpression ':' singleExpression /          
                                        simpleSingleExpression '=' singleExpression
    literal                     <-      NullLiteral / 
                                        BooleanLiteral /
                                        numericLiteral
    numericLiteral              <-      DecimalLiteral
    lastElement                 <-      Ellipsis (Identifier / singleExpression)
    eos                         <-      SemiColon / '}' / EOF
    importStatement             <-      Import fromBlock
    fromBlock                   <-      (Multiply / multipleImportStatement) (As identifierName)? From StringlLiteral eos
    multipleImportStatement     <-      (identifierName ',')? '{' identifierName (',' identifierName)* '}'
    identifierName              <-      Identifier / reservedWord
    reservedWord                <-      keyword / NullLiteral / BooleanLiteral
    keyword                     <-      Break / Do / Instanceof / Typeof / Case / Else / New / Var / Catch / Finally /
                                        Return / Void / Continue / For / Switch / While / Debugger / Function / This /
                                        With /  Default / If / Throw / Delete / In / Try / Class / Enum / Extends /
                                        Super / Const / Export / Import / Implements / Let / Private / Public / 
                                        Interface / Package / Protected / Static / Yield
    exportStatement             <-      Export Default? (fromBlock / statement)
    emptyStatement              <-      SemiColon   
    classDeclaration            <-      Class Identifier classTail
    classTail                   <-      (Extends singleExpression)? '{' classElement* '}'
    classElement                <-      (Static / Identifier)? methodDefinition / emptyStatement
    methodDefinition            <-      propertyName '(' formalParameterList? ')' '{' functionBody '}' /
                                        getter '(' ')' '{' functionBody '}' /
                                        setter '(' formalParameterList? ')' '{' functionBody '}' /
                                        generatorMethod
    propertyName                <-      identifierName / StringlLiteral / numericLiteral
    formalParameterList         <-      formalParameterArg (',' formalParameterArg)* (',' lastFormalParameterArg)? /
                                        lastFormalParameterArg /
                                        arrayLiteral /
                                        objectLiteral
    formalParameterArg          <-      Identifier ('=' singleExpression)?
    lastFormalParameterArg      <-      Ellipsis Identifier
    objectLiteral               <-      '{' (propertyAssignment (',' propertyAssignment)*)? ','? '}'
    propertyAssignment          <-      propertyName (':' / '=') singleExpression /
                                        '[' singleExpression ']' ':' singleExpression /
                                        getter '(' ')' '{' functionBody '}' /
                                        setter '(' Identifier ')' '{' functionBody '}' /
                                        generatorMethod /
                                        Identifier
    functionBody                <-      sourceElements? 
    sourceElements              <-      sourceElement
    sourceElement               <-      Export? statement
    getter                      <-      Identifier 'get'& propertyName
    setter                      <-      Identifier 'set'& propertyName
    generatorMethod             <-      '*'? Identifier '(' formalParameterList? ')' '{' functionBody '}'
    expressionStatement         <-      !('{' / Function)& expressionSequence eos
    Function                    <-      'function'
    expressionSequence          <-      singleExpression (',' singleExpression)*
    ifStatement                 <-      If '(' expressionSequence ')' statement (Else statement)?
    iterationStatement          <-      Do statement While '(' expressionSequence ')' eos /
                                        While '(' expressionSequence ')' statement /
                                        For '(' expressionSequence? SemiColon expressionSequence? SemiColon expressionSequence? ')' statement /
                                        For '(' varModifier variableDeclarationList SemiColon expressionSequence? SemiColon expressionSequence? ')' statement
    continueStatement               <-      Continue Identifier? eos
    breakStatment                   <-      Break Identifier? eos
    returnStatement                 <-      Return expressionSequence? eos 
    yieldStatement                  <-      Yield expressionSequence? eos
    withStatement                   <-      With '(' expressionSequence ')' statement
    labelledStatement               <-      Identifier ':' statement
    switchStatement                 <-      Switch '(' expressionSequence ')' caseBlock
    caseBlock                       <-      '{' caseClauses? (defaultClause caseClauses?)? '}'
    caseClauses                     <-      caseClause+
    caseClause                      <-      Case expressionSequence ':' statementList?
    defaultClause                   <-      Default ':' statementList?
    throwStatement                  <-      Throw expressionSequence eos
    tryStatement                    <-      Try block (cathProduction finallyProduction? / finallyProduction)
    cathProduction                  <-      Catch '(' Identifier ')' block
    finallyProduction               <-      Finally block
    debuggerStatement               <-      Debugger eos
    functionDeclaration             <-      Function Identifier '(' formalParameterList? ')' '{' functionBody '}'
    generatorFunctionDeclaration    <-      Function '*' Identifier? '(' formalParameterList? ')' '{' functionBody '}'
    iteratorBlock                   <-      '{' (iteratorDefinition (',' iteratorDefinition)*)? ','? '}'
    iteratorDefinition              <-      '[' singleExpression ']' '(' formalParameterList? ')' '{' functionBody '}'
    generatorBlock                  <-      '{' (generatorDefinition (',' generatorDefinition)*)? ','? '}'
    generatorDefinition             <-      '*' iteratorDefinition
    arrowFunctionParameters         <-      Identifier / '(' formalParameterList? ')'
    arrowFunctionBody               <-      singleExpression /  '{' functionBody '}'


--Lexer
    
    NullLiteral                 <-      'null'
    BooleanLiteral              <-      'true' / 'false'
    DecimalLiteral              <-      DecimalIntegerLiteral ('.' [0-9]*)?
    DecimalIntegerLiteral       <-      '0' / [1-9] [0-9]*
    StringlLiteral              <-      'StringlLiteral'?
    SemiColon                   <-      ';'
    EOF                         <-      !.
    Identifier                  <-      [a-zA-Z][a-zA-z0-9]*
    Int                         <-      [0-9]+
    Multiply                    <-      '*'
    Ellipsis                    <-      '...'


--keywords

    Break                       <-      'break'
    Do                          <-      'do'
    Instanceof                  <-      'instanceof'
    Typeof                      <-      'typeof'
    Case                        <-      'case'
    Else                        <-      'else'
    New                         <-      'new'
    Var                         <-      'var'
    Catch                       <-      'catch'
    Finally                     <-      'finally'
    Return                      <-      'return'
    Void                        <-      'void'
    Continue                    <-      'continue'
    For                         <-      'for'
    Switch                      <-      'switch'
    While                       <-      'while'
    Debugger                    <-      'debugger'
    Function                    <-      'function'
    This                        <-      'this'
    With                        <-      'with'
    Default                     <-      'default'
    If                          <-      'if'
    Throw                       <-      'throw'
    Delete                      <-      'delete'
    In                          <-      'in'
    Try                         <-      'try'
    As                          <-      'as'
    From                        <-      'from'
    Class                       <-      'class'
    Enum                        <-      'enum'
    Extends                     <-      'extends'
    Super                       <-      'super'
    Const                       <-      'const'
    Export                      <-      'export'
    Import                      <-      'import'
    Implements                  <-      'implements' 
    Let                         <-      'let' 
    Private                     <-      'private' 
    Public                      <-      'public' 
    Interface                   <-      'interface' 
    Package                     <-      'package' 
    Protected                   <-      'protected' 
    Static                      <-      'static' 
    Yield                       <-      'yield' 

]]  


g, lab, pos = m.match(parser)
print(g, lab, pos)

--gerar o parser
local p = coder.makeg(g)        

local dir = lfs.currentdir() .. '/test/JavaScriptParser/yes/'
util.testYes(dir, 'js', p)

dir = lfs.currentdir() .. '/no/'
util.testNo(dir, 'js', p)
