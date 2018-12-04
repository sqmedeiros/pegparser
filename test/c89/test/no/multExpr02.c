/*
invalid expression
expected enumerator after ','
invalid type_name/expression after "sizeof"
invalid expression after "--" operator
*/

enum a{
    ok =,
    = 1
};

int i = sizeof;

int f(){
    return --int;
}

/*OK:

enum a{
    ok = 0,
    bad = 1
};

int i = sizeof int;

int f(){
    return --i;
}
*/
