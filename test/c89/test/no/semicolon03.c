/* expected ';' */

int main(){
    a:
        printf("hello, world!\n");
    goto a
}

/*OK:
int main(){
    a:
        printf("hello, world!\n");
    goto a;
}
*/
