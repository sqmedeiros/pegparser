/*
invalid expression
expected '}'
*/

int main(){
    int x = 0, y = 1;
    x =/ y;
    while(true){
        x++;
        if(x == 10)
            break;
}

/*OK:

int main(){
    int x = 0, y = 1;
    x /= y;
    while(true){
        x++;
        if(x == 10)
            break;
    }
}
*/
