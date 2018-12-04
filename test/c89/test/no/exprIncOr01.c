/* expected expression after '|' operator */

int main(){
    if(false|)
        printf("Hello, World!\n");
}

/*OK:
int main(){
    if(false|true)
        printf("Hello, World!\n");
}
*/
