/* expected statement after "case" */

int main(){
    int x = 1;
    switch(x){
        case 1:
    }
}

/*OK:
int main(){
    int x = 1;
    switch(x){
        case 1:
        break;
    }
}
*/
