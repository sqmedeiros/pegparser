package testes;

public class Expression {
	private static int Um() {
		return 1;
	}
	
	public static void main(String[] args) {
		int a = 25 + (2)*30+44-12*(45+3/2)-5;
		System.out.println(a+40*(42+a*30-7)*(Um()));
	}
}