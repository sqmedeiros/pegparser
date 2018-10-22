/* invalid expression */

int main(){
    int x = 1;
    switch(){
        case 1:
        break;
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
