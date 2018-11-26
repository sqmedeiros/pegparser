package testes;

public class Disciplina {
	private Integer id;
	private String nome;
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public String getNome() {
		return nome;
	}
	public void setNome(String nome) {
		this.nome = nome;
	}
	public Disciplina(Integer id, String nome) {
		super();
		this.id = id;
		this.nome = nome;
	}
	public Disciplina() {
		super();
	}
}
