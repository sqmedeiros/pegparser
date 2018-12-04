/* invalid expression */

int main(){
    int x[2] = {0,1};
    printf("%d\n", x[]);
}

/*OK:
int main(){
    int x[2] = {0,1};
    printf("%d\n", x[1]);
}
*/
