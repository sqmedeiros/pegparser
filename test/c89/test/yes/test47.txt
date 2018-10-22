/* invalid expression after "++" operator */

int main(){
    int x = 1;
    ++;
}

/*OK:
int main(){
    int x = 1;
    ++x;
}
*/
