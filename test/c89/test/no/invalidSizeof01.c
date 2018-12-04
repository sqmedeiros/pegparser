/* invalid type_name/expression after "sizeof" */

int main(){
    printf("%d\n", sizeof);
}

/*OK:
int main(){
    printf("%d\n", sizeof int);
}
*/
