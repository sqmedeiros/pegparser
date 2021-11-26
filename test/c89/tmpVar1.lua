Unique Path (UPath)
Uunique
CHAR_CONST	 = 	1
volatile	 = 	1
]	 = 	3
[	 = 	3
goto	 = 	1
|=	 = 	1
sizeof	 = 	1
else	 = 	1
union	 = 	1
unsigned	 = 	1
<<=	 = 	1
^	 = 	1
ID	 = 	15
while	 = 	2
|	 = 	1
}	 = 	4
{	 = 	4
const	 = 	1
enum	 = 	2
%=	 = 	1
&=	 = 	1
void	 = 	1
!=	 = 	1
-=	 = 	1
+=	 = 	1
*=	 = 	1
signed	 = 	1
&&	 = 	1
case	 = 	1
/=	 = 	1
==	 = 	1
char	 = 	1
break	 = 	1
<=	 = 	1
struct	 = 	1
short	 = 	1
!	 = 	1
continue	 = 	1
default	 = 	1
&	 = 	2
~	 = 	1
if	 = 	2
-	 = 	2
>>=	 = 	1
+	 = 	2
ENUMERATION_CONST	 = 	1
for	 = 	1
||	 = 	1
long	 = 	1
FLOAT_CONST	 = 	1
%	 = 	1
INT_CONST	 = 	1
STRING	 = 	1
->	 = 	1
.	 = 	1
--	 = 	2
*	 = 	4
<	 = 	1
=	 = 	3
:	 = 	5
;	 = 	10
>>	 = 	1
^=	 = 	1
<<	 = 	1
/	 = 	1
++	 = 	2
>=	 = 	1
do	 = 	1
auto	 = 	1
extern	 = 	1
double	 = 	1
static	 = 	1
switch	 = 	1
SKIP	 = 	1
int	 = 	1
(	 = 	14
return	 = 	1
)	 = 	14
,	 = 	10
>	 = 	1
?	 = 	1
typedef	 = 	1
...	 = 	1
register	 = 	1
float	 = 	1
Token 	1	 = 	65
Token 	2	 = 	8
Token 	3	 = 	3
Token 	4	 = 	3
Token 	5	 = 	1
Token 	6	 = 	nil
Token 	7	 = 	nil
Token 	8	 = 	nil
Token 	9	 = 	nil
Token 	10	 = 	2
Unique tokens (# 64): !, !=, %, %=, &&, &=, *=, +=, -=, ->, ., ..., /, /=, <, <<, <<=, <=, ==, >, >=, >>, >>=, ?, CHAR_CONST, ENUMERATION_CONST, FLOAT_CONST, INT_CONST, STRING, ^, ^=, auto, break, case, char, const, continue, default, do, double, else, extern, float, for, goto, int, long, register, return, short, signed, sizeof, static, struct, switch, typedef, union, unsigned, void, volatile, |, |=, ||, ~
calcTail
translation_unit: 	;, }
external_decl: 	;, }
function_def: 	}
decl_spec: 	__ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, }
decl: 	;
storage_class_spec: 	auto, extern, register, static, typedef
type_spec: 	__ID, char, double, float, int, long, short, signed, unsigned, void, }
type_qualifier: 	const, volatile
struct_or_union: 	struct, union
init_declarator_list: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
init_declarator: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
struct_decl: 	;
spec_qualifier_list: 	__ID, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
spec_qualifier: 	__ID, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
struct_declarator: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
enumerator: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
declarator: 	), ], __ID
direct_declarator: 	), ], __ID
pointer: 	*, const, volatile
param_type_list: 	), *, ..., ], __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, }
param_decl: 	), *, ], __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, }
id_list: 	__ID
initializer: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
type_name: 	), *, ], __ID, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
abstract_declarator: 	), *, ], const, volatile
direct_abstract_declarator: 	), ]
typedef_name: 	__ID
stat: 	;, }
compound_stat: 	}
exp: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
assignment_exp: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
assignment_operator: 	%=, &=, *=, +=, -=, /=, <<=, =, >>=, ^=, |=
conditional_exp: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
const_exp: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
logical_or_exp: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
logical_and_exp: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
inclusive_or_exp: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
exclusive_or_exp: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
and_exp: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
equality_exp: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
relational_exp: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
shift_exp: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
additive_exp: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
multiplicative_exp: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
cast_exp: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
unary_exp: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
postfix_exp: 	), ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING
primary_exp: 	), __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING
constant: 	__CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __INT_CONST
unary_operator: 	!, &, *, +, -, ~
COMMENT: 	*/
INT_CONST: 	0, 1, 2, 3, 4, 5, 6, 7, 8, L, U, __DIGIT, __XDIGIT, l, u
FLOAT_CONST: 	., F, L, __DIGIT, __XDIGIT, f, l
XDIGIT: 	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, F, a, b, c, d, e, f
DIGIT: 	0, 1, 2, 3, 4, 5, 6, 7, 8, 9
CHAR_CONST: 	'
STRING: 	"
ESC_CHAR: 	", ', 0, 1, 2, 3, 4, 5, 6, 7, ?, \\, __XDIGIT, a, b, f, n, r, t, v
ENUMERATION_CONST: 	__ID
ID: 	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, _, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
KEYWORDS: 	auto, break, case, char, const, continue, default, do, double, else, enum, extern, float, for, goto, if, int, long, register, return, short, signed, sizeof, static, struct, switch, typedef, union, unsigned, void, volatile, while
SPACE: 		, 
, , , ,  , __COMMENT
SKIP: 		, 
, , , ,  , __COMMENT, __empty
Global Prefix
translation_unit: 	
external_decl: 	;, }
function_def: 	;, __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, }
decl_spec: 	), ;, ], __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, {, }
decl: 	), ;, ], __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, {, }
storage_class_spec: 	), ;, ], __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, {, }
type_spec: 	), ;, ], __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, {, }
type_qualifier: 	), *, ;, ], __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, {, }
struct_or_union: 	), ;, ], __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, {, }
init_declarator_list: 	__ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, }
init_declarator: 	,, __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, }
struct_decl: 	;, __ID, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
spec_qualifier_list: 	(, sizeof
spec_qualifier: 	;, __ID, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
struct_declarator: 	,, __ID, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
enumerator: 	,, {
declarator: 	(, ,, ;, __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, }
direct_declarator: 	(, *, ,, ;, __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, }
pointer: 	(, *, ,, ;, __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, }
param_type_list: 	(
param_decl: 	(, ,
id_list: 	(
initializer: 	,, =, {
type_name: 	(, sizeof
abstract_declarator: 	(, __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, }
direct_abstract_declarator: 	(, *, __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, }
typedef_name: 	), ;, ], __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, {, }
stat: 	), :, ;, do, else, {, }
compound_stat: 	), :, ;, ], __ID, do, else, {, }
exp: 	(, ), :, ;, ?, [, do, else, return, {, }
assignment_exp: 	%=, &=, (, ), *=, +=, ,, -=, /=, :, ;, <<=, =, >>=, ?, [, ^=, do, else, return, {, |=, }
assignment_operator: 	), *, ++, --, ], __CHAR_CONST, __ENUMERATION_CONST, __FLOAT_CONST, __ID, __INT_CONST, __STRING, char, const, double, float, int, long, short, signed, unsigned, void, volatile, }
conditional_exp: 	%=, &=, (, ), *=, +=, ,, -=, /=, :, ;, <<=, =, >>=, ?, [, ^=, case, do, else, return, {, |=, }
const_exp: 	:, =, [, case
logical_or_exp: 	%=, &=, (, ), *=, +=, ,, -=, /=, :, ;, <<=, =, >>=, ?, [, ^=, case, do, else, return, {, |=, }
logical_and_exp: 	%=, &=, (, ), *=, +=, ,, -=, /=, :, ;, <<=, =, >>=, ?, [, ^=, case, do, else, return, {, |=, ||, }
inclusive_or_exp: 	%=, &&, &=, (, ), *=, +=, ,, -=, /=, :, ;, <<=, =, >>=, ?, [, ^=, case, do, else, return, {, |=, ||, }
exclusive_or_exp: 	%=, &&, &=, (, ), *=, +=, ,, -=, /=, :, ;, <<=, =, >>=, ?, [, ^=, case, do, else, return, {, |, |=, ||, }
and_exp: 	%=, &&, &=, (, ), *=, +=, ,, -=, /=, :, ;, <<=, =, >>=, ?, [, ^, ^=, case, do, else, return, {, |, |=, ||, }
equality_exp: 	%=, &, &&, &=, (, ), *=, +=, ,, -=, /=, :, ;, <<=, =, >>=, ?, [, ^, ^=, case, do, else, return, {, |, |=, ||, }
relational_exp: 	!=, %=, &, &&, &=, (, ), *=, +=, ,, -=, /=, :, ;, <<=, =, ==, >>=, ?, [, ^, ^=, case, do, else, return, {, |, |=, ||, }
shift_exp: 	!=, %=, &, &&, &=, (, ), *=, +=, ,, -=, /=, :, ;, <, <<=, <=, =, ==, >, >=, >>=, ?, [, ^, ^=, case, do, else, return, {, |, |=, ||, }
additive_exp: 	!=, %=, &, &&, &=, (, ), *=, +=, ,, -=, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, [, ^, ^=, case, do, else, return, {, |, |=, ||, }
multiplicative_exp: 	!=, %=, &, &&, &=, (, ), *=, +, +=, ,, -, -=, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, [, ^, ^=, case, do, else, return, {, |, |=, ||, }
cast_exp: 	!, !=, %, %=, &, &&, &=, (, ), *, *=, +, +=, ,, -, -=, /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, [, ^, ^=, case, do, else, return, {, |, |=, ||, }, ~
unary_exp: 	!, !=, %, %=, &, &&, &=, (, ), *, *=, +, ++, +=, ,, -, --, -=, /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, [, ^, ^=, case, do, else, return, sizeof, {, |, |=, ||, }, ~
postfix_exp: 	!, !=, %, %=, &, &&, &=, (, ), *, *=, +, ++, +=, ,, -, --, -=, /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, [, ^, ^=, case, do, else, return, sizeof, {, |, |=, ||, }, ~
primary_exp: 	!, !=, %, %=, &, &&, &=, (, ), *, *=, +, ++, +=, ,, -, --, -=, /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, [, ^, ^=, case, do, else, return, sizeof, {, |, |=, ||, }, ~
constant: 	!, !=, %, %=, &, &&, &=, (, ), *, *=, +, ++, +=, ,, -, --, -=, /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, [, ^, ^=, case, do, else, return, sizeof, {, |, |=, ||, }, ~
unary_operator: 	!, !=, %, %=, &, &&, &=, (, ), *, *=, +, ++, +=, ,, -, --, -=, /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, [, ^, ^=, case, do, else, return, sizeof, {, |, |=, ||, }, ~
COMMENT: 		, 
, , , ,  , __COMMENT
INT_CONST: 	!, !=, %, %=, &, &&, &=, (, ), *, *=, +, ++, +=, ,, -, --, -=, /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, [, ^, ^=, case, do, else, return, sizeof, {, |, |=, ||, }, ~
FLOAT_CONST: 	!, !=, %, %=, &, &&, &=, (, ), *, *=, +, ++, +=, ,, -, --, -=, /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, [, ^, ^=, case, do, else, return, sizeof, {, |, |=, ||, }, ~
XDIGIT: 	__XDIGIT, x
DIGIT: 	!, !=, %, %=, &, &&, &=, (, ), *, *=, +, ++, +=, ,, -, --, -=, /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, [, ^, ^=, __DIGIT, case, do, else, return, sizeof, {, |, |=, ||, }, ~
CHAR_CONST: 	!, !=, %, %=, &, &&, &=, (, ), *, *=, +, ++, +=, ,, -, --, -=, /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, [, ^, ^=, case, do, else, return, sizeof, {, |, |=, ||, }, ~
STRING: 	!, !=, %, %=, &, &&, &=, (, ), *, *=, +, ++, +=, ,, -, --, -=, /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, [, ^, ^=, case, do, else, return, sizeof, {, |, |=, ||, }, ~
ESC_CHAR: 	
ENUMERATION_CONST: 	!, !=, %, %=, &, &&, &=, (, ), *, *=, +, ++, +=, ,, -, --, -=, /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, [, ^, ^=, case, do, else, return, sizeof, {, |, |=, ||, }, ~
ID: 	!, !=, %, %=, &, &&, &=, (, ), *, *=, +, ++, +=, ,, -, --, -=, ->, ., /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, [, ], ^, ^=, __ID, auto, case, char, const, do, double, else, enum, extern, float, goto, int, long, register, return, short, signed, sizeof, static, struct, typedef, union, unsigned, void, volatile, {, |, |=, ||, }, ~
KEYWORDS: 	
SPACE: 	
SKIP: 	
foi true22
passou três	storage_class_spec	decl_spec
UniqueFlw	ID	rule = 	type_spec	pref = 	enum	flw = 	!=, %, %=, &, &&, &=, (, ), *, *=, +, +=, ,, -, -=, /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, ], ^, ^=, __ID, auto, char, const, double, enum, extern, float, int, long, register, short, signed, static, struct, typedef, union, unsigned, void, volatile, |, |=, ||, }	nInt = 	1	nEq = 	1	pflw = 	nil
UniqueFlwVar	struct_or_union	rule = 	type_spec	pref = 	), ;, ], __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, {, }	flw = 	__ID, {
UniqueFlwVar	struct_or_union	rule = 	type_spec	pref = 	), ;, ], __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, {, }	flw = 	__ID
UniqueFlw	ID	rule = 	type_spec	pref = 	struct, union	flw = 	!=, %, %=, &, &&, &=, (, ), *, *=, +, +=, ,, -, -=, /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, ], ^, ^=, __ID, auto, char, const, double, enum, extern, float, int, long, register, short, signed, static, struct, typedef, union, unsigned, void, volatile, |, |=, ||, }	nInt = 	1	nEq = 	1	pflw = 	nil
passou três	initializer	init_declarator
passou três	const_exp	enumerator
UniqueFlwVar	const_exp	rule = 	direct_declarator	pref = 	[	flw = 	]
UniqueFlwVar	type_qualifier	rule = 	pointer	pref = 	*, const, volatile	flw = 	*, const, volatile
UniqueFlwVar	abstract_declarator	rule = 	direct_abstract_declarator	pref = 	(	flw = 	)
UniqueFlwVar	const_exp	rule = 	direct_abstract_declarator	pref = 	[	flw = 	]
foi true22
passou três	const_exp	stat
UniqueFlwVar	const_exp	rule = 	stat	pref = 	case	flw = 	:
foi true22
foi true22
foi true22
passou três	stat	stat
foi true22
foi true22
foi true22
passou três	stat	stat
UniqueFlwVar	stat	rule = 	stat	pref = 	do	flw = 	while
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	exp	stat
UniqueFlwVar	exp	rule = 	stat	pref = 	return	flw = 	;
foi true22
passou três	exp	conditional_exp
UniqueFlwVar	exp	rule = 	conditional_exp	pref = 	?	flw = 	:
foi true22
passou três	logical_and_exp	logical_or_exp
foi true22
passou três	inclusive_or_exp	logical_and_exp
foi true22
passou três	exclusive_or_exp	inclusive_or_exp
foi true22
passou três	and_exp	exclusive_or_exp
passou três	equality_exp	and_exp
foi true22
foi true22
passou três	relational_exp	equality_exp
foi true22
foi true22
foi true22
foi true22
passou três	shift_exp	relational_exp
foi true22
foi true22
passou três	additive_exp	shift_exp
passou três	multiplicative_exp	additive_exp
foi true22
foi true22
foi true22
passou três	unary_exp	unary_exp
passou três	exp	postfix_exp
UniqueFlwVar	exp	rule = 	postfix_exp	pref = 	[	flw = 	]
foi true22
foi true22
passou três	constant	primary_exp
unique var 	external_decl
Unique usage	external_decl
unique var 	decl
unique var 	enumerator
unique var 	enumerator
Unique usage	enumerator
unique var 	struct_decl
unique var 	const_exp
unique var 	param_type_list
unique var 	const_exp
unique var 	stat
unique var 	stat
unique var 	stat
unique var 	exp
unique var 	stat
unique var 	exp
unique var 	stat
unique var 	exp
unique var 	stat
unique var 	stat
unique var 	exp
unique var 	exp
unique var 	exp
unique var 	exp
unique var 	stat
unique var 	exp
unique var 	exp
unique var 	conditional_exp
unique var 	logical_and_exp
unique var 	inclusive_or_exp
unique var 	exclusive_or_exp
unique var 	and_exp
unique var 	relational_exp
unique var 	shift_exp
unique var 	additive_exp
unique var 	unary_exp
foi true22
UniqueFlw	ID	rule = 	type_spec	pref = 	enum	flw = 	!=, %, %=, &, &&, &=, (, ), *, *=, +, +=, ,, -, -=, /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, ], ^, ^=, __ID, auto, char, const, double, enum, extern, float, int, long, register, short, signed, static, struct, typedef, union, unsigned, void, volatile, |, |=, ||, }	nInt = 	1	nEq = 	1	pflw = 	nil
UniqueFlwVar	struct_or_union	rule = 	type_spec	pref = 	), ;, ], __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, {, }	flw = 	__ID, {
UniqueFlwVar	struct_or_union	rule = 	type_spec	pref = 	), ;, ], __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, {, }	flw = 	__ID
UniqueFlw	ID	rule = 	type_spec	pref = 	struct, union	flw = 	!=, %, %=, &, &&, &=, (, ), *, *=, +, +=, ,, -, -=, /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, ], ^, ^=, __ID, auto, char, const, double, enum, extern, float, int, long, register, short, signed, static, struct, typedef, union, unsigned, void, volatile, |, |=, ||, }	nInt = 	1	nEq = 	1	pflw = 	nil
passou três	initializer	init_declarator
passou três	const_exp	enumerator
UniqueFlwVar	const_exp	rule = 	direct_declarator	pref = 	[	flw = 	]
UniqueFlwVar	type_qualifier	rule = 	pointer	pref = 	*, const, volatile	flw = 	*, const, volatile
UniqueFlwVar	abstract_declarator	rule = 	direct_abstract_declarator	pref = 	(	flw = 	)
UniqueFlwVar	const_exp	rule = 	direct_abstract_declarator	pref = 	[	flw = 	]
foi true22
passou três	const_exp	stat
UniqueFlwVar	const_exp	rule = 	stat	pref = 	case	flw = 	:
foi true22
foi true22
foi true22
passou três	stat	stat
foi true22
foi true22
foi true22
passou três	stat	stat
UniqueFlwVar	stat	rule = 	stat	pref = 	do	flw = 	while
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	exp	stat
UniqueFlwVar	exp	rule = 	stat	pref = 	return	flw = 	;
foi true22
passou três	exp	conditional_exp
UniqueFlwVar	exp	rule = 	conditional_exp	pref = 	?	flw = 	:
foi true22
passou três	logical_and_exp	logical_or_exp
foi true22
passou três	inclusive_or_exp	logical_and_exp
foi true22
passou três	exclusive_or_exp	inclusive_or_exp
foi true22
passou três	and_exp	exclusive_or_exp
passou três	equality_exp	and_exp
foi true22
foi true22
passou três	relational_exp	equality_exp
foi true22
foi true22
foi true22
foi true22
passou três	shift_exp	relational_exp
foi true22
foi true22
passou três	additive_exp	shift_exp
passou três	multiplicative_exp	additive_exp
foi true22
foi true22
foi true22
passou três	unary_exp	unary_exp
passou três	exp	postfix_exp
UniqueFlwVar	exp	rule = 	postfix_exp	pref = 	[	flw = 	]
foi true22
foi true22
unique var 	external_decl
Unique usage	external_decl
unique var 	decl
unique var2 	storage_class_spec
unique var 	enumerator
Unique usage	enumerator
unique var 	enumerator
Unique usage	enumerator
unique var 	struct_decl
unique var2 	direct_abstract_declarator
unique var 	const_exp
unique var 	param_type_list
unique var 	const_exp
unique var 	stat
unique var 	stat
unique var 	stat
unique var 	exp
unique var 	stat
unique var 	exp
unique var 	stat
unique var 	exp
unique var 	stat
unique var 	stat
unique var 	exp
unique var 	exp
unique var 	exp
unique var 	exp
unique var 	stat
unique var 	exp
unique var 	exp
unique var 	conditional_exp
unique var 	logical_and_exp
unique var 	inclusive_or_exp
unique var 	exclusive_or_exp
unique var 	and_exp
unique var 	relational_exp
unique var 	shift_exp
unique var 	additive_exp
unique var 	unary_exp
unique var2 	constant
foi true22
UniqueFlw	ID	rule = 	type_spec	pref = 	enum	flw = 	!=, %, %=, &, &&, &=, (, ), *, *=, +, +=, ,, -, -=, /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, ], ^, ^=, __ID, auto, char, const, double, enum, extern, float, int, long, register, short, signed, static, struct, typedef, union, unsigned, void, volatile, |, |=, ||, }	nInt = 	1	nEq = 	1	pflw = 	nil
UniqueFlwVar	struct_or_union	rule = 	type_spec	pref = 	), ;, ], __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, {, }	flw = 	__ID, {
UniqueFlwVar	struct_or_union	rule = 	type_spec	pref = 	), ;, ], __ID, auto, char, const, double, extern, float, int, long, register, short, signed, static, typedef, unsigned, void, volatile, {, }	flw = 	__ID
UniqueFlw	ID	rule = 	type_spec	pref = 	struct, union	flw = 	!=, %, %=, &, &&, &=, (, ), *, *=, +, +=, ,, -, -=, /, /=, :, ;, <, <<, <<=, <=, =, ==, >, >=, >>, >>=, ?, ], ^, ^=, __ID, auto, char, const, double, enum, extern, float, int, long, register, short, signed, static, struct, typedef, union, unsigned, void, volatile, |, |=, ||, }	nInt = 	1	nEq = 	1	pflw = 	nil
passou três	initializer	init_declarator
passou três	const_exp	enumerator
UniqueFlwVar	const_exp	rule = 	direct_declarator	pref = 	[	flw = 	]
UniqueFlwVar	type_qualifier	rule = 	pointer	pref = 	*, const, volatile	flw = 	*, const, volatile
UniqueFlwVar	abstract_declarator	rule = 	direct_abstract_declarator	pref = 	(	flw = 	)
UniqueFlwVar	const_exp	rule = 	direct_abstract_declarator	pref = 	[	flw = 	]
foi true22
passou três	const_exp	stat
UniqueFlwVar	const_exp	rule = 	stat	pref = 	case	flw = 	:
foi true22
foi true22
foi true22
passou três	stat	stat
foi true22
foi true22
foi true22
passou três	stat	stat
UniqueFlwVar	stat	rule = 	stat	pref = 	do	flw = 	while
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	exp	stat
UniqueFlwVar	exp	rule = 	stat	pref = 	return	flw = 	;
foi true22
passou três	exp	conditional_exp
UniqueFlwVar	exp	rule = 	conditional_exp	pref = 	?	flw = 	:
foi true22
passou três	logical_and_exp	logical_or_exp
foi true22
passou três	inclusive_or_exp	logical_and_exp
foi true22
passou três	exclusive_or_exp	inclusive_or_exp
foi true22
passou três	and_exp	exclusive_or_exp
passou três	equality_exp	and_exp
foi true22
foi true22
passou três	relational_exp	equality_exp
foi true22
foi true22
foi true22
foi true22
passou três	shift_exp	relational_exp
foi true22
foi true22
passou três	additive_exp	shift_exp
passou três	multiplicative_exp	additive_exp
foi true22
foi true22
foi true22
passou três	unary_exp	unary_exp
passou três	exp	postfix_exp
UniqueFlwVar	exp	rule = 	postfix_exp	pref = 	[	flw = 	]
foi true22
foi true22
unique var 	external_decl
Unique usage	external_decl
unique var 	decl
unique var2 	storage_class_spec
unique var 	enumerator
Unique usage	enumerator
unique var 	enumerator
Unique usage	enumerator
unique var 	struct_decl
unique var2 	direct_abstract_declarator
unique var 	const_exp
unique var 	param_type_list
unique var 	const_exp
unique var 	stat
unique var 	stat
unique var 	stat
unique var 	exp
unique var 	stat
unique var 	exp
unique var 	stat
unique var 	exp
unique var 	stat
unique var 	stat
unique var 	exp
unique var 	exp
unique var 	exp
unique var 	exp
unique var 	stat
unique var 	exp
unique var 	exp
unique var 	conditional_exp
unique var 	logical_and_exp
unique var 	inclusive_or_exp
unique var 	exclusive_or_exp
unique var 	and_exp
unique var 	relational_exp
unique var 	shift_exp
unique var 	additive_exp
unique var 	unary_exp
unique var2 	constant
insideLoop: external_decl, function_def, decl_spec, decl, storage_class_spec, type_spec, type_qualifier, struct_or_union, init_declarator_list, init_declarator, struct_decl, spec_qualifier, declarator, direct_declarator, pointer, param_type_list, param_decl, id_list, abstract_declarator, direct_abstract_declarator, typedef_name, stat, compound_stat, exp, assignment_exp, conditional_exp, const_exp, logical_or_exp, logical_and_exp, inclusive_or_exp, exclusive_or_exp, and_exp, equality_exp, relational_exp, shift_exp, additive_exp, multiplicative_exp, cast_exp, unary_exp, postfix_exp, primary_exp, constant, unary_operator, 
Unique vars: translation_unit, external_decl, enumerator, 
matchUPath: translation_unit, external_decl, storage_class_spec, type_qualifier, struct_or_union, enumerator, direct_abstract_declarator, constant, 
Adding labels: Err_1, Err_2, Err_3, Err_4, Err_5, Err_6, Err_7, Err_8, Err_9, Err_10, Err_11, Err_12, Err_13, Err_14, Err_15, Err_16, Err_17, Err_18, Err_19, Err_20, Err_21, Err_22, Err_23, Err_24, Err_25, Err_26, Err_27, Err_28, Err_29, Err_30, Err_31, Err_32, Err_33, Err_34, Err_35, Err_36, Err_37, Err_38, Err_39, Err_40, Err_41, Err_42, Err_43, Err_44, Err_45, Err_46, Err_47, Err_48, Err_49, Err_50, Err_51, Err_52, Err_53, Err_54, Err_55, Err_56, Err_57, Err_58, Err_59, Err_60, Err_61, Err_62, 

Property 	nil
translation_unit <-  SKIP external_decl+^Err_001 !.
external_decl   <-  function_def  /  decl
function_def    <-  declarator decl* compound_stat  /  decl_spec function_def
decl_spec       <-  storage_class_spec  /  type_spec  /  type_qualifier
decl            <-  decl_spec init_declarator_list? ';'  /  decl_spec decl
storage_class_spec <-  'auto'  /  'register'  /  'static'  /  'extern'  /  'typedef'
type_spec       <-  'void'  /  'char'  /  'short'  /  'int'  /  'long'  /  'float'  /  'double'  /  'signed'  /  'unsigned'  /  typedef_name  /  'enum' ID? '{' enumerator^Err_002 (',' enumerator^Err_003)* '}'^Err_004  /  'enum' ID^Err_005  /  struct_or_union ID? '{'^Err_006 struct_decl+^Err_007 '}'^Err_008  /  struct_or_union ID^Err_009
type_qualifier  <-  'const'  /  'volatile'
struct_or_union <-  'struct'  /  'union'
init_declarator_list <-  init_declarator (',' init_declarator)*
init_declarator <-  declarator '=' initializer  /  declarator
struct_decl     <-  spec_qualifier struct_declarator (',' struct_declarator)* ';'  /  spec_qualifier struct_decl
spec_qualifier_list <-  (type_spec  /  type_qualifier)+
spec_qualifier  <-  type_spec  /  type_qualifier
struct_declarator <-  declarator? ':' const_exp  /  declarator
enumerator      <-  (ID '=' const_exp  /  ID)^Err_010
declarator      <-  pointer? direct_declarator
direct_declarator <-  (ID  /  '(' declarator ')') ('[' const_exp? ']'  /  '(' param_type_list ')'  /  '(' id_list? ')')*
pointer         <-  '*' type_qualifier* pointer  /  '*' type_qualifier*
param_type_list <-  param_decl (',' param_decl)* (',' '...')?
param_decl      <-  decl_spec+ (declarator  /  abstract_declarator)?
id_list         <-  ID (',' ID)*
initializer     <-  '{' initializer (',' initializer)* ','? '}'  /  assignment_exp
type_name       <-  spec_qualifier_list abstract_declarator?
abstract_declarator <-  pointer  /  pointer? direct_abstract_declarator
direct_abstract_declarator <-  '(' abstract_declarator ')' ('[' const_exp? ']'^Err_011  /  '(' param_type_list? ')'^Err_012)*
typedef_name    <-  ID
stat            <-  ID ':' stat  /  'case' const_exp^Err_013 ':'^Err_014 stat^Err_015  /  'default' ':'^Err_016 stat^Err_017  /  exp? ';'  /  compound_stat  /  'if' '('^Err_018 exp^Err_019 ')' stat 'else' stat^Err_020  /  'if' '('^Err_021 exp^Err_022 ')'^Err_023 stat^Err_024  /  'switch' '('^Err_025 exp^Err_026 ')'^Err_027 stat^Err_028  /  'while' '('^Err_029 exp^Err_030 ')'^Err_031 stat^Err_032  /  'do' stat^Err_033 'while'^Err_034 '('^Err_035 exp^Err_036 ')'^Err_037 ';'^Err_038  /  'for' '('^Err_039 exp? ';'^Err_040 exp? ';'^Err_041 exp? ')'^Err_042 stat^Err_043  /  'goto' ID^Err_044 ';'^Err_045  /  'continue' ';'^Err_046  /  'break' ';'^Err_047  /  'return' exp? ';'^Err_048
compound_stat   <-  '{' decl* stat* '}'
exp             <-  assignment_exp (',' assignment_exp)*
assignment_exp  <-  unary_exp assignment_operator assignment_exp  /  conditional_exp
assignment_operator <-  '=' !'='  /  '*='  /  '/='  /  '%='  /  '+='  /  '-='  /  '<<='  /  '>>='  /  '&='  /  '^='  /  '|='
conditional_exp <-  logical_or_exp '?' exp^Err_049 ':'^Err_050 conditional_exp^Err_051  /  logical_or_exp
const_exp       <-  conditional_exp
logical_or_exp  <-  logical_and_exp ('||' logical_and_exp^Err_052)*
logical_and_exp <-  inclusive_or_exp ('&&' inclusive_or_exp^Err_053)*
inclusive_or_exp <-  exclusive_or_exp ('|' !'|' exclusive_or_exp^Err_054)*
exclusive_or_exp <-  and_exp ('^' and_exp^Err_055)*
and_exp         <-  equality_exp ('&' !'&' equality_exp)*
equality_exp    <-  relational_exp (('=='  /  '!=') relational_exp^Err_056)*
relational_exp  <-  shift_exp (('<='  /  '>='  /  '<'  /  '>') shift_exp^Err_057)*
shift_exp       <-  additive_exp (('<<'  /  '>>') additive_exp^Err_058)*
additive_exp    <-  multiplicative_exp (('+'  /  '-') multiplicative_exp)*
multiplicative_exp <-  cast_exp (('*'  /  '/'  /  '%') cast_exp)*
cast_exp        <-  '(' type_name ')' cast_exp  /  unary_exp
unary_exp       <-  '++' unary_exp  /  '--' unary_exp  /  unary_operator cast_exp  /  'sizeof' (type_name  /  unary_exp)^Err_059  /  postfix_exp
postfix_exp     <-  primary_exp ('[' exp ']'^Err_060  /  '(' (assignment_exp (',' assignment_exp)*)? ')'  /  '.' ID^Err_061  /  '->' ID^Err_062  /  '++'  /  '--')*
primary_exp     <-  ID  /  STRING  /  constant  /  '(' exp ')'
constant        <-  INT_CONST  /  CHAR_CONST  /  FLOAT_CONST  /  ENUMERATION_CONST
unary_operator  <-  '&'  /  '*'  /  '+'  /  '-'  /  '~'  /  '!'
COMMENT         <-  '/*' (!'*/' .)* '*/'
INT_CONST       <-  ('0' [xX] XDIGIT+  /  !'0' DIGIT DIGIT*  /  '0' [0-8]*) ([uU] [lL]  /  [lL] [uU]  /  'l'  /  'L'  /  'u'  /  'U')?
FLOAT_CONST     <-  '0x' (('.'  /  XDIGIT+  /  XDIGIT+  /  '.') ([eE] [-+]? XDIGIT+)? [lLfF]?  /  XDIGIT+ [eE] [-+]? XDIGIT+ [lLfF]?)  /  ('.'  /  DIGIT+  /  DIGIT+  /  '.') ([eE] [-+]? DIGIT+)? [lLfF]?  /  DIGIT+ [eE] [-+]? DIGIT+ [lLfF]?
XDIGIT          <-  [0-9a-fA-F]
DIGIT           <-  [0-9]
CHAR_CONST      <-  "'" (%nl  /  !"'" .) "'"
STRING          <-  '"' (%nl  /  !'"' .)* '"'
ESC_CHAR        <-  '\\' ('n'  /  't'  /  'v'  /  'b'  /  'r'  /  'f'  /  'a'  /  '\\'  /  '?'  /  "'"  /  '"'  /  [01234567] [01234567]? [01234567]?  /  'x' XDIGIT)
ENUMERATION_CONST <-  ID
ID              <-  !KEYWORDS [a-zA-Z_] [a-zA-Z_0-9]*
KEYWORDS        <-  ('auto'  /  'double'  /  'int'  /  'struct'  /  'break'  /  'else'  /  'long'  /  'switch'  /  'case'  /  'enum'  /  'register'  /  'typedef'  /  'char'  /  'extern'  /  'return'  /  'union'  /  'const'  /  'float'  /  'short'  /  'unsigned'  /  'continue'  /  'for'  /  'signed'  /  'void'  /  'default'  /  'goto'  /  'sizeof'  /  'volatile'  /  'do'  /  'if'  /  'static'  /  'while') ![a-zA-Z_0-9]
SPACE           <-  [ 	
]  /  COMMENT
SKIP            <-  ([ 	
]  /  COMMENT)*
Token           <-  '~'  /  '}'  /  '||'  /  '|='  /  '|'  /  '{'  /  XDIGIT  /  STRING  /  KEYWORDS  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ESC_CHAR  /  ENUMERATION_CONST  /  DIGIT  /  COMMENT  /  CHAR_CONST  /  '^='  /  '^'  /  ']'  /  '['  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '...'  /  '->'  /  '-='  /  '--'  /  '-'  /  ','  /  '+='  /  '++'  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!='  /  '!'
EatToken        <-  (Token  /  (!SPACE .)+) SKIP
Err_001         <-  (!('volatile'  /  'void'  /  'unsigned'  /  'union'  /  'typedef'  /  'struct'  /  'static'  /  'signed'  /  'short'  /  'register'  /  'long'  /  'int'  /  'float'  /  'extern'  /  'enum'  /  'double'  /  'const'  /  'char'  /  'auto'  /  ID  /  '*'  /  '('  /  !.) EatToken)*
Err_002         <-  (!('}'  /  ',') EatToken)*
Err_003         <-  (!('}'  /  ',') EatToken)*
Err_004         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'typedef'  /  'struct'  /  'static'  /  'signed'  /  'short'  /  'register'  /  'long'  /  'int'  /  'float'  /  'extern'  /  'enum'  /  'double'  /  'const'  /  'char'  /  'auto'  /  ID  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_005         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'typedef'  /  'struct'  /  'static'  /  'signed'  /  'short'  /  'register'  /  'long'  /  'int'  /  'float'  /  'extern'  /  'enum'  /  'double'  /  'const'  /  'char'  /  'auto'  /  ID  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_006         <-  (!('}'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'struct'  /  'signed'  /  'short'  /  'long'  /  'int'  /  'float'  /  'enum'  /  'double'  /  'const'  /  'char'  /  ID) EatToken)*
Err_007         <-  (!('}'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'struct'  /  'signed'  /  'short'  /  'long'  /  'int'  /  'float'  /  'enum'  /  'double'  /  'const'  /  'char'  /  ID) EatToken)*
Err_008         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'typedef'  /  'struct'  /  'static'  /  'signed'  /  'short'  /  'register'  /  'long'  /  'int'  /  'float'  /  'extern'  /  'enum'  /  'double'  /  'const'  /  'char'  /  'auto'  /  ID  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_009         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'typedef'  /  'struct'  /  'static'  /  'signed'  /  'short'  /  'register'  /  'long'  /  'int'  /  'float'  /  'extern'  /  'enum'  /  'double'  /  'const'  /  'char'  /  'auto'  /  ID  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_010         <-  (!('}'  /  ',') EatToken)*
Err_011         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '['  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_012         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '['  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_013         <-  (!':' EatToken)*
Err_014         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_015         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_016         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_017         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_018         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_019         <-  (!')' EatToken)*
Err_020         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_021         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_022         <-  (!')' EatToken)*
Err_023         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_024         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_025         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_026         <-  (!')' EatToken)*
Err_027         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_028         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_029         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_030         <-  (!')' EatToken)*
Err_031         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_032         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_033         <-  (!'while' EatToken)*
Err_034         <-  (!'(' EatToken)*
Err_035         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_036         <-  (!')' EatToken)*
Err_037         <-  (!';' EatToken)*
Err_038         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_039         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_040         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_041         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '!') EatToken)*
Err_042         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_043         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_044         <-  (!';' EatToken)*
Err_045         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_046         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_047         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_048         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_049         <-  (!':' EatToken)*
Err_050         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_051         <-  (!('}'  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_052         <-  (!('}'  /  '||'  /  ']'  /  '?'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_053         <-  (!('}'  /  '||'  /  ']'  /  '?'  /  ';'  /  ':'  /  ','  /  ')'  /  '&&') EatToken)*
Err_054         <-  (!('}'  /  '||'  /  '|'  /  ']'  /  '?'  /  ';'  /  ':'  /  ','  /  ')'  /  '&&') EatToken)*
Err_055         <-  (!('}'  /  '||'  /  '|'  /  '^'  /  ']'  /  '?'  /  ';'  /  ':'  /  ','  /  ')'  /  '&&') EatToken)*
Err_056         <-  (!('}'  /  '||'  /  '|'  /  '^'  /  ']'  /  '?'  /  '=='  /  ';'  /  ':'  /  ','  /  ')'  /  '&&'  /  '&'  /  '!=') EatToken)*
Err_057         <-  (!('}'  /  '||'  /  '|'  /  '^'  /  ']'  /  '?'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ':'  /  ','  /  ')'  /  '&&'  /  '&'  /  '!=') EatToken)*
Err_058         <-  (!('}'  /  '||'  /  '|'  /  '^'  /  ']'  /  '?'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  ','  /  ')'  /  '&&'  /  '&'  /  '!=') EatToken)*
Err_059         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_060         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '['  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '.'  /  '->'  /  '-='  /  '--'  /  '-'  /  ','  /  '+='  /  '++'  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_061         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '['  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '.'  /  '->'  /  '-='  /  '--'  /  '-'  /  ','  /  '+='  /  '++'  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_062         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '['  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '.'  /  '->'  /  '-='  /  '--'  /  '-'  /  ','  /  '+='  /  '++'  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*	

Property 	unique
translation_unit <-  SKIP_unique external_decl_unique+_unique^Err_001 !.
external_decl   <-  (function_def  /  decl_unique)_unique
function_def    <-  declarator decl* compound_stat  /  decl_spec function_def
decl_spec       <-  storage_class_spec_unique  /  type_spec  /  type_qualifier
decl            <-  decl_spec init_declarator_list? ';'  /  decl_spec decl
storage_class_spec <-  ('auto'_unique  /  ('register'_unique  /  ('static'_unique  /  ('extern'_unique  /  'typedef'_unique)_unique)_unique)_unique)_unique
type_spec       <-  'void'_unique  /  'char'_unique  /  'short'_unique  /  'int'_unique  /  'long'_unique  /  'float'_unique  /  'double'_unique  /  'signed'_unique  /  'unsigned'_unique  /  typedef_name  /  ('enum' ID? '{'_unique enumerator_unique^Err_002 (','_unique enumerator_unique^Err_003)*_unique '}'_unique^Err_004  /  ('enum'_unique ID_unique^Err_005  /  (struct_or_union ID?_unique '{'_unique^Err_006 struct_decl_unique+_unique^Err_007 '}'_unique^Err_008  /  struct_or_union_unique ID_unique^Err_009)_unique)_unique)_unique
type_qualifier  <-  ('const'_unique  /  'volatile'_unique)_unique
struct_or_union <-  ('struct'_unique  /  'union'_unique)_unique
init_declarator_list <-  init_declarator (',' init_declarator)*
init_declarator <-  declarator '=' initializer_unique  /  declarator
struct_decl     <-  spec_qualifier struct_declarator (',' struct_declarator)* ';'  /  spec_qualifier struct_decl
spec_qualifier_list <-  (type_spec  /  type_qualifier)+
spec_qualifier  <-  type_spec  /  type_qualifier
struct_declarator <-  declarator? ':' const_exp  /  declarator
enumerator      <-  ((ID '=' const_exp_unique  /  ID_unique)_unique)^Err_010
declarator      <-  pointer? direct_declarator
direct_declarator <-  (ID  /  '(' declarator ')') ('[' const_exp? ']'_unique  /  '(' param_type_list ')'  /  '(' id_list? ')')*
pointer         <-  '*' type_qualifier* pointer_unique  /  '*' type_qualifier*
param_type_list <-  param_decl (',' param_decl)* (',' '...'_unique)?
param_decl      <-  decl_spec+ (declarator  /  abstract_declarator)?
id_list         <-  ID (',' ID)*
initializer     <-  '{' initializer (',' initializer)* ','? '}'_unique  /  assignment_exp
type_name       <-  spec_qualifier_list abstract_declarator?
abstract_declarator <-  pointer  /  pointer? direct_abstract_declarator_unique
direct_abstract_declarator <-  '(' abstract_declarator ')'_unique (('['_unique const_exp_unique?_unique ']'_unique^Err_011  /  '('_unique param_type_list_unique?_unique ')'_unique^Err_012)_unique)*_unique
typedef_name    <-  ID
stat            <-  ID ':' stat  /  'case'_unique const_exp_unique^Err_013 ':'_unique^Err_014 stat_unique^Err_015  /  'default'_unique ':'_unique^Err_016 stat_unique^Err_017  /  exp? ';'  /  compound_stat  /  ('if' '('^Err_018 exp^Err_019 ')' stat 'else'_unique stat_unique^Err_020  /  ('if'_unique '('_unique^Err_021 exp_unique^Err_022 ')'_unique^Err_023 stat_unique^Err_024  /  ('switch'_unique '('_unique^Err_025 exp_unique^Err_026 ')'_unique^Err_027 stat_unique^Err_028  /  ('while'_unique '('_unique^Err_029 exp_unique^Err_030 ')'_unique^Err_031 stat_unique^Err_032  /  ('do'_unique stat_unique^Err_033 'while'_unique^Err_034 '('_unique^Err_035 exp_unique^Err_036 ')'_unique^Err_037 ';'_unique^Err_038  /  ('for'_unique '('_unique^Err_039 exp_unique?_unique ';'_unique^Err_040 exp_unique?_unique ';'_unique^Err_041 exp_unique?_unique ')'_unique^Err_042 stat_unique^Err_043  /  ('goto'_unique ID_unique^Err_044 ';'_unique^Err_045  /  ('continue'_unique ';'_unique^Err_046  /  ('break'_unique ';'_unique^Err_047  /  'return'_unique exp_unique?_unique ';'_unique^Err_048)_unique)_unique)_unique)_unique)_unique)_unique)_unique)_unique)_unique
compound_stat   <-  '{' decl* stat* '}'
exp             <-  assignment_exp (',' assignment_exp)*
assignment_exp  <-  unary_exp assignment_operator assignment_exp  /  conditional_exp
assignment_operator <-  '=' !'='  /  ('*='_unique  /  ('/='_unique  /  ('%='_unique  /  ('+='_unique  /  ('-='_unique  /  ('<<='_unique  /  ('>>='_unique  /  ('&='_unique  /  ('^='_unique  /  '|='_unique)_unique)_unique)_unique)_unique)_unique)_unique)_unique)_unique)_unique
conditional_exp <-  logical_or_exp '?'_unique exp_unique^Err_049 ':'_unique^Err_050 conditional_exp_unique^Err_051  /  logical_or_exp
const_exp       <-  conditional_exp
logical_or_exp  <-  logical_and_exp ('||'_unique logical_and_exp_unique^Err_052)*
logical_and_exp <-  inclusive_or_exp ('&&'_unique inclusive_or_exp_unique^Err_053)*
inclusive_or_exp <-  exclusive_or_exp ('|'_unique !'|' exclusive_or_exp_unique^Err_054)*
exclusive_or_exp <-  and_exp ('^'_unique and_exp_unique^Err_055)*
and_exp         <-  equality_exp ('&' !'&' equality_exp_unique)*
equality_exp    <-  relational_exp ((('=='_unique  /  '!='_unique)_unique) relational_exp_unique^Err_056)*
relational_exp  <-  shift_exp ((('<='_unique  /  ('>='_unique  /  ('<'_unique  /  '>'_unique)_unique)_unique)_unique) shift_exp_unique^Err_057)*
shift_exp       <-  additive_exp ((('<<'_unique  /  '>>'_unique)_unique) additive_exp_unique^Err_058)*
additive_exp    <-  multiplicative_exp (('+'  /  '-') multiplicative_exp_unique)*
multiplicative_exp <-  cast_exp (('*'  /  ('/'_unique  /  '%'_unique)_unique) cast_exp_unique)*
cast_exp        <-  '(' type_name ')' cast_exp  /  unary_exp
unary_exp       <-  '++' unary_exp  /  '--' unary_exp  /  unary_operator cast_exp  /  'sizeof'_unique ((type_name  /  unary_exp_unique)_unique)^Err_059  /  postfix_exp
postfix_exp     <-  primary_exp ('[' exp_unique ']'_unique^Err_060  /  '(' (assignment_exp (',' assignment_exp)*)? ')'  /  '.'_unique ID_unique^Err_061  /  '->'_unique ID_unique^Err_062  /  '++'  /  '--')*
primary_exp     <-  ID  /  STRING_unique  /  constant_unique  /  '(' exp ')'
constant        <-  (INT_CONST_unique  /  (CHAR_CONST_unique  /  (FLOAT_CONST_unique  /  ENUMERATION_CONST_unique)_unique)_unique)_unique
unary_operator  <-  '&'  /  '*'  /  '+'  /  '-'  /  ('~'_unique  /  '!'_unique)_unique
COMMENT         <-  '/*' (!'*/' .)* '*/'
INT_CONST       <-  ('0' [xX] XDIGIT+  /  !'0' DIGIT DIGIT*  /  '0' [0-8]*) ([uU] [lL]  /  [lL] [uU]  /  'l'  /  'L'  /  'u'  /  'U')?
FLOAT_CONST     <-  '0x' (('.'  /  XDIGIT+  /  XDIGIT+  /  '.') ([eE] [-+]? XDIGIT+)? [lLfF]?  /  XDIGIT+ [eE] [-+]? XDIGIT+ [lLfF]?)  /  ('.'  /  DIGIT+  /  DIGIT+  /  '.') ([eE] [-+]? DIGIT+)? [lLfF]?  /  DIGIT+ [eE] [-+]? DIGIT+ [lLfF]?
XDIGIT          <-  [0-9a-fA-F]
DIGIT           <-  [0-9]
CHAR_CONST      <-  "'" (%nl  /  !"'" .) "'"
STRING          <-  '"' (%nl  /  !'"' .)* '"'
ESC_CHAR        <-  '\\' ('n'  /  't'  /  'v'  /  'b'  /  'r'  /  'f'  /  'a'  /  '\\'  /  '?'  /  "'"  /  '"'  /  [01234567] [01234567]? [01234567]?  /  'x' XDIGIT)
ENUMERATION_CONST <-  ID
ID              <-  !KEYWORDS [a-zA-Z_] [a-zA-Z_0-9]*
KEYWORDS        <-  ('auto'  /  'double'  /  'int'  /  'struct'  /  'break'  /  'else'  /  'long'  /  'switch'  /  'case'  /  'enum'  /  'register'  /  'typedef'  /  'char'  /  'extern'  /  'return'  /  'union'  /  'const'  /  'float'  /  'short'  /  'unsigned'  /  'continue'  /  'for'  /  'signed'  /  'void'  /  'default'  /  'goto'  /  'sizeof'  /  'volatile'  /  'do'  /  'if'  /  'static'  /  'while') ![a-zA-Z_0-9]
SPACE           <-  [ 	
]  /  COMMENT
SKIP            <-  ([ 	
]  /  COMMENT)*
Token           <-  '~'  /  '}'  /  '||'  /  '|='  /  '|'  /  '{'  /  XDIGIT  /  STRING  /  KEYWORDS  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ESC_CHAR  /  ENUMERATION_CONST  /  DIGIT  /  COMMENT  /  CHAR_CONST  /  '^='  /  '^'  /  ']'  /  '['  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '...'  /  '->'  /  '-='  /  '--'  /  '-'  /  ','  /  '+='  /  '++'  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!='  /  '!'
EatToken        <-  (Token  /  (!SPACE .)+) SKIP
Err_001         <-  (!('volatile'  /  'void'  /  'unsigned'  /  'union'  /  'typedef'  /  'struct'  /  'static'  /  'signed'  /  'short'  /  'register'  /  'long'  /  'int'  /  'float'  /  'extern'  /  'enum'  /  'double'  /  'const'  /  'char'  /  'auto'  /  ID  /  '*'  /  '('  /  !.) EatToken)*
Err_002         <-  (!('}'  /  ',') EatToken)*
Err_003         <-  (!('}'  /  ',') EatToken)*
Err_004         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'typedef'  /  'struct'  /  'static'  /  'signed'  /  'short'  /  'register'  /  'long'  /  'int'  /  'float'  /  'extern'  /  'enum'  /  'double'  /  'const'  /  'char'  /  'auto'  /  ID  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_005         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'typedef'  /  'struct'  /  'static'  /  'signed'  /  'short'  /  'register'  /  'long'  /  'int'  /  'float'  /  'extern'  /  'enum'  /  'double'  /  'const'  /  'char'  /  'auto'  /  ID  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_006         <-  (!('}'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'struct'  /  'signed'  /  'short'  /  'long'  /  'int'  /  'float'  /  'enum'  /  'double'  /  'const'  /  'char'  /  ID) EatToken)*
Err_007         <-  (!('}'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'struct'  /  'signed'  /  'short'  /  'long'  /  'int'  /  'float'  /  'enum'  /  'double'  /  'const'  /  'char'  /  ID) EatToken)*
Err_008         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'typedef'  /  'struct'  /  'static'  /  'signed'  /  'short'  /  'register'  /  'long'  /  'int'  /  'float'  /  'extern'  /  'enum'  /  'double'  /  'const'  /  'char'  /  'auto'  /  ID  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_009         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'typedef'  /  'struct'  /  'static'  /  'signed'  /  'short'  /  'register'  /  'long'  /  'int'  /  'float'  /  'extern'  /  'enum'  /  'double'  /  'const'  /  'char'  /  'auto'  /  ID  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_010         <-  (!('}'  /  ',') EatToken)*
Err_011         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '['  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_012         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '['  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_013         <-  (!':' EatToken)*
Err_014         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_015         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_016         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_017         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_018         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_019         <-  (!')' EatToken)*
Err_020         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_021         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_022         <-  (!')' EatToken)*
Err_023         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_024         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_025         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_026         <-  (!')' EatToken)*
Err_027         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_028         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_029         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_030         <-  (!')' EatToken)*
Err_031         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_032         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_033         <-  (!'while' EatToken)*
Err_034         <-  (!'(' EatToken)*
Err_035         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_036         <-  (!')' EatToken)*
Err_037         <-  (!';' EatToken)*
Err_038         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_039         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_040         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_041         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '!') EatToken)*
Err_042         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_043         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_044         <-  (!';' EatToken)*
Err_045         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_046         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_047         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_048         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_049         <-  (!':' EatToken)*
Err_050         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_051         <-  (!('}'  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_052         <-  (!('}'  /  '||'  /  ']'  /  '?'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_053         <-  (!('}'  /  '||'  /  ']'  /  '?'  /  ';'  /  ':'  /  ','  /  ')'  /  '&&') EatToken)*
Err_054         <-  (!('}'  /  '||'  /  '|'  /  ']'  /  '?'  /  ';'  /  ':'  /  ','  /  ')'  /  '&&') EatToken)*
Err_055         <-  (!('}'  /  '||'  /  '|'  /  '^'  /  ']'  /  '?'  /  ';'  /  ':'  /  ','  /  ')'  /  '&&') EatToken)*
Err_056         <-  (!('}'  /  '||'  /  '|'  /  '^'  /  ']'  /  '?'  /  '=='  /  ';'  /  ':'  /  ','  /  ')'  /  '&&'  /  '&'  /  '!=') EatToken)*
Err_057         <-  (!('}'  /  '||'  /  '|'  /  '^'  /  ']'  /  '?'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ':'  /  ','  /  ')'  /  '&&'  /  '&'  /  '!=') EatToken)*
Err_058         <-  (!('}'  /  '||'  /  '|'  /  '^'  /  ']'  /  '?'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  ','  /  ')'  /  '&&'  /  '&'  /  '!=') EatToken)*
Err_059         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_060         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '['  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '.'  /  '->'  /  '-='  /  '--'  /  '-'  /  ','  /  '+='  /  '++'  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_061         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '['  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '.'  /  '->'  /  '-='  /  '--'  /  '-'  /  ','  /  '+='  /  '++'  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_062         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '['  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '.'  /  '->'  /  '-='  /  '--'  /  '-'  /  ','  /  '+='  /  '++'  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*	

End UPath

Yes: 	array01.c
Yes: 	array02.c
Yes: 	array03.c
Yes: 	assignment01.c
Yes: 	decl01.c
Yes: 	dowhile01.c
Yes: 	enum01.c
Yes: 	enum02.c
Yes: 	enum03.c
Yes: 	enum04.c
Yes: 	enum05.c
Yes: 	expand.c
Yes: 	expbinand.c
Yes: 	expbinor.c
Yes: 	expor.c
Yes: 	expor02.c
Yes: 	expunary01.c
Yes: 	expxor.c
Yes: 	for01.c
Yes: 	for02.c
Yes: 	function01.c
Yes: 	function02.c
Yes: 	global01.c
Yes: 	goto01.c
Yes: 	goto02.c
Yes: 	if01.c
Yes: 	if02.c
Yes: 	main01.c
Yes: 	main02.c
Yes: 	pointer01.c
Yes: 	sizeof01.c
Yes: 	struct01.c
Yes: 	struct02.c
Yes: 	struct03.c
Yes: 	struct04.c
Yes: 	switch01.c
Yes: 	switch02.c
Yes: 	switch03.c
Yes: 	switch04.c
Yes: 	ternary01.c
Yes: 	ternary02.c
Yes: 	while01.c
Yes: 	while02.c
Yes: 	while03.c
Yes: 	while04.c
No: 	braces01.c
r = nil lab = fail line: 2 col: 10
No: 	braces02.c
r = nil lab = fail line: 2 col: 25
No: 	braces03.c
r = nil lab = fail line: 3 col: 17
No: 	brack01.c
r = nil lab = fail line: 4 col: 1
No: 	brack02.c
r = nil lab = fail line: 4 col: 15
No: 	brack03.c
r = nil lab = fail line: 5 col: 9
No: 	brackIf01.c
r = nil lab = fail line: 4 col: 8
No: 	brackSwitch01.c
r = nil lab = fail line: 5 col: 12
No: 	brackWhile01.c
r = nil lab = fail line: 4 col: 11
No: 	brackWhile02.c
r = nil lab = fail line: 6 col: 11
No: 	colon01.c
r = nil lab = fail line: 8 col: 13
No: 	colon02.c
r = nil lab = fail line: 4 col: 43
No: 	declAfterComma01.c
r = nil lab = fail line: 2 col: 11
No: 	endComment01.c
r = nil lab = fail line: 7 col: 1
No: 	enumeratorComma01.c
r = nil lab = fail line: 2 col: 12
No: 	exprAnd01.c
r = nil lab = fail line: 4 col: 13
No: 	exprComma01.c
r = nil lab = fail line: 5 col: 45
No: 	exprExcOr01.c
r = nil lab = fail line: 4 col: 14
No: 	exprIncOr01.c
r = nil lab = fail line: 4 col: 14
No: 	exprLogAnd01.c
r = nil lab = fail line: 4 col: 14
No: 	exprLogOr01.c
r = nil lab = fail line: 4 col: 15
No: 	identifier01.c
r = nil lab = fail line: 4 col: 9
No: 	identifier02.c
r = nil lab = fail line: 6 col: 22
No: 	identifier03.c
r = nil lab = fail line: 6 col: 23
No: 	invalidDecl01.c
r = nil lab = fail line: 3 col: 1
No: 	invalidExpr01.c
r = nil lab = fail line: 4 col: 1
No: 	invalidExpr02.c
r = nil lab = fail line: 7 col: 14
No: 	invalidExpr03.c
r = nil lab = fail line: 6 col: 14
No: 	invalidExpr04.c
r = nil lab = fail line: 4 col: 8
No: 	invalidExpr05.c
r = nil lab = fail line: 5 col: 12
No: 	invalidExpr06.c
r = nil lab = fail line: 4 col: 11
No: 	invalidExpr07.c
r = nil lab = fail line: 6 col: 11
No: 	invalidExpr08.c
r = nil lab = fail line: 5 col: 10
No: 	invalidExpr09.c
r = nil lab = fail line: 5 col: 22
No: 	invalidExpr10.c
r = nil lab = fail line: 8 col: 17
No: 	invalidExprCond101.c
r = nil lab = fail line: 4 col: 20
No: 	invalidExprCond201.c
r = nil lab = fail line: 4 col: 24
No: 	invalidExprInc01.c
r = nil lab = fail line: 5 col: 7
No: 	invalidExprUnary01.c
r = nil lab = fail line: 5 col: 10
No: 	invalidSizeof01.c
r = nil lab = fail line: 4 col: 26
No: 	multBrack01.c
r = nil lab = fail line: 9 col: 27
No: 	multEnumeratorBraces01.c
r = nil lab = fail line: 6 col: 9
No: 	multExpr01.c
r = nil lab = fail line: 9 col: 13
No: 	multExpr02.c
r = nil lab = fail line: 9 col: 9
No: 	multExprBraces01.c
r = nil lab = fail line: 8 col: 9
No: 	multSemicolon01.c
r = nil lab = fail line: 8 col: 23
No: 	multStat01.c
r = nil lab = fail line: 10 col: 5
No: 	semicolon01.c
r = nil lab = fail line: 2 col: 24
No: 	semicolon02.c
r = nil lab = fail line: 5 col: 23
No: 	semicolon03.c
r = nil lab = fail line: 7 col: 1
No: 	semicolon04.c
r = nil lab = fail line: 5 col: 1
No: 	semicolon05.c
r = nil lab = fail line: 7 col: 5
No: 	sqBrack01.c
r = nil lab = fail line: 4 col: 13
No: 	stat01.c
r = nil lab = fail line: 5 col: 1
No: 	stat02.c
r = nil lab = fail line: 6 col: 1
No: 	stat03.c
r = nil lab = fail line: 6 col: 1
No: 	statCase01.c
r = nil lab = fail line: 7 col: 5
No: 	statDefault01.c
r = nil lab = fail line: 7 col: 5
No: 	while01.c
r = nil lab = fail line: 6 col: 1
No: 	zeroDecl01.c
r = nil lab = fail line: 4 col: 1
