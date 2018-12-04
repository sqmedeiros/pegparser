/* expected expression after "&&" operator */

int main(){
    if(true&&)
        printf("Hello, World!\n");
}

/*OK:
int main(){
    if(true&&true)
        printf("Hello, World!\n");
}
*/
