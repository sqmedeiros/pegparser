public class CommaAvaliableErr {
    public <A> A method(A ... c, A a) {
        a.set(2);
        return a;
    }
}