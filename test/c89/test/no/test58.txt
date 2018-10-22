/*
expected ';'
expected ';'
expected ')'
expected '}'
*/

bool f(){ return true }

int main(){
    int x;
    for(x = 0; x < 10, x++){
        if(x || f(){
            printf("x greater than 0\n"));
        }
    }
}

/*OK:

bool f(){ return true; }

int main(){
    int x;
    for(x = 0; x < 10; x++){
        if(x || f()){
            printf("x greater than 0\n");
        }
    }
}
*/
