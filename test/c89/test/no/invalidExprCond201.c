/* invalid expression after ':' */

int main(){
    int x = true ? 0 : ;
}

/*OK:
int main(){
    int x = true ? 0 : 1;
}
*/
