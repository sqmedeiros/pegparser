/* expected ':' */

int main(){
    printf("Hello, %s!\n", true ? "World" "Wrlod");
}

/*OK:
int main(){
    printf("Hello, %s!\n", true ? "World" : "Wrlod");
}
*/
