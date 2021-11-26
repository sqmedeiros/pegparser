Unique Path (UPath)
Uunique
NUMBER	 = 	1
true	 = 	1
integer	 = 	1
>	 = 	1
.	 = 	1
repeat	 = 	1
}	 = 	2
^	 = 	1
string	 = 	1
record	 = 	1
#	 = 	1
not	 = 	1
->	 = 	4
NAME	 = 	13
//	 = 	1
&	 = 	1
local	 = 	4
|	 = 	1
:	 = 	5
%%	 = 	1
=	 = 	7
do	 = 	3
{	 = 	2
<	 = 	1
float	 = 	1
as	 = 	1
function	 = 	1
..	 = 	1
~=	 = 	1
value	 = 	1
if	 = 	1
>>	 = 	1
SKIP	 = 	1
<<	 = 	1
/	 = 	1
~	 = 	2
-	 = 	2
foreign	 = 	1
+	 = 	1
,	 = 	8
>=	 = 	1
until	 = 	1
elseif	 = 	1
<=	 = 	1
==	 = 	1
end	 = 	6
and	 = 	1
or	 = 	1
import	 = 	2
nil	 = 	2
then	 = 	2
false	 = 	1
]	 = 	1
else	 = 	1
[	 = 	1
for	 = 	1
)	 = 	6
*	 = 	1
boolean	 = 	1
(	 = 	6
STRINGLIT	 = 	6
while	 = 	1
return	 = 	1
;	 = 	4
Token 	1	 = 	45
Token 	2	 = 	7
Token 	3	 = 	1
Token 	4	 = 	3
Token 	5	 = 	1
Token 	6	 = 	4
Token 	7	 = 	1
Token 	8	 = 	1
Token 	9	 = 	nil
Token 	10	 = 	nil
Unique tokens (# 44): #, %%, &, *, +, ., .., /, //, <, <<, <=, ==, >, >=, >>, NUMBER, [, ], ^, and, as, boolean, else, elseif, false, float, for, foreign, function, if, integer, not, or, record, repeat, return, string, true, until, value, while, |, ~=
calcTail
program: 	), ], __NAME, __NUMBER, __SKIP, __STRINGLIT, boolean, end, false, float, integer, nil, string, true, value, }
toplevelfunc: 	end
toplevelvar: 	), ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
toplevelrecord: 	end
localopt: 	__empty, local
import: 	), __STRINGLIT
foreign: 	), __STRINGLIT
rettypeopt: 	), __NAME, __empty, boolean, float, integer, nil, string, value, }
paramlist: 	), __NAME, __empty, boolean, float, integer, nil, string, value, }
param: 	), __NAME, boolean, float, integer, nil, string, value, }
decl: 	), __NAME, boolean, float, integer, nil, string, value, }
decllist: 	), __NAME, boolean, float, integer, nil, string, value, }
simpletype: 	__NAME, boolean, float, integer, nil, string, value, }
typelist: 	)
rettype: 	), __NAME, boolean, float, integer, nil, string, value, }
type: 	), __NAME, boolean, float, integer, nil, string, value, }
recordfields: 	), ;, __NAME, boolean, float, integer, nil, string, value, }
recordfield: 	), ;, __NAME, boolean, float, integer, nil, string, value, }
block: 	), ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, end, false, float, integer, nil, return, string, true, value, }
statement: 	), ;, ], __NAME, __NUMBER, __STRINGLIT, boolean, end, false, float, integer, nil, string, true, value, }
elseifstats: 	), ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, end, false, float, integer, nil, return, string, then, true, value, }
elseifstat: 	), ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, end, false, float, integer, nil, return, string, then, true, value, }
elseopt: 	), ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, else, end, false, float, integer, nil, return, string, true, value, }
returnstat: 	), ;, ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, return, string, true, value, }
exp: 	), ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
e1: 	), ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
e2: 	), ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
e3: 	), ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
e4: 	), ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
e5: 	), ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
e6: 	), ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
e7: 	), ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
e8: 	), ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
e9: 	), ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
e10: 	), ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
e11: 	), ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
e12: 	), ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
suffixedexp: 	), ], __NAME, __STRINGLIT, }
expsuffix: 	), ], __NAME, __STRINGLIT, }
prefixexp: 	), __NAME
castexp: 	), ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
simpleexp: 	), ], __NAME, __NUMBER, __STRINGLIT, false, nil, true, }
var: 	), ], __NAME, __STRINGLIT, }
varlist: 	), ], __NAME, __STRINGLIT, }
funcargs: 	), __STRINGLIT, }
explist: 	), ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
initlist: 	}
fieldlist: 	), ,, ;, ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
field: 	), ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
fieldsep: 	,, ;
STRINGLIT: 	", '
RESERVED: 	and, as, boolean, break, do, else, elseif, end, false, float, for, foreign, function, goto, if, import, in, integer, local, nil, not, or, record, repeat, return, string, then, true, until, value, while
NAME: 	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, _, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
NUMBER: 	., 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
COMMENT: 	--, __any
SPACE: 		, 
, , , ,  , __COMMENT
SKIP: 		, 
, , , ,  , __COMMENT, __empty
Global Prefix
program: 	
toplevelfunc: 	), ], __NAME, __NUMBER, __SKIP, __STRINGLIT, boolean, end, false, float, integer, nil, string, true, value, }
toplevelvar: 	), ], __NAME, __NUMBER, __SKIP, __STRINGLIT, boolean, end, false, float, integer, nil, string, true, value, }
toplevelrecord: 	), ], __NAME, __NUMBER, __SKIP, __STRINGLIT, boolean, end, false, float, integer, nil, string, true, value, }
localopt: 	), ], __NAME, __NUMBER, __SKIP, __STRINGLIT, boolean, end, false, float, integer, nil, string, true, value, }
import: 	), ], __NAME, __NUMBER, __SKIP, __STRINGLIT, boolean, end, false, float, integer, nil, string, true, value, }
foreign: 	), ], __NAME, __NUMBER, __SKIP, __STRINGLIT, boolean, end, false, float, integer, nil, string, true, value, }
rettypeopt: 	)
paramlist: 	(
param: 	(, ,
decl: 	,, __empty, for, local
decllist: 	local
simpletype: 	(, ,, ->, :, as, {
typelist: 	(, ,, ->, :, as, {
rettype: 	->, :
type: 	(, ,, :, as, {
recordfields: 	__NAME
recordfield: 	), ;, __NAME, boolean, float, integer, nil, string, value, }
block: 	), __NAME, __empty, boolean, do, else, float, integer, nil, repeat, string, then, value, }
statement: 	), ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, do, else, end, false, float, integer, nil, repeat, string, then, true, value, }
elseifstats: 	), ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, end, false, float, integer, nil, return, string, then, true, value, }
elseifstat: 	), ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, end, false, float, integer, nil, return, string, then, true, value, }
elseopt: 	), ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, end, false, float, integer, nil, return, string, then, true, value, }
returnstat: 	), ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, do, else, end, false, float, integer, nil, repeat, string, then, true, value, }
exp: 	(, ,, ;, =, [, elseif, if, return, until, while, {
e1: 	(, ,, ;, =, [, elseif, if, return, until, while, {
e2: 	(, ,, ;, =, [, elseif, if, or, return, until, while, {
e3: 	(, ,, ;, =, [, and, elseif, if, or, return, until, while, {
e4: 	(, ,, ;, <, <=, =, ==, >, >=, [, and, elseif, if, or, return, until, while, {, ~=
e5: 	(, ,, ;, <, <=, =, ==, >, >=, [, and, elseif, if, or, return, until, while, {, |, ~=
e6: 	(, ,, ;, <, <=, =, ==, >, >=, [, and, elseif, if, or, return, until, while, {, |, ~, ~=
e7: 	&, (, ,, ;, <, <=, =, ==, >, >=, [, and, elseif, if, or, return, until, while, {, |, ~, ~=
e8: 	&, (, ,, .., ;, <, <<, <=, =, ==, >, >=, >>, [, and, elseif, if, or, return, until, while, {, |, ~, ~=
e9: 	&, (, ,, .., ;, <, <<, <=, =, ==, >, >=, >>, [, and, elseif, if, or, return, until, while, {, |, ~, ~=
e10: 	&, (, +, ,, -, .., ;, <, <<, <=, =, ==, >, >=, >>, [, and, elseif, if, or, return, until, while, {, |, ~, ~=
e11: 	%%, &, (, *, +, ,, -, .., /, //, ;, <, <<, <=, =, ==, >, >=, >>, [, ^, and, elseif, if, or, return, until, while, {, |, ~, ~=
e12: 	#, %%, &, (, *, +, ,, -, .., /, //, ;, <, <<, <=, =, ==, >, >=, >>, [, ^, and, elseif, if, not, or, return, until, while, {, |, ~, ~=
suffixedexp: 	#, %%, &, (, ), *, +, ,, -, .., /, //, ;, <, <<, <=, =, ==, >, >=, >>, [, ], ^, __NAME, __NUMBER, __STRINGLIT, __empty, and, boolean, do, else, elseif, end, false, float, if, integer, nil, not, or, repeat, return, string, then, true, until, value, while, {, |, }, ~, ~=
expsuffix: 	), ], __NAME, __STRINGLIT, }
prefixexp: 	#, %%, &, (, ), *, +, ,, -, .., /, //, ;, <, <<, <=, =, ==, >, >=, >>, [, ], ^, __NAME, __NUMBER, __STRINGLIT, __empty, and, boolean, do, else, elseif, end, false, float, if, integer, nil, not, or, repeat, return, string, then, true, until, value, while, {, |, }, ~, ~=
castexp: 	#, %%, &, (, *, +, ,, -, .., /, //, ;, <, <<, <=, =, ==, >, >=, >>, [, ^, and, elseif, if, not, or, return, until, while, {, |, ~, ~=
simpleexp: 	#, %%, &, (, *, +, ,, -, .., /, //, ;, <, <<, <=, =, ==, >, >=, >>, [, ^, and, elseif, if, not, or, return, until, while, {, |, ~, ~=
var: 	), ,, ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, do, else, end, false, float, integer, nil, repeat, string, then, true, value, }
varlist: 	), ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, do, else, end, false, float, integer, nil, repeat, string, then, true, value, }
funcargs: 	), ], __NAME, __STRINGLIT, }
explist: 	(, =, return
initlist: 	#, %%, &, (, ), *, +, ,, -, .., /, //, ;, <, <<, <=, =, ==, >, >=, >>, [, ], ^, __NAME, __STRINGLIT, and, elseif, if, not, or, return, until, while, {, |, }, ~, ~=
fieldlist: 	{
field: 	,, ;, {
fieldsep: 	), ], __NAME, __NUMBER, __STRINGLIT, boolean, false, float, integer, nil, string, true, value, }
STRINGLIT: 	#, %%, &, (, ), *, +, ,, -, .., /, //, ;, <, <<, <=, =, ==, >, >=, >>, [, ], ^, __NAME, __STRINGLIT, and, elseif, if, import, not, or, return, until, while, {, |, }, ~, ~=
RESERVED: 	
NAME: 	#, %%, &, (, ), *, +, ,, -, ->, ., .., /, //, :, ;, <, <<, <=, =, ==, >, >=, >>, [, ], ^, __NAME, __NUMBER, __STRINGLIT, __empty, and, as, boolean, do, else, elseif, end, false, float, for, function, if, integer, local, nil, not, or, record, repeat, return, string, then, true, until, value, while, {, |, }, ~, ~=
NUMBER: 	#, %%, &, (, *, +, ,, -, .., /, //, ;, <, <<, <=, =, ==, >, >=, >>, [, ^, and, elseif, if, not, or, return, until, while, {, |, ~, ~=
COMMENT: 		, 
, , , ,  , __COMMENT
SPACE: 	
SKIP: 	
foi true22
passou três	toplevelrecord	program
UniqueFlwVar	toplevelrecord	rule = 	program	pref = 	), ], __NAME, __NUMBER, __SKIP, __STRINGLIT, boolean, end, false, float, integer, nil, string, true, value, }	flw = 	$, __NAME, function, local, record
UniqueFlwVar	localopt	rule = 	toplevelfunc	pref = 	), ], __NAME, __NUMBER, __SKIP, __STRINGLIT, boolean, end, false, float, integer, nil, string, true, value, }	flw = 	function
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
UniqueFlwVar	typelist	rule = 	rettype	pref = 	->, :	flw = 	->
UniqueFlwVar	simpletype	rule = 	rettype	pref = 	->, :	flw = 	->
UniqueFlwVar	typelist	rule = 	type	pref = 	(, ,, :, as, {	flw = 	->
UniqueFlwVar	simpletype	rule = 	type	pref = 	(, ,, :, as, {	flw = 	->
UniqueFlwVar	type	rule = 	recordfield	pref = 	:	flw = 	;, __NAME, end
passou três	returnstat	block
UniqueFlwVar	block	rule = 	statement	pref = 	do	flw = 	end
foi true22
passou três	exp	statement
UniqueFlwVar	exp	rule = 	statement	pref = 	while	flw = 	do
UniqueFlwVar	block	rule = 	statement	pref = 	do	flw = 	end
foi true22
passou três	block	statement
UniqueFlwVar	block	rule = 	statement	pref = 	repeat	flw = 	until
foi true22
passou três	exp	statement
foi true22
passou três	exp	statement
UniqueFlwVar	exp	rule = 	statement	pref = 	if	flw = 	then
UniqueFlwVar	block	rule = 	statement	pref = 	then	flw = 	else, elseif, end
passou três	elseifstats	statement
UniqueFlwVar	elseifstats	rule = 	statement	pref = 	), ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, end, false, float, integer, nil, return, string, then, true, value, }	flw = 	else, end
passou três	elseopt	statement
UniqueFlwVar	elseopt	rule = 	statement	pref = 	), ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, end, false, float, integer, nil, return, string, then, true, value, }	flw = 	end
foi true22
passou três	decl	statement
UniqueFlwVar	decl	rule = 	statement	pref = 	for	flw = 	=
UniqueFlwVar	exp	rule = 	statement	pref = 	=	flw = 	,
UniqueFlwVar	block	rule = 	statement	pref = 	do	flw = 	end
passou três	elseifstat	elseifstats
foi true22
passou três	exp	elseifstat
UniqueFlwVar	exp	rule = 	elseifstat	pref = 	elseif	flw = 	then
foi true22
passou três	block	elseopt
foi true22
passou três	explist	returnstat
UniqueFlwVar	explist	rule = 	returnstat	pref = 	return	flw = 	;, else, elseif, end, until
foi true22
passou três	e2	e1
foi true22
passou três	e3	e2
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	e4	e3
foi true22
passou três	e5	e4
foi true22
passou três	e6	e5
foi true22
passou três	e7	e6
foi true22
foi true22
passou três	e8	e7
foi true22
passou três	e8	e8
foi true22
foi true22
passou três	e10	e9
foi true22
foi true22
foi true22
foi true22
passou três	e11	e10
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	e11	e12
foi true22
passou três	exp	expsuffix
UniqueFlwVar	exp	rule = 	expsuffix	pref = 	[	flw = 	]
foi true22
UniqueFlwVar	simpleexp	rule = 	castexp	pref = 	#, %%, &, (, *, +, ,, -, .., /, //, ;, <, <<, <=, =, ==, >, >=, >>, [, ^, and, elseif, if, not, or, return, until, while, {, |, ~, ~=	flw = 	as
foi true22
passou três	type	castexp
passou três	initlist	funcargs
unique var 	toplevelrecord
Unique usage	toplevelrecord
unique var 	foreign
Unique usage	foreign
unique var 	paramlist
Unique usage	paramlist
unique var 	rettypeopt
Unique usage	rettypeopt
unique var 	block
unique var 	recordfields
Unique usage	recordfields
unique var 	rettype
unique var 	param
unique var 	param
Unique usage	param
unique var 	type
unique var 	rettype
unique var 	rettype
unique var 	rettype
unique var 	rettype
Unique usage	rettype
unique var 	recordfield
Unique usage	recordfield
unique var 	type
unique var 	block
unique var 	exp
unique var 	block
unique var 	block
unique var 	exp
unique var 	exp
unique var 	block
unique var 	elseifstats
Unique usage	elseifstats
unique var 	elseopt
Unique usage	elseopt
unique var 	decl
unique var 	exp
unique var 	exp
unique var 	exp
unique var 	block
unique var 	elseifstat
Unique usage	elseifstat
unique var 	exp
unique var 	block
Unique usage	block
unique var 	block
Unique usage	block
unique var 	explist
unique var 	e2
unique var 	e3
unique var 	e4
unique var 	e5
unique var 	e6
unique var 	e7
unique var 	e8
unique var 	e8
unique var 	e10
unique var 	e11
unique var 	e11
unique var 	exp
unique var 	type
foi true22
UniqueFlwVar	toplevelrecord	rule = 	program	pref = 	), ], __NAME, __NUMBER, __SKIP, __STRINGLIT, boolean, end, false, float, integer, nil, string, true, value, }	flw = 	$, __NAME, function, local, record
UniqueFlwVar	localopt	rule = 	toplevelfunc	pref = 	), ], __NAME, __NUMBER, __SKIP, __STRINGLIT, boolean, end, false, float, integer, nil, string, true, value, }	flw = 	function
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
UniqueFlwVar	typelist	rule = 	rettype	pref = 	->, :	flw = 	->
UniqueFlwVar	simpletype	rule = 	rettype	pref = 	->, :	flw = 	->
UniqueFlwVar	typelist	rule = 	type	pref = 	(, ,, :, as, {	flw = 	->
UniqueFlwVar	simpletype	rule = 	type	pref = 	(, ,, :, as, {	flw = 	->
UniqueFlwVar	type	rule = 	recordfield	pref = 	:	flw = 	;, __NAME, end
UniqueFlwVar	block	rule = 	statement	pref = 	do	flw = 	end
foi true22
passou três	exp	statement
UniqueFlwVar	exp	rule = 	statement	pref = 	while	flw = 	do
UniqueFlwVar	block	rule = 	statement	pref = 	do	flw = 	end
foi true22
passou três	block	statement
UniqueFlwVar	block	rule = 	statement	pref = 	repeat	flw = 	until
foi true22
passou três	exp	statement
foi true22
passou três	exp	statement
UniqueFlwVar	exp	rule = 	statement	pref = 	if	flw = 	then
UniqueFlwVar	block	rule = 	statement	pref = 	then	flw = 	else, elseif, end
passou três	elseifstats	statement
UniqueFlwVar	elseifstats	rule = 	statement	pref = 	), ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, end, false, float, integer, nil, return, string, then, true, value, }	flw = 	else, end
passou três	elseopt	statement
UniqueFlwVar	elseopt	rule = 	statement	pref = 	), ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, end, false, float, integer, nil, return, string, then, true, value, }	flw = 	end
foi true22
passou três	decl	statement
UniqueFlwVar	decl	rule = 	statement	pref = 	for	flw = 	=
UniqueFlwVar	exp	rule = 	statement	pref = 	=	flw = 	,
UniqueFlwVar	block	rule = 	statement	pref = 	do	flw = 	end
foi true22
passou três	exp	elseifstat
UniqueFlwVar	exp	rule = 	elseifstat	pref = 	elseif	flw = 	then
foi true22
passou três	block	elseopt
foi true22
passou três	explist	returnstat
UniqueFlwVar	explist	rule = 	returnstat	pref = 	return	flw = 	;, else, elseif, end, until
foi true22
passou três	e2	e1
foi true22
passou três	e3	e2
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	e4	e3
foi true22
passou três	e5	e4
foi true22
passou três	e6	e5
foi true22
passou três	e7	e6
foi true22
foi true22
passou três	e8	e7
foi true22
passou três	e8	e8
foi true22
foi true22
passou três	e10	e9
foi true22
foi true22
foi true22
foi true22
passou três	e11	e10
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	e11	e12
foi true22
passou três	exp	expsuffix
UniqueFlwVar	exp	rule = 	expsuffix	pref = 	[	flw = 	]
foi true22
UniqueFlwVar	simpleexp	rule = 	castexp	pref = 	#, %%, &, (, *, +, ,, -, .., /, //, ;, <, <<, <=, =, ==, >, >=, >>, [, ^, and, elseif, if, not, or, return, until, while, {, |, ~, ~=	flw = 	as
foi true22
passou três	type	castexp
passou três	initlist	funcargs
unique var2 	toplevelfunc
unique var 	toplevelrecord
Unique usage	toplevelrecord
unique var2 	import
unique var 	foreign
Unique usage	foreign
unique var 	paramlist
Unique usage	paramlist
unique var 	rettypeopt
Unique usage	rettypeopt
unique var 	block
Unique usage	block
unique var 	recordfields
Unique usage	recordfields
unique var 	rettype
Unique usage	rettype
unique var 	param
Unique usage	param
unique var 	param
Unique usage	param
unique var 	type
unique var 	rettype
Unique usage	rettype
unique var 	rettype
Unique usage	rettype
unique var 	typelist
unique var 	simpletype
unique var 	rettype
Unique usage	rettype
unique var 	rettype
Unique usage	rettype
unique var 	recordfield
Unique usage	recordfield
unique var 	type
unique var 	statement
Unique usage	statement
unique var 	returnstat
Unique usage	returnstat
unique var 	block
Unique usage	block
unique var 	exp
unique var 	block
Unique usage	block
unique var 	block
Unique usage	block
unique var 	exp
unique var 	exp
unique var 	block
Unique usage	block
unique var 	elseifstats
Unique usage	elseifstats
unique var 	elseopt
Unique usage	elseopt
unique var 	decl
unique var 	exp
unique var 	exp
unique var 	exp
unique var 	block
Unique usage	block
unique var 	decllist
Unique usage	decllist
unique var 	explist
unique var 	suffixedexp
unique var 	elseifstat
Unique usage	elseifstat
unique var 	exp
unique var 	block
Unique usage	block
unique var 	block
Unique usage	block
unique var 	explist
unique var 	e2
unique var 	e3
unique var 	e4
unique var 	e5
unique var 	e6
unique var 	e7
unique var 	e8
unique var 	e8
unique var 	e10
unique var 	e11
unique var 	e11
unique var 	exp
unique var 	type
foi true22
UniqueFlwVar	toplevelrecord	rule = 	program	pref = 	), ], __NAME, __NUMBER, __SKIP, __STRINGLIT, boolean, end, false, float, integer, nil, string, true, value, }	flw = 	$, __NAME, function, local, record
UniqueFlwVar	localopt	rule = 	toplevelfunc	pref = 	), ], __NAME, __NUMBER, __SKIP, __STRINGLIT, boolean, end, false, float, integer, nil, string, true, value, }	flw = 	function
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
UniqueFlwVar	typelist	rule = 	rettype	pref = 	->, :	flw = 	->
UniqueFlwVar	simpletype	rule = 	rettype	pref = 	->, :	flw = 	->
UniqueFlwVar	typelist	rule = 	type	pref = 	(, ,, :, as, {	flw = 	->
UniqueFlwVar	simpletype	rule = 	type	pref = 	(, ,, :, as, {	flw = 	->
UniqueFlwVar	type	rule = 	recordfield	pref = 	:	flw = 	;, __NAME, end
UniqueFlwVar	block	rule = 	statement	pref = 	do	flw = 	end
foi true22
passou três	exp	statement
UniqueFlwVar	exp	rule = 	statement	pref = 	while	flw = 	do
UniqueFlwVar	block	rule = 	statement	pref = 	do	flw = 	end
foi true22
passou três	block	statement
UniqueFlwVar	block	rule = 	statement	pref = 	repeat	flw = 	until
foi true22
passou três	exp	statement
foi true22
passou três	exp	statement
UniqueFlwVar	exp	rule = 	statement	pref = 	if	flw = 	then
UniqueFlwVar	block	rule = 	statement	pref = 	then	flw = 	else, elseif, end
passou três	elseifstats	statement
UniqueFlwVar	elseifstats	rule = 	statement	pref = 	), ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, end, false, float, integer, nil, return, string, then, true, value, }	flw = 	else, end
passou três	elseopt	statement
UniqueFlwVar	elseopt	rule = 	statement	pref = 	), ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, end, false, float, integer, nil, return, string, then, true, value, }	flw = 	end
foi true22
passou três	decl	statement
UniqueFlwVar	decl	rule = 	statement	pref = 	for	flw = 	=
UniqueFlwVar	exp	rule = 	statement	pref = 	=	flw = 	,
UniqueFlwVar	block	rule = 	statement	pref = 	do	flw = 	end
foi true22
passou três	exp	elseifstat
UniqueFlwVar	exp	rule = 	elseifstat	pref = 	elseif	flw = 	then
foi true22
passou três	block	elseopt
foi true22
passou três	explist	returnstat
UniqueFlwVar	explist	rule = 	returnstat	pref = 	return	flw = 	;, else, elseif, end, until
foi true22
passou três	e2	e1
foi true22
passou três	e3	e2
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	e4	e3
foi true22
passou três	e5	e4
foi true22
passou três	e6	e5
foi true22
passou três	e7	e6
foi true22
foi true22
passou três	e8	e7
foi true22
passou três	e8	e8
foi true22
foi true22
passou três	e10	e9
foi true22
foi true22
foi true22
foi true22
passou três	e11	e10
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	e11	e12
foi true22
passou três	exp	expsuffix
UniqueFlwVar	exp	rule = 	expsuffix	pref = 	[	flw = 	]
foi true22
UniqueFlwVar	simpleexp	rule = 	castexp	pref = 	#, %%, &, (, *, +, ,, -, .., /, //, ;, <, <<, <=, =, ==, >, >=, >>, [, ^, and, elseif, if, not, or, return, until, while, {, |, ~, ~=	flw = 	as
foi true22
passou três	type	castexp
passou três	initlist	funcargs
unique var2 	toplevelfunc
unique var 	toplevelrecord
Unique usage	toplevelrecord
unique var2 	import
unique var 	foreign
Unique usage	foreign
unique var 	paramlist
Unique usage	paramlist
unique var 	rettypeopt
Unique usage	rettypeopt
unique var 	block
Unique usage	block
unique var 	recordfields
Unique usage	recordfields
unique var 	rettype
Unique usage	rettype
unique var 	param
Unique usage	param
unique var 	param
Unique usage	param
unique var 	type
unique var 	decl
unique var 	decl
unique var 	rettype
Unique usage	rettype
unique var 	rettype
Unique usage	rettype
unique var 	typelist
unique var 	simpletype
unique var 	rettype
Unique usage	rettype
unique var 	rettype
Unique usage	rettype
unique var 	recordfield
Unique usage	recordfield
unique var 	type
unique var 	statement
Unique usage	statement
unique var 	returnstat
Unique usage	returnstat
unique var 	block
Unique usage	block
unique var 	exp
unique var 	block
Unique usage	block
unique var 	block
Unique usage	block
unique var 	exp
unique var 	exp
unique var 	block
Unique usage	block
unique var 	elseifstats
Unique usage	elseifstats
unique var 	elseopt
Unique usage	elseopt
unique var 	decl
unique var 	exp
unique var 	exp
unique var 	exp
unique var 	block
Unique usage	block
unique var 	decllist
Unique usage	decllist
unique var 	explist
unique var 	suffixedexp
unique var 	elseifstat
Unique usage	elseifstat
unique var 	exp
unique var 	block
Unique usage	block
unique var 	block
Unique usage	block
unique var 	explist
unique var 	e2
unique var 	e3
unique var 	e4
unique var 	e5
unique var 	e6
unique var 	e7
unique var 	e8
unique var 	e8
unique var 	e10
unique var 	e11
unique var 	e11
unique var 	exp
unique var 	type
foi true22
UniqueFlwVar	toplevelrecord	rule = 	program	pref = 	), ], __NAME, __NUMBER, __SKIP, __STRINGLIT, boolean, end, false, float, integer, nil, string, true, value, }	flw = 	$, __NAME, function, local, record
UniqueFlwVar	localopt	rule = 	toplevelfunc	pref = 	), ], __NAME, __NUMBER, __SKIP, __STRINGLIT, boolean, end, false, float, integer, nil, string, true, value, }	flw = 	function
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
UniqueFlwVar	typelist	rule = 	rettype	pref = 	->, :	flw = 	->
UniqueFlwVar	simpletype	rule = 	rettype	pref = 	->, :	flw = 	->
UniqueFlwVar	typelist	rule = 	type	pref = 	(, ,, :, as, {	flw = 	->
UniqueFlwVar	simpletype	rule = 	type	pref = 	(, ,, :, as, {	flw = 	->
UniqueFlwVar	type	rule = 	recordfield	pref = 	:	flw = 	;, __NAME, end
UniqueFlwVar	block	rule = 	statement	pref = 	do	flw = 	end
foi true22
passou três	exp	statement
UniqueFlwVar	exp	rule = 	statement	pref = 	while	flw = 	do
UniqueFlwVar	block	rule = 	statement	pref = 	do	flw = 	end
foi true22
passou três	block	statement
UniqueFlwVar	block	rule = 	statement	pref = 	repeat	flw = 	until
foi true22
passou três	exp	statement
foi true22
passou três	exp	statement
UniqueFlwVar	exp	rule = 	statement	pref = 	if	flw = 	then
UniqueFlwVar	block	rule = 	statement	pref = 	then	flw = 	else, elseif, end
passou três	elseifstats	statement
UniqueFlwVar	elseifstats	rule = 	statement	pref = 	), ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, end, false, float, integer, nil, return, string, then, true, value, }	flw = 	else, end
passou três	elseopt	statement
UniqueFlwVar	elseopt	rule = 	statement	pref = 	), ;, ], __NAME, __NUMBER, __STRINGLIT, __empty, boolean, end, false, float, integer, nil, return, string, then, true, value, }	flw = 	end
foi true22
passou três	decl	statement
UniqueFlwVar	decl	rule = 	statement	pref = 	for	flw = 	=
UniqueFlwVar	exp	rule = 	statement	pref = 	=	flw = 	,
UniqueFlwVar	block	rule = 	statement	pref = 	do	flw = 	end
foi true22
passou três	exp	elseifstat
UniqueFlwVar	exp	rule = 	elseifstat	pref = 	elseif	flw = 	then
foi true22
passou três	block	elseopt
foi true22
passou três	explist	returnstat
UniqueFlwVar	explist	rule = 	returnstat	pref = 	return	flw = 	;, else, elseif, end, until
foi true22
passou três	e2	e1
foi true22
passou três	e3	e2
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	e4	e3
foi true22
passou três	e5	e4
foi true22
passou três	e6	e5
foi true22
passou três	e7	e6
foi true22
foi true22
passou três	e8	e7
foi true22
passou três	e8	e8
foi true22
foi true22
passou três	e10	e9
foi true22
foi true22
foi true22
foi true22
passou três	e11	e10
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	e11	e12
foi true22
passou três	exp	expsuffix
UniqueFlwVar	exp	rule = 	expsuffix	pref = 	[	flw = 	]
foi true22
UniqueFlwVar	simpleexp	rule = 	castexp	pref = 	#, %%, &, (, *, +, ,, -, .., /, //, ;, <, <<, <=, =, ==, >, >=, >>, [, ^, and, elseif, if, not, or, return, until, while, {, |, ~, ~=	flw = 	as
foi true22
passou três	type	castexp
passou três	initlist	funcargs
unique var2 	toplevelfunc
unique var 	toplevelrecord
Unique usage	toplevelrecord
unique var2 	import
unique var 	foreign
Unique usage	foreign
unique var 	paramlist
Unique usage	paramlist
unique var 	rettypeopt
Unique usage	rettypeopt
unique var 	block
Unique usage	block
unique var 	recordfields
Unique usage	recordfields
unique var 	rettype
Unique usage	rettype
unique var 	param
Unique usage	param
unique var 	param
Unique usage	param
unique var 	type
unique var 	decl
unique var 	decl
unique var 	rettype
Unique usage	rettype
unique var 	rettype
Unique usage	rettype
unique var 	typelist
unique var 	simpletype
unique var 	rettype
Unique usage	rettype
unique var 	rettype
Unique usage	rettype
unique var 	recordfield
Unique usage	recordfield
unique var 	type
unique var 	statement
Unique usage	statement
unique var 	returnstat
Unique usage	returnstat
unique var 	block
Unique usage	block
unique var 	exp
unique var 	block
Unique usage	block
unique var 	block
Unique usage	block
unique var 	exp
unique var 	exp
unique var 	block
Unique usage	block
unique var 	elseifstats
Unique usage	elseifstats
unique var 	elseopt
Unique usage	elseopt
unique var 	decl
unique var 	exp
unique var 	exp
unique var 	exp
unique var 	block
Unique usage	block
unique var 	decllist
Unique usage	decllist
unique var 	explist
unique var 	suffixedexp
unique var 	elseifstat
Unique usage	elseifstat
unique var 	exp
unique var 	block
Unique usage	block
unique var 	block
Unique usage	block
unique var 	explist
unique var 	e2
unique var 	e3
unique var 	e4
unique var 	e5
unique var 	e6
unique var 	e7
unique var 	e8
unique var 	e8
unique var 	e10
unique var 	e11
unique var 	e11
unique var 	exp
unique var 	type
insideLoop: toplevelfunc, toplevelvar, toplevelrecord, localopt, import, foreign, param, decl, simpletype, typelist, type, recordfield, statement, elseifstat, returnstat, exp, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12, suffixedexp, expsuffix, prefixexp, castexp, simpleexp, var, varlist, funcargs, explist, initlist, fieldlist, field, fieldsep, 
Unique vars: program, toplevelrecord, foreign, rettypeopt, paramlist, param, decllist, rettype, recordfields, recordfield, block, statement, elseifstats, elseifstat, elseopt, returnstat, 
matchUPath: program, toplevelfunc, toplevelrecord, import, foreign, param, decllist, rettype, recordfields, recordfield, block, statement, elseifstat, returnstat, e11, 
Adding labels: Err_1, Err_2, Err_3, Err_4, Err_5, Err_6, Err_7, Err_8, Err_9, Err_10, Err_11, Err_12, Err_13, Err_14, Err_15, Err_16, Err_17, Err_18, Err_19, Err_20, Err_21, Err_22, Err_23, Err_24, Err_25, Err_26, Err_27, Err_28, Err_29, Err_30, Err_31, Err_32, Err_33, Err_34, Err_35, Err_36, Err_37, Err_38, Err_39, Err_40, Err_41, Err_42, Err_43, Err_44, Err_45, Err_46, Err_47, Err_48, Err_49, Err_50, Err_51, Err_52, Err_53, Err_54, Err_55, Err_56, Err_57, Err_58, Err_59, Err_60, Err_61, Err_62, Err_63, Err_64, Err_65, Err_66, Err_67, Err_68, 

