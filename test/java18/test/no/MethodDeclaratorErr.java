public class MethodDeclaratorErr {
    public <A> A -method(A a) {
        a.set(2);
        return a;
    }
}