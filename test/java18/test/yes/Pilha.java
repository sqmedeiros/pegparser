package testes;

import java.util.LinkedList;

public class Pilha<E> {
    private LinkedList<E> list;
    
    public Pilha() {
        list = new LinkedList<>();
    }
    
    public void push(E e) {
        list.addFirst(e);
    }
    
    public E top() {
        return list.getFirst();
    }
    
    public void pop() {
        list.removeFirst();
    }
    
    public boolean isEmpty() {
        return list.isEmpty(); 
    }
    
    public int size() {
        return list.size();
    }
}