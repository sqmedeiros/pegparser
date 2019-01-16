/* expected identifier */

struct { int a; } * x;

int main(){
    printf("%d\n", x->1);
}

/*OK:
struct { int a; } x;

int main(){
    printf("%d\n", x->a);
}
*/
