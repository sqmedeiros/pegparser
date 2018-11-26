package testes;

public class SortMain {
    private static int[] getDefault() {
        int[] aux = {10, 2, 3, 7, 9, 4, 5};
        return aux;
    }
    
    private static void sort(Sort s, int[] vector) {
        s.sort(vector);
        System.out.print("{ ");
        for (int i = 0; i < vector.length; i++) {
            System.out.print(vector[i] + " ");
        }
        System.out.println("}");
    }
    
    public static void main(String[] args) {
        sort(new InsertionSort(), getDefault());
        sort(new BubbleSort(), getDefault());
        sort(new QuickSort(), getDefault());
        sort(new SelectionSort(), getDefault());
    }
}

interface Sort {
    public void sort(int[] vetor);
}

class InsertionSort implements Sort {
    @Override
    public void sort(int[] vetor) {
        int j;
        int key;
        int i;
        
        for (j = 1; j < vetor.length; j++)
        {
          key = vetor[j];
          for (i = j - 1; (i >= 0) && (vetor[i] > key); i--)
          {
             vetor[i + 1] = vetor[i];
           }
            vetor[i + 1] = key;
        }
    }
}

class BubbleSort implements Sort {

    @Override
    public void sort(int[] vetor) {
        boolean troca = true;
        int aux;
        while (troca) {
            troca = false;
            for (int i = 0; i < vetor.length - 1; i++) {
                if (vetor[i] > vetor[i + 1]) {
                    aux = vetor[i];
                    vetor[i] = vetor[i + 1];
                    vetor[i + 1] = aux;
                    troca = true;
                }
            }
        }
    }
}

class QuickSort implements Sort {

    @Override
    public void sort(int[] vetor) {
        quickSort(vetor, 0, vetor.length-1);
    }
    
    private void quickSort(int[] vetor, int inicio, int fim) {
        if (inicio < fim) {
               int posicaoPivo = separar(vetor, inicio, fim);
               quickSort(vetor, inicio, posicaoPivo - 1);
               quickSort(vetor, posicaoPivo + 1, fim);
        }
    }
    
    private int separar(int[] vetor, int inicio, int fim) {
        int pivo = vetor[inicio];
        int i = inicio + 1, f = fim;
        while (i <= f) {
               if (vetor[i] <= pivo)
                      i++;
               else if (pivo < vetor[f])
                      f--;
               else {
                      int troca = vetor[i];
                      vetor[i] = vetor[f];
                      vetor[f] = troca;
                      i++;
                      f--;
               }
        }
        vetor[inicio] = vetor[f];
        vetor[f] = pivo;
        return f;
    }
}

class SelectionSort implements Sort {

    @Override
    public void sort(int[] vetor) {
        for(int fixo = 0; fixo < vetor.length-1; fixo++) {
            int menor = fixo;
            for (int i = menor + 1; i < vetor.length; i++) {
                if (vetor[i] < vetor[menor])
                    menor = i;
                if (menor != fixo) {
                    int t = vetor[fixo];
                    vetor[fixo] = vetor[menor];
                    vetor[menor] = t;
                }
            }
        }
    }
}