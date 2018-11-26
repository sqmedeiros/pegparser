public class Aluno implements Pessoa {
	private Integer matricula;
	private List<Disciplina> disciplinas;

	public Aluno(Integer matricula, String nome, String cpf, String telefone, List<Disciplina> disciplinas) {
		super(nome, cpf, telefone);
		this.matricula = matricula;
		this.disciplinas = disciplinas;
	}

	public Aluno(Integer matricula, String nome, String cpf, String telefone) {
		super(nome, cpf, telefone);
		this.matricula = matricula;
	}

	public Integer getMtricula() {
		return this.matricula;
	}  

	public void setMetricula(Integer matricula) {
		this.matricula = matricula;
	}

	public void addDisciplina(Disciplina disciplina) {
		this.disciplinas.add(disciplina);
	}

	public void removeDisciplina(Disciplina disciplina) {
		this.disciplinas.remove(disciplina);
	}
}