local m = require 'pegparser.parser'
local coder = require 'pegparser.coder'
local util = require'pegparser.util'

local parser = [[
    
    parser                      <-      statement


-- STATEMENTS

    statement                   <-      labeledStatement 

    labeledStatement            <-      Identifier COLON statement / 
                                        CASE ConstantExpression COLON statement /
                                        DEFAULT COLON statement

    Identifier                  <-      !Keyword IdNondigit IdChar*

    ConstantExpression          <-      ConditionalExpression

    ConditionalExpression       <-      LogicalORExpression (QUERY Expression COLON LogicalORExpression)*

    LogicalORExpression         <-      LogicalANDExpression (OROR LogicalANDExpression)*

    LogicalANDExpression        <-      InclusiveORExpression (ANDAND InclusiveORExpression)*

    InclusiveORExpression       <-      ExclusiveORExpression (OR ExclusiveORExpression)*

    ExclusiveORExpression       <-      ANDExpression (HAT ANDExpression)*

    ANDExpression               <-      EqualityExpression (AND EqualityExpression)*

    EqualityExpression          <-      RelationalExpression ((EQUEQU / BANGEQU) RelationalExpression)*

    RelationalExpression        <-      ShiftExpression ((LE / GE / LT / GT) ShiftExpression)*

    ShiftExpression             <-      AdditiveExpression ((LEFT / RIGHT) AdditiveExpression)*

    AdditiveExpression          <-      MultiplicativeExpression ((PLUS / MINUS) MultiplicativeExpression)*

    MultiplicativeExpression    <-      CastExpression ((STAR / DIV / MOD) CastExpression)*

    CastExpression              <-      (LPAR TypeName RPAR)* UnaryExpression

    UnaryExpression             <-      PostfixExpression /
                                        INC UnaryExpression /
                                        DEC UnaryExpression /
                                        UnaryOperator CastExpression /
                                        SIZEOF (UnaryExpression / LPAR TypeName RPAR )

    UnaryOperator               <-      AND / STAR / PLUS / MINUS / TILDA / BANG                                        

    PostfixExpression           <-      ( PrimaryExpression /
                                        LPAR TypeName RPAR LWING InitializerList COMMA? RWING )
                                        ( LBRK Expression RBRK /
                                        LPAR ArgumentExpressionList? RPAR /
                                        DOT Identifier /
                                        PTR Identifier /
                                        INC /
                                        DEC )*

    TypeName                    <-      SpecifierQualifierList AbstractDeclarator?

    InitializerList             <-      Designation? Initializer (COMMA Designation? Initializer)*

    Designation                 <-      Designator+ EQU

    Designator                  <-      LBRK ConstantExpression RBRK / DOT Identifier

    Initializer                 <-      AssignmentExpression / LWING InitializerList COMMA? RWING

    ArgumentExpressionList      <-      AssignmentExpression (COMMA AssignmentExpression)*

    SpecifierQualifierList      <-      ( TypeQualifier* TypedefName TypeQualifier* ) / 
                                        ( TypeSpecifier / TypeQualifier )+

    TypeQualifier               <-      CONST / RESTRICT / VOLATILE / DECLSPEC LPAR Identifier RPAR 

    TypedefName                 <-      Identifier

    TypeSpecifier               <-      VOID / CHAR / SHORT / INT / LONG / FLOAT / DOUBLE / SIGNED / UNSIGNED /
                                        BOOL / COMPLEX / StructOrUnionSpecifier / EnumSpecifier

    StructOrUnionSpecifier      <-      StructOrUnion ( Identifier? LWING StructDeclaration+ RWING / Identifier ) 

    EnumSpecifier               <-      ENUM ( Identifier? LWING EnumeratorList COMMA? RWING / Identifier )

    EnumeratorList              <-      Enumerator (COMMA Enumerator)*

    Enumerator                  <-      EnumerationConstant (EQU ConstantExpression)?  

    StructOrUnion               <-      STRUCT / UNION 

    StructDeclaration           <-      SpecifierQualifierList StructDeclaratorList SEMI

    StructDeclaratorList        <-      StructDeclarator (COMMA StructDeclarator)*

    StructDeclarator            <-      Declarator? COLON ConstantExpression / Declarator    

    Declarator                  <-      Pointer? DirectDeclarator

    Pointer                     <-      ( STAR TypeQualifier* )+

    DirectDeclarator            <-      ( Identifier / LPAR Declarator RPAR )
                                        ( LBRK TypeQualifier* AssignmentExpression? RBRK
                                        / LBRK STATIC TypeQualifier* AssignmentExpression RBRK
                                        / LBRK TypeQualifier+ STATIC AssignmentExpression RBRK
                                        / LBRK TypeQualifier* STAR RBRK
                                        / LPAR ParameterTypeList RPAR
                                        / LPAR IdentifierList? RPAR )* 

    ParameterTypeList           <-      ParameterList (COMMA ELLIPSIS)?  

    IdentifierList              <-      Identifier (COMMA Identifier)*  

    ParameterList               <-      ParameterDeclaration (COMMA ParameterDeclaration)*

    ParameterDeclaration        <-      DeclarationSpecifiers ( Declarator / AbstractDeclarator )? 

    DeclarationSpecifiers       <-      (( StorageClassSpecifier / TypeQualifier / FunctionSpecifier )*
                                        TypedefName ( StorageClassSpecifier / TypeQualifier / FunctionSpecifier )*) /
                                        ( StorageClassSpecifier / TypeSpecifier / TypeQualifier /
                                        FunctionSpecifier )+  

    AbstractDeclarator          <-      Pointer? DirectAbstractDeclarator / Pointer 
    
    DirectAbstractDeclarator    <-      ( LPAR AbstractDeclarator RPAR /
                                        LBRK (AssignmentExpression / STAR)? RBRK /
                                        LPAR ParameterTypeList? RPAR )
                                        ( LBRK (AssignmentExpression / STAR)? RBRK
                                        / LPAR ParameterTypeList? RPAR )*                                         

    StorageClassSpecifier       <-      TYPEDEF / EXTERN / STATIC / AUTO / REGISTER /
                                        ATTRIBUTE LPAR LPAR (!RPAR .)* RPAR RPAR     

    FunctionSpecifier           <-      INLINE / STDCALL                                                                                                          

    PrimaryExpression           <-      Identifier / Constant / StringLiteral / LPAR Expression RPAR

    Constant                    <-      FloatConstant / IntegerConstant / EnumerationConstant / CharacterConstant

    FloatConstant               <-      DecimalFloatConstant

    DecimalFloatConstant        <-      Fraction / [0-9]+ 

    Fraction                    <-      [0-9]* "." [0-9]+ / [0-9]+ "."  

    IntegerConstant             <-      DecimalConstant

    DecimalConstant             <-      [1-9][0-9]*

    EnumerationConstant         <-      Identifier

    CharacterConstant           <-      "L"? "'" Char* "'"

    Char                        <-      [a-z] / [A-Z]

    StringLiteral               <-      '"' (!'"' .)* '"' / "'" (!"'" .)* "'"

    Expression                  <-      AssignmentExpression (COMMA AssignmentExpression)*

    AssignmentExpression        <-      UnaryExpression AssignmentOperator AssignmentExpression / ConditionalExpression

    AssignmentOperator          <-      EQU / STAREQU / DIVEQU / MODEQU / PLUSEQU / MINUSEQU / LEFTEQU /
                                        RIGHTEQU / ANDEQU / HATEQU / OREQU

    Keyword                     <-      ( "auto" / "break" / "case" / "char" / "const" / "continue" / "default" / "double" /
                                        "do" / "else" / "enum" / "extern" / "float" / "for" / "goto" / "if" / "int" /
                                        "inline" / "long" / "register" / "restrict" / "return" / "short" / "signed" /
                                        "sizeof" / "static" / "struct" / "switch" / "typedef" / "union" / "unsigned" /
                                        "void" / "volatile" / "while" / "_Bool" / "_Complex" / "_Imaginary" / "_stdcall" /
                                        "__declspec" / "__attribute__" )  !IdChar

    IdChar                      <-      [a-z] / [A-Z] / [0-9]

    IdNondigit                  <-      [a-z] / [A-Z]                                    



--Keywords

    AUTO      <- "auto"     
    BREAK     <- "break"    
    CASE      <- "case"     
    CHAR      <- "char"     
    CONST     <- "const"    
    CONTINUE  <- "continue" 
    DEFAULT   <- "default"  
    DOUBLE    <- "double"   
    DO        <- "do"       
    ELSE      <- "else"     
    ENUM      <- "enum"     
    EXTERN    <- "extern"   
    FLOAT     <- "float"    
    FOR       <- "for"      
    GOTO      <- "goto"     
    IF        <- "if"       
    INT       <- "int"      
    INLINE    <- "inline"   
    LONG      <- "long"     
    REGISTER  <- "register" 
    RESTRICT  <- "restrict" 
    RETURN    <- "return"   
    SHORT     <- "short"    
    SIGNED    <- "signed"   
    SIZEOF    <- "sizeof"   
    STATIC    <- "static"   
    STRUCT    <- "struct"   
    SWITCH    <- "switch"   
    TYPEDEF   <- "typedef"  
    UNION     <- "union"    
    UNSIGNED  <- "unsigned" 
    VOID      <- "void"     
    VOLATILE  <- "volatile" 
    WHILE     <- "while"    
    BOOL      <- "_Bool"    
    COMPLEX   <- "_Complex" 
    STDCALL   <- "_stdcall" 
    DECLSPEC  <- "__declspec"
    ATTRIBUTE <- "__attribute__"

-- Punctuators

    LBRK       <-  "["         
    RBRK       <-  "]"         
    LPAR       <-  "("         
    RPAR       <-  ")"         
    LWING      <-  "{"         
    RWING      <-  "}"         
    DOT        <-  "."         
    PTR        <-  "->"        
    INC        <-  "++"        
    DEC        <-  "--"        
    AND        <-  "&"  !"&" 
    STAR       <-  "*"  !"="   
    PLUS       <-  "+"  !"+="  
    MINUS      <-  "-"  !"\-=>"
    TILDA      <-  "~"         
    BANG       <-  "!"  !"="   
    DIV        <-  "/"  !"="   
    MOD        <-  "%"  !"=>"  
    LEFT       <-  "<<" !"="   
    RIGHT      <-  ">>" !"="   
    LT         <-  "<"  !"="   
    GT         <-  ">"  !"="   
    LE         <-  "<="        
    GE         <-  ">="        
    EQUEQU     <-  "=="        
    BANGEQU    <-  "!="        
    HAT        <-  "^"  !"="   
    OR         <-  "|"  !"="   
    ANDAND     <-  "&&"        
    OROR       <-  "||"        
    QUERY      <-  "?"         
    COLON      <-  ":"  !">"   
    SEMI       <-  ";"         
    ELLIPSIS   <-  "..."       
    EQU        <-  "="  !"="   
    STAREQU    <-  "*="        
    DIVEQU     <-  "/="        
    MODEQU     <-  "%="        
    PLUSEQU    <-  "+="        
    MINUSEQU   <-  "-="        
    LEFTEQU    <-  "<<="       
    RIGHTEQU   <-  ">>="       
    ANDEQU     <-  "&="        
    HATEQU     <-  "^="        
    OREQU      <-  "|="        
    COMMA      <-  ","         

    EOT        <-  !.                                                                          

]]  


g, lab, pos = m.match(parser)
print(g, lab, pos)

--gerar o parser
local p = coder.makeg(g)      



local dir = util.getPath(arg[0]) .. '/test'
if arg[1] then
  dir = util.getPath(arg[1])
end

util.testYes(dir .. '/yes/', 'c', p)
util.testNo(dir .. '/no/', 'c', p)


