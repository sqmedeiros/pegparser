public class FormalParameterErr {
    public <A> A method(A a, -B b) {
        a.set(2);
        return a;
    }
}