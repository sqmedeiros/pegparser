int f(  ){ return 1; }

int main(){
    int x;
    for(x = 0; x < 10; x++){
        if(x || f()){
            printf("x greater than 0\n");
        }
    }
}
