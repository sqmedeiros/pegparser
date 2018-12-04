/* expected case expression */

int main(){
    int a;
    scanf("%d", &a);
    switch(a){
        case :
            printf("it's 1\n");
            break;
        default:
            printf("not 1\n");
            break;
    }
    return 0;
}

/*OK:
int main(){
    int a;
    scanf("%d", &a);
    switch(a){
        case 1:
            printf("it's 1\n");
            break;
        default:
            printf("not 1\n");
            break;
    }
    return 0;
}
*/
