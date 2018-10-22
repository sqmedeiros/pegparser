/*
invalid expression
expected expression after "||" operator
expected ')'
expected expression after additive operator
*/

int main(){
    int x = ;
    if(x < 3 || ){
        printf(;
    }
    return 0+;
}

/*OK:

int main(){
    int x = 0;
    if(x < 3 || x == 0){
        printf("ok\n");
    }
    return 0;
}
*/
