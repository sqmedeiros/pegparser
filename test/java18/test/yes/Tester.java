public class Tester {
    public Tester() {
        a.super();
        a.<?>b();
    }

    public Tester() {
        this.super();
        a = (int) b;
    }
}