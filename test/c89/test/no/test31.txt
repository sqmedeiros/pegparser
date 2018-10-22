/* invalid expression after '?' */

int main(){
    int x = true ? : 1;
}

/*OK:
int main(){
    int x = true ? 0 : 1;
}
*/