Property 	nil
program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* !.
toplevelfunc    <-  localopt 'function' NAME^Err_001 '('^Err_002 paramlist ')'^Err_003 rettypeopt block 'end'^Err_004
toplevelvar     <-  localopt decl '=' exp
toplevelrecord  <-  'record' NAME^Err_005 recordfields^Err_006 'end'^Err_007
localopt        <-  'local'?
import          <-  'local' NAME '=' 'import' ('(' STRINGLIT^Err_008 ')'^Err_009  /  STRINGLIT)^Err_010
foreign         <-  'local' NAME^Err_011 '='^Err_012 'foreign'^Err_013 'import'^Err_014 ('(' STRINGLIT^Err_015 ')'^Err_016  /  STRINGLIT)^Err_017
rettypeopt      <-  (':' rettype^Err_018)?
paramlist       <-  (param (',' param^Err_019)*)?
param           <-  NAME ':'^Err_020 type^Err_021
decl            <-  NAME (':' type)?
decllist        <-  decl^Err_022 (',' decl^Err_023)*
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type '}'
typelist        <-  '(' (type (',' type)*)? ')'
rettype         <-  (typelist '->' rettype^Err_024  /  simpletype '->' rettype^Err_025  /  typelist  /  simpletype)^Err_026
type            <-  typelist '->' rettype^Err_027  /  simpletype '->' rettype^Err_028  /  simpletype
recordfields    <-  recordfield+^Err_029
recordfield     <-  NAME ':'^Err_030 type^Err_031 ';'?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'^Err_032  /  'while' exp^Err_033 'do'^Err_034 block 'end'^Err_035  /  'repeat' block 'until'^Err_036 exp^Err_037  /  'if' exp^Err_038 'then'^Err_039 block elseifstats elseopt 'end'^Err_040  /  'for' decl^Err_041 '='^Err_042 exp^Err_043 ','^Err_044 exp^Err_045 (',' exp^Err_046)? 'do'^Err_047 block 'end'^Err_048  /  'local' decllist^Err_049 '='^Err_050 explist^Err_051  /  varlist '=' explist  /  suffixedexp
elseifstats     <-  elseifstat*
elseifstat      <-  'elseif' exp^Err_052 'then'^Err_053 block
elseopt         <-  ('else' block)?
returnstat      <-  'return' explist? ';'?
exp             <-  e1
e1              <-  e2 ('or' e2^Err_054)*
e2              <-  e3 ('and' e3^Err_055)*
e3              <-  e4 (('=='  /  '~='  /  '<='  /  '>='  /  '<'  /  '>') e4^Err_056)*
e4              <-  e5 ('|' e5^Err_057)*
e5              <-  e6 ('~' !'=' e6^Err_058)*
e6              <-  e7 ('&' e7^Err_059)*
e7              <-  e8 (('<<'  /  '>>') e8^Err_060)*
e8              <-  e9 ('..' e8^Err_061)?
e9              <-  e10 (('+'  /  '-') e10^Err_062)*
e10             <-  e11 (('*'  /  '%%'  /  '/'  /  '//') e11^Err_063)*
e11             <-  ('not'  /  '#'  /  '-'  /  '~')* e12
e12             <-  castexp ('^' e11^Err_064)?
suffixedexp     <-  prefixexp expsuffix+
expsuffix       <-  funcargs  /  ':' NAME funcargs  /  '[' exp^Err_065 ']'^Err_066  /  '.' !'.' NAME^Err_067
prefixexp       <-  NAME  /  '(' exp ')'
castexp         <-  simpleexp 'as' type^Err_068  /  simpleexp
simpleexp       <-  'nil'  /  'false'  /  'true'  /  NUMBER  /  STRINGLIT  /  initlist  /  suffixedexp  /  prefixexp
var             <-  suffixedexp  /  NAME !expsuffix
varlist         <-  var (',' var)*
funcargs        <-  '(' explist? ')'  /  initlist  /  STRINGLIT
explist         <-  exp (',' exp)*
initlist        <-  '{' fieldlist? '}'
fieldlist       <-  field (fieldsep field)* fieldsep?
field           <-  (NAME '=')? exp
fieldsep        <-  ';'  /  ','
STRINGLIT       <-  '"' (!'"' .)* '"'  /  "'" (!"'" .)* "'"
RESERVED        <-  ('and'  /  'as'  /  'boolean'  /  'break'  /  'do'  /  'elseif'  /  'else'  /  'end'  /  'float'  /  'foreign'  /  'for'  /  'false'  /  'function'  /  'goto'  /  'if'  /  'import'  /  'integer'  /  'in'  /  'local'  /  'nil'  /  'not'  /  'or'  /  'record'  /  'repeat'  /  'return'  /  'string'  /  'then'  /  'true'  /  'until'  /  'value'  /  'while') ![a-zA-Z_0-9]
NAME            <-  !RESERVED [a-zA-Z_] [a-zA-Z_0-9]*
NUMBER          <-  [0-9]+ ('.' !'.' [0-9]*)?
COMMENT         <-  '--' (!%nl .)*
SPACE           <-  [ 	
]  /  COMMENT
SKIP            <-  ([ 	
]  /  COMMENT)*
Token           <-  '~='  /  '~'  /  '}'  /  '|'  /  '{'  /  STRINGLIT  /  RESERVED  /  NUMBER  /  NAME  /  COMMENT  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '->'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  '#'
EatToken        <-  (Token  /  (!SPACE .)+) SKIP
Err_001         <-  (!'(' EatToken)*
Err_002         <-  (!(NAME  /  ')') EatToken)*
Err_003         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  ':'  /  '(') EatToken)*
Err_004         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_005         <-  (!NAME EatToken)*
Err_006         <-  (!'end' EatToken)*
Err_007         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_008         <-  (!')' EatToken)*
Err_009         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_010         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_011         <-  (!'=' EatToken)*
Err_012         <-  (!'foreign' EatToken)*
Err_013         <-  (!'import' EatToken)*
Err_014         <-  (!(STRINGLIT  /  '(') EatToken)*
Err_015         <-  (!')' EatToken)*
Err_016         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_017         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_018         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_019         <-  (!(','  /  ')') EatToken)*
Err_020         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
Err_021         <-  (!(','  /  ')') EatToken)*
Err_022         <-  (!('='  /  ',') EatToken)*
Err_023         <-  (!('='  /  ',') EatToken)*
Err_024         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_025         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_026         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_027         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_028         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_029         <-  (!('end'  /  NAME) EatToken)*
Err_030         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
Err_031         <-  (!('end'  /  NAME  /  ';') EatToken)*
Err_032         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_033         <-  (!'do' EatToken)*
Err_034         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_035         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_036         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_037         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_038         <-  (!'then' EatToken)*
Err_039         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_040         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_041         <-  (!'=' EatToken)*
Err_042         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_043         <-  (!',' EatToken)*
Err_044         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_045         <-  (!('do'  /  ',') EatToken)*
Err_046         <-  (!'do' EatToken)*
Err_047         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_048         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_049         <-  (!'=' EatToken)*
Err_050         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_051         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_052         <-  (!'then' EatToken)*
Err_053         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_054         <-  (!('}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ']'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_055         <-  (!('}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_056         <-  (!('~='  /  '}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_057         <-  (!('~='  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_058         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_059         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_060         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_061         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_062         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '..'  /  '-'  /  ','  /  '+'  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_063         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_064         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_065         <-  (!']' EatToken)*
Err_066         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_067         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_068         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*	

Property 	unique
program         <-  SKIP_unique ((toplevelfunc_unique  /  (toplevelvar  /  (toplevelrecord_unique  /  (import_unique  /  foreign_unique)_unique)_unique)_unique)_unique)*_unique !.
toplevelfunc    <-  localopt 'function'_unique NAME_unique^Err_001 '('_unique^Err_002 paramlist_unique ')'_unique^Err_003 rettypeopt_unique block_unique 'end'_unique^Err_004
toplevelvar     <-  localopt decl '=' exp
toplevelrecord  <-  'record'_unique NAME_unique^Err_005 recordfields_unique^Err_006 'end'_unique^Err_007
localopt        <-  'local'?
import          <-  'local' NAME '=' 'import'_unique (('('_unique STRINGLIT_unique^Err_008 ')'_unique^Err_009  /  STRINGLIT_unique)_unique)^Err_010
foreign         <-  'local'_unique NAME_unique^Err_011 '='_unique^Err_012 'foreign'_unique^Err_013 'import'_unique^Err_014 (('('_unique STRINGLIT_unique^Err_015 ')'_unique^Err_016  /  STRINGLIT_unique)_unique)^Err_017
rettypeopt      <-  (':'_unique rettype_unique^Err_018)?_unique
paramlist       <-  (param_unique (','_unique param_unique^Err_019)*_unique)?_unique
param           <-  NAME_unique ':'_unique^Err_020 type_unique^Err_021
decl            <-  NAME (':' type)?
decllist        <-  decl_unique^Err_022 (','_unique decl_unique^Err_023)*_unique
simpletype      <-  'nil'  /  'boolean'_unique  /  'integer'_unique  /  'float'_unique  /  'string'_unique  /  'value'_unique  /  NAME  /  '{' type '}'
typelist        <-  '(' (type (',' type)*)? ')'
rettype         <-  ((typelist '->'_unique rettype_unique^Err_024  /  (simpletype '->'_unique rettype_unique^Err_025  /  (typelist_unique  /  simpletype_unique)_unique)_unique)_unique)^Err_026
type            <-  typelist '->'_unique rettype_unique^Err_027  /  simpletype '->'_unique rettype_unique^Err_028  /  simpletype
recordfields    <-  recordfield_unique+_unique^Err_029
recordfield     <-  NAME_unique ':'_unique^Err_030 type_unique^Err_031 ';'_unique?_unique
block           <-  statement_unique*_unique returnstat_unique?_unique
statement       <-  (';'_unique  /  ('do'_unique block_unique 'end'_unique^Err_032  /  ('while'_unique exp_unique^Err_033 'do'_unique^Err_034 block_unique 'end'_unique^Err_035  /  ('repeat'_unique block_unique 'until'_unique^Err_036 exp_unique^Err_037  /  ('if'_unique exp_unique^Err_038 'then'_unique^Err_039 block_unique elseifstats_unique elseopt_unique 'end'_unique^Err_040  /  ('for'_unique decl_unique^Err_041 '='_unique^Err_042 exp_unique^Err_043 ','_unique^Err_044 exp_unique^Err_045 (','_unique exp_unique^Err_046)?_unique 'do'_unique^Err_047 block_unique 'end'_unique^Err_048  /  ('local'_unique decllist_unique^Err_049 '='_unique^Err_050 explist_unique^Err_051  /  (varlist '=' explist  /  suffixedexp_unique)_unique)_unique)_unique)_unique)_unique)_unique)_unique)_unique
elseifstats     <-  elseifstat_unique*_unique
elseifstat      <-  'elseif'_unique exp_unique^Err_052 'then'_unique^Err_053 block_unique
elseopt         <-  ('else'_unique block_unique)?_unique
returnstat      <-  'return'_unique explist_unique?_unique ';'_unique?_unique
exp             <-  e1
e1              <-  e2 ('or'_unique e2_unique^Err_054)*
e2              <-  e3 ('and'_unique e3_unique^Err_055)*
e3              <-  e4 ((('=='_unique  /  ('~='_unique  /  ('<='_unique  /  ('>='_unique  /  ('<'_unique  /  '>'_unique)_unique)_unique)_unique)_unique)_unique) e4_unique^Err_056)*
e4              <-  e5 ('|'_unique e5_unique^Err_057)*
e5              <-  e6 ('~'_unique !'=' e6_unique^Err_058)*
e6              <-  e7 ('&'_unique e7_unique^Err_059)*
e7              <-  e8 ((('<<'_unique  /  '>>'_unique)_unique) e8_unique^Err_060)*
e8              <-  e9 ('..'_unique e8_unique^Err_061)?
e9              <-  e10 ((('+'_unique  /  '-'_unique)_unique) e10_unique^Err_062)*
e10             <-  e11 ((('*'_unique  /  ('%%'_unique  /  ('/'_unique  /  '//'_unique)_unique)_unique)_unique) e11_unique^Err_063)*
e11             <-  (('not'_unique  /  ('#'_unique  /  ('-'_unique  /  '~'_unique)_unique)_unique)_unique)* e12_unique
e12             <-  castexp ('^'_unique e11_unique^Err_064)?
suffixedexp     <-  prefixexp expsuffix+
expsuffix       <-  funcargs  /  ':' NAME funcargs  /  ('['_unique exp_unique^Err_065 ']'_unique^Err_066  /  '.'_unique !'.' NAME_unique^Err_067)_unique
prefixexp       <-  NAME  /  '(' exp ')'
castexp         <-  simpleexp 'as'_unique type_unique^Err_068  /  simpleexp
simpleexp       <-  'nil'  /  'false'_unique  /  'true'_unique  /  NUMBER_unique  /  STRINGLIT  /  initlist  /  suffixedexp  /  prefixexp
var             <-  suffixedexp  /  NAME !expsuffix
varlist         <-  var (',' var)*
funcargs        <-  '(' explist? ')'  /  (initlist_unique  /  STRINGLIT_unique)_unique
explist         <-  exp (',' exp)*
initlist        <-  '{' fieldlist? '}'
fieldlist       <-  field (fieldsep field)* fieldsep?
field           <-  (NAME '=')? exp
fieldsep        <-  ';'  /  ','
STRINGLIT       <-  '"' (!'"' .)* '"'  /  "'" (!"'" .)* "'"
RESERVED        <-  ('and'  /  'as'  /  'boolean'  /  'break'  /  'do'  /  'elseif'  /  'else'  /  'end'  /  'float'  /  'foreign'  /  'for'  /  'false'  /  'function'  /  'goto'  /  'if'  /  'import'  /  'integer'  /  'in'  /  'local'  /  'nil'  /  'not'  /  'or'  /  'record'  /  'repeat'  /  'return'  /  'string'  /  'then'  /  'true'  /  'until'  /  'value'  /  'while') ![a-zA-Z_0-9]
NAME            <-  !RESERVED [a-zA-Z_] [a-zA-Z_0-9]*
NUMBER          <-  [0-9]+ ('.' !'.' [0-9]*)?
COMMENT         <-  '--' (!%nl .)*
SPACE           <-  [ 	
]  /  COMMENT
SKIP            <-  ([ 	
]  /  COMMENT)*
Token           <-  '~='  /  '~'  /  '}'  /  '|'  /  '{'  /  STRINGLIT  /  RESERVED  /  NUMBER  /  NAME  /  COMMENT  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '->'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  '#'
EatToken        <-  (Token  /  (!SPACE .)+) SKIP
Err_001         <-  (!'(' EatToken)*
Err_002         <-  (!(NAME  /  ')') EatToken)*
Err_003         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  ':'  /  '(') EatToken)*
Err_004         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_005         <-  (!NAME EatToken)*
Err_006         <-  (!'end' EatToken)*
Err_007         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_008         <-  (!')' EatToken)*
Err_009         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_010         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_011         <-  (!'=' EatToken)*
Err_012         <-  (!'foreign' EatToken)*
Err_013         <-  (!'import' EatToken)*
Err_014         <-  (!(STRINGLIT  /  '(') EatToken)*
Err_015         <-  (!')' EatToken)*
Err_016         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_017         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_018         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_019         <-  (!(','  /  ')') EatToken)*
Err_020         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
Err_021         <-  (!(','  /  ')') EatToken)*
Err_022         <-  (!('='  /  ',') EatToken)*
Err_023         <-  (!('='  /  ',') EatToken)*
Err_024         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_025         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_026         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_027         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_028         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_029         <-  (!('end'  /  NAME) EatToken)*
Err_030         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
Err_031         <-  (!('end'  /  NAME  /  ';') EatToken)*
Err_032         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_033         <-  (!'do' EatToken)*
Err_034         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_035         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_036         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_037         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_038         <-  (!'then' EatToken)*
Err_039         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_040         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_041         <-  (!'=' EatToken)*
Err_042         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_043         <-  (!',' EatToken)*
Err_044         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_045         <-  (!('do'  /  ',') EatToken)*
Err_046         <-  (!'do' EatToken)*
Err_047         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_048         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_049         <-  (!'=' EatToken)*
Err_050         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_051         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_052         <-  (!'then' EatToken)*
Err_053         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_054         <-  (!('}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ']'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_055         <-  (!('}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_056         <-  (!('~='  /  '}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_057         <-  (!('~='  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_058         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_059         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_060         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_061         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_062         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '..'  /  '-'  /  ','  /  '+'  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_063         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_064         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_065         <-  (!']' EatToken)*
Err_066         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_067         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_068         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*	

End UPath

Yes: 	arraytype01.titan
Yes: 	arraytype02.titan
Yes: 	assign01.titan
Yes: 	comment01.titan
Yes: 	dowhile01.titan
Yes: 	expression01.titan
Yes: 	expression02.titan
Yes: 	expression03.titan
Yes: 	expression04.titan
Yes: 	expression05.titan
Yes: 	expression06.titan
Yes: 	expression07.titan
Yes: 	expression08.titan
Yes: 	expressionCall01.titan
Yes: 	expressionCall02.titan
Yes: 	expressionCall03.titan
Yes: 	expressionCall04.titan
Yes: 	expressionCall05.titan
Yes: 	expressionCall06.titan
Yes: 	expressionCall07.titan
Yes: 	expressionCall08.titan
Yes: 	expressionCall09.titan
Yes: 	expressionCall10.titan
Yes: 	expressionCast01.titan
Yes: 	expressionCast02.titan
Yes: 	expressionCast03.titan
Yes: 	expressionCast04.titan
Yes: 	expressionOp01.titan
Yes: 	expressionOp02.titan
Yes: 	expressionOp03.titan
Yes: 	expressionOp04.titan
Yes: 	expressionOp05.titan
Yes: 	expressionOp06.titan
Yes: 	expressionString01.titan
Yes: 	expressionString02.titan
Yes: 	expressionString03.titan
Yes: 	expressionString04.titan
Yes: 	expressionString05.titan
Yes: 	for01.titan
Yes: 	foreign01.titan
Yes: 	functiontype01.titan
Yes: 	functiontype02.titan
Yes: 	functiontype03.titan
Yes: 	functiontype04.titan
Yes: 	functiontype05.titan
Yes: 	functiontype06.titan
Yes: 	functiontype07.titan
Yes: 	functiontype08.titan
Yes: 	if01.titan
Yes: 	if02.titan
Yes: 	if03.titan
Yes: 	if04.titan
Yes: 	import01.titan
Yes: 	moduleMember01.titan
Yes: 	primitivetype01.titan
Yes: 	primitivetype02.titan
Yes: 	record01.titan
Yes: 	record02.titan
Yes: 	record03.titan
Yes: 	record04.titan
Yes: 	record05.titan
Yes: 	record06.titan
Yes: 	record07.titan
Yes: 	record08.titan
Yes: 	record09.titan
Yes: 	record10.titan
Yes: 	record11.titan
Yes: 	record12.titan
Yes: 	repeat01.titan
Yes: 	return01.titan
Yes: 	return02.titan
Yes: 	return03.titan
Yes: 	return04.titan
Yes: 	return05.titan
Yes: 	return06.titan
Yes: 	suffixOp01.titan
Yes: 	table01.titan
Yes: 	table02.titan
Yes: 	table03.titan
Yes: 	toplevelfunction01.titan
Yes: 	toplevelfunction02.titan
Yes: 	toplevelfunction03.titan
Yes: 	toplevelfunction04.titan
Yes: 	toplevelvar01.titan
Yes: 	toplevelvar02.titan
Yes: 	vardec01.titan
Yes: 	while01.titan
No: 	assignAssign01.titan
r = nil lab = fail line: 3 col: 1
No: 	assignFor01.titan
r = nil lab = fail line: 2 col: 9
No: 	assignLocal01.titan
r = nil lab = fail line: 2 col: 11
No: 	assignVar01.titan
r = nil lab = fail line: 1 col: 3
No: 	castMissingType01.titan
r = nil lab = fail line: 4 col: 1
No: 	colonRecordField01.titan
r = nil lab = fail line: 2 col: 5
No: 	commaFor01.titan
r = nil lab = fail line: 2 col: 12
No: 	declFor01.titan
r = nil lab = fail line: 2 col: 6
No: 	declLocal01.titan
r = nil lab = fail line: 2 col: 9
No: 	declLocal02.titan
r = nil lab = fail line: 2 col: 8
No: 	declLocal03.titan
r = nil lab = fail line: 2 col: 15
No: 	declLocal04.titan
r = nil lab = fail line: 2 col: 8
No: 	declParList01.titan
r = nil lab = fail line: 2 col: 11
No: 	declParList02.titan
r = nil lab = fail line: 1 col: 22
No: 	doFor01.titan
r = nil lab = fail line: 3 col: 2
No: 	doWhile01.titan
r = nil lab = fail line: 3 col: 3
No: 	endBlock01.titan
r = nil lab = fail line: 4 col: 1
No: 	endFor01.titan
r = nil lab = fail line: 4 col: 2
No: 	endFunc01.titan
r = nil lab = fail line: 3 col: 2
No: 	endFunc02.titan
r = nil lab = fail line: 2 col: 9
No: 	endFunc03.titan
r = nil lab = fail line: 4 col: 1
No: 	endIf01.titan
r = nil lab = fail line: 5 col: 2
No: 	endRecord01.titan
r = nil lab = fail line: 3 col: 1
No: 	endWhile01.titan
r = nil lab = fail line: 5 col: 2
No: 	exp1For01.titan
r = nil lab = fail line: 2 col: 10
No: 	exp2For01.titan
r = nil lab = fail line: 3 col: 1
No: 	exp3For01.titan
r = nil lab = fail line: 3 col: 1
No: 	expAssign01.titan
r = nil lab = fail line: 2 col: 6
No: 	expAssign02.titan
r = nil lab = fail line: 2 col: 13
No: 	expAssign03.titan
r = nil lab = fail line: 4 col: 1
No: 	expElseIf01.titan
r = nil lab = fail line: 5 col: 1
No: 	expExpList01.titan
r = nil lab = fail line: 4 col: 1
No: 	expExpList02.titan
r = nil lab = fail line: 2 col: 11
No: 	expExpSuf01.titan
r = nil lab = fail line: 2 col: 8
No: 	expFieldList01.titan
r = nil lab = fail line: 2 col: 11
No: 	expIf01.titan
r = nil lab = fail line: 3 col: 1
No: 	expLocal01.titan
r = nil lab = fail line: 4 col: 1
No: 	expRepeat01.titan
r = nil lab = fail line: 6 col: 1
No: 	expSimpleExp01.titan
r = nil lab = fail line: 2 col: 7
No: 	expStat01.titan
r = nil lab = fail line: 3 col: 1
No: 	expStat02.titan
r = nil lab = fail line: 2 col: 2
No: 	expVarDec01.titan
r = nil lab = fail line: 2 col: 1
No: 	expVarList01.titan
r = nil lab = fail line: 2 col: 5
No: 	expWhile01.titan
r = nil lab = fail line: 3 col: 1
No: 	fieldRecord01.titan
r = nil lab = fail line: 3 col: 1
No: 	funcArgsExpSuf01.titan
r = nil lab = fail line: 2 col: 12
No: 	lParPList01.titan
r = nil lab = fail line: 1 col: 14
No: 	nameColonExpSuf01.titan
r = nil lab = fail line: 2 col: 10
No: 	nameDotExpSuf01.titan
r = nil lab = fail line: 2 col: 8
No: 	nameFunc01.titan
r = nil lab = fail line: 1 col: 17
No: 	nameFunc02.titan
r = nil lab = fail line: 1 col: 10
No: 	nameImport01.titan
r = nil lab = fail line: 1 col: 7
No: 	nameRecord01.titan
r = nil lab = fail line: 2 col: 1
No: 	opExp01.titan
r = nil lab = fail line: 4 col: 1
No: 	paramSemicolon01.titan
r = nil lab = fail line: 1 col: 15
No: 	rBracketExpSuf01.titan
r = nil lab = fail line: 3 col: 1
No: 	rCurlyInitList01.titan
r = nil lab = fail line: 3 col: 1
No: 	rCurlyType01.titan
r = nil lab = fail line: 1 col: 15
No: 	rParFuncArgs01.titan
r = nil lab = fail line: 3 col: 1
No: 	rParImport01.titan
r = nil lab = fail line: 2 col: 1
No: 	rParPList01.titan
r = nil lab = fail line: 1 col: 16
No: 	rParSimpleExp01.titan
r = nil lab = fail line: 3 col: 1
No: 	rParenTypelist01.titan
r = nil lab = fail line: 1 col: 21
No: 	stringImport01.titan
r = nil lab = fail line: 2 col: 1
No: 	stringLParImport01.titan
r = nil lab = fail line: 1 col: 22
No: 	thenElseIf01.titan
r = nil lab = fail line: 5 col: 2
No: 	thenIf01.titan
r = nil lab = fail line: 3 col: 3
No: 	typeDecl01.titan
r = nil lab = fail line: 1 col: 18
No: 	typeFunc01.titan
r = nil lab = fail line: 2 col: 7
No: 	typeRecordField01.titan
r = nil lab = fail line: 3 col: 1
No: 	typeReturnTypes01.titan
r = nil lab = fail line: 1 col: 20
No: 	typeType01.titan
r = nil lab = fail line: 1 col: 11
No: 	typelistType01.titan
r = nil lab = fail line: 1 col: 13
No: 	untilRepeat01.titan
r = nil lab = fail line: 5 col: 1
