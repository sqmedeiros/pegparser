/* expected identifier */

int main(){
    goto;
    ret:
        return 0;
}

/*OK:
int main(){
    goto ret;
    ret:
        return 0;
}
*/
