package testes;

import java.util.Arrays;
import java.util.List;

public class LambdaExpressions {
	public static void main(String[] args) {
		Runnable r = () -> System.out.println("Thread com função lambda!");
		new Thread(r).start();
		
		System.out.println("Imprime todos os elementos da lista!");
		List<Integer> list = Arrays.asList(1, 2, 3, 4, 5, 6, 7);
		list.forEach(n -> System.out.print(n + " "));
		System.out.println();
		
		System.out.println("Imprime todos os elementos pares da lista!");
		List<Integer> list2 = Arrays.asList(1, 2, 3, 4, 5, 6, 7);
		list2.forEach(n -> {
		       if (n % 2 == 0) {
		             System.out.print(n + " ");
		       }                   
		});
		System.out.println();
	}
}
