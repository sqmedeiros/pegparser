/* invalid expression */

int main(){
    int x = 1;
    x += ;
}

/*OK:
int main(){
    int x = 1;
    x += 0;
}
*/
