/* invalid expression after unary operator */

int main(){
    int x=1, *y;
    y = &;
}

/*OK:
int main(){
    int x=1, *y;
    y = &x;
}
*/
