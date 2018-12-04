/* invalid expression */

int main(){
    do
        puts("Hello, World");
    while();
}

/*OK:
int main(){
    do
        puts("Hello, World");
    while(false);
}
*/
