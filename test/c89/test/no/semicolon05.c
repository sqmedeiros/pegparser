/* expected ';' */

int main(){
    while(true){
        printf("Hello, World!\n");
        break
    }
    return 0;
}

/*OK:
int main(){
    while(true){
        printf("Hello, World!\n");
        break;
    }
    return 0;
}
*/
