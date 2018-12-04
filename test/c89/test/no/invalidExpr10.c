/* expected parameter expression */

int f(int a, int b){
    return a+b;
}

int main(){
    int x = f(1,);
}

/*OK:
int f(int a, int b){
    return a+b;
}

int main(){
    int x = f(1,);
}
*/
