/* invalid expression */

int main(){
    int x = 1;
    switch(x){
        case :
            puts("Hello, World");
            break;
    }
}

/*OK:
int main(){
    int x = 1;
    switch(x){
        case 1:
            puts("Hello, World");
            break;
    }
}
*/
