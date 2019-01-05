public class VariableDeclaratorIdErr1 {
    public <A> A method(A ... @) {
        a.set(2);
        return a;
    }
}