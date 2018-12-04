/* expected statement after "default" */

int main(){
    int x = 1;
    switch(x){
        default:
    }
}

/*OK:
int main(){
    int x = 1;
    switch(x){
        default:
        break;
    }
}
*/
