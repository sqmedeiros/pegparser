/* expected '(' after "while" */

int main(){
    do
        puts("Hello, World");
    while false;
}

/*OK:
int main(){
    do
        puts("Hello, World");
    while(false);
}
*/
