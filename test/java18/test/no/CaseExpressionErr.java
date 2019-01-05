public class CaseExpressionErr {
	public static void main(String[] args) {
		switch (a) {
			case @:
				System.out.println("Ok\n");
				break;
			default:
				/* Nothing */;
		}
	}
}