/*
expected ';'
expected ')'
expected ')'
*/

int main(){
    int x;
    for(x = 0; x < 10, x++){
        if(x > 1{
            printf("x greater than 0\n";)
        }
    }
}

/*OK:

int main(){
    int x;
    for(x = 0; x < 10; x++){
        if(x > 1){
            printf("x greater than 0\n");
        }
    }
}

*/
