/* expected '(' after "if" */

int main(){
    if true {
        puts("Hello, World");
    }
}

/*OK:
int main(){
    if(true){
        puts("Hello, World");
    }
}
*/
