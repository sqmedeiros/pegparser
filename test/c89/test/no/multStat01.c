/*
expected "while"
invalid expression
expected '(' after "if"
*/

int main(){
    int x;
    do break;
    x = 1;
    while(){
        x++;
        if 5==x)
            break;
    }
}

/*OK:

int main(){
    int x;
    do break; while(false);
    x = 1;
    while(true){
        x++;
        if(5==x)
            break;
    }
}
*/
