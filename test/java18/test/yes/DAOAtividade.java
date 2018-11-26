package framework.dao;

import java.lang.reflect.InvocationTargetException;
import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import framework.dao.interfaces.DatabaseException;
import framework.dao.interfaces.IDAOAtividade;
import framework.model.Area;
import framework.model.Pratica;
import framework.model.Projeto;

public abstract class DAOAtividade<
		A extends Area, 
		Proj extends Projeto<?>,
		Prat extends Pratica<A,?,Proj>> 
			implements IDAOAtividade<A, Proj, Prat> 
{

	private final Class<Prat> pratClass;
	private final Class<Proj> projClass;
	private final Class<A> areaClass;
	
	
	public DAOAtividade(Class<A> areaClass, Class<Proj> projClass, Class<Prat> pratClass) {
		this.areaClass = areaClass;
		this.projClass = projClass;
		this.pratClass = pratClass;
	}
	
	@Override
	public void inserir(Prat prat) throws DatabaseException {
		String sql = "insert into Pratica set ";
		ArrayList<String> campos = new ArrayList<String>();
		
		if(prat.getDataInicio() != null)
			campos.add("dataInicio='" + prat.getDataInicio().toString() + "'");
		
		if(prat.getDataTermino() != null)
			campos.add("dataTermino='" + prat.getDataTermino().toString() + "'");
		
		if(prat.getProjeto() != null )
			campos.add("codigoProjeto=" + prat.getProjeto());
				
		if(prat.getArea() != null)
			campos.add("codigoArea=" + prat.getArea());

		
		//chamar parte flexível
		campos = compInserir(campos, prat);
		
		for(int i = 0; i < campos.size(); i++) {
			sql += campos.get(i);
			if(i+1 < campos.size())
				sql += ", ";
		}
		
		sql += ";";
		System.out.println(sql); // Remover depois
		try {
			JDBC.runInsert(sql);
		} catch (SQLException e) {
			throw new DatabaseException("Não foi possível realizar a operação solicitada");
		}	
	}

	@Override
	public void remover(Prat prat) throws DatabaseException {
		String sql = "delete from Pratica where codigoPratica=" + prat.getCodigo() + ";";
		System.out.println(sql);
		try {
			JDBC.runRemove(sql);
		} catch(Exception e) {
			throw new DatabaseException("Impossível remover o projeto informado");
		}
	}

	@Override
	public void atualizar(Prat prat) throws DatabaseException {
		String sql = "update Pratica set ";
		ArrayList<String> campos = new ArrayList<String>();
		
		if(prat.getDataInicio() != null)
			campos.add("dataInicio='" + prat.getDataInicio().toString() + "'");
		
		if(prat.getDataTermino() != null)
			campos.add("dataTermino='" + prat.getDataTermino().toString() + "'");
		
		if(prat.getProjeto() != null )
			campos.add("codigoProjeto=" + prat.getProjeto());
				
		if(prat.getArea() != null)
			campos.add("codigoArea=" + prat.getArea());
			
		//chamar parte flexível
		campos = compAtualizar(campos, prat);
		
		for(int i = 0; i < campos.size(); i++) {
			sql += campos.get(i);
			if(i+1 < campos.size())
				sql += ", ";
		}
		
		sql += " where codigoProjeto=" + prat.getCodigo() + ";";
		System.out.println(sql);
		try {
			JDBC.runUpdate(sql);
		} catch(Exception e) {
			throw new DatabaseException("Não foi possível atualizar o projeto");
		}
	}

	@Override
	public List<Prat> consultar(Prat prat) throws DatabaseException {
		String sql = "select * from Pratica ";
		
		ArrayList<String> cond = new ArrayList<String>();
		
		if(prat.getCodigo() != null) {
			cond.add("codigoPratica = " + prat.getCodigo());
		}
		
		if(prat.getDataInicio() != null && prat.getDataTermino() != null) {
			cond.add("dataInicio >= '" + prat.getDataInicio().toString() + "'");
			cond.add("(dataTermino is null or (dataTermino >= '" + 
					prat.getDataInicio().toString() + "' and dataTermino <='" 
					+ prat.getDataTermino().toString() + "'))");
		}
		else if (prat.getDataInicio() != null) {
			cond.add("dataInicio >= '" + prat.getDataInicio().toString() + "'");
		}
		
		if(prat.getProjeto() != null )
			cond.add("codigoProjeto=" + prat.getProjeto());
				
		if(prat.getArea() != null)
			cond.add("codigoArea=" + prat.getArea());
					
		cond = compConsultar(cond, prat);
		
		if (!cond.isEmpty())
		{
			sql += "where ";
			for(int i = 0; i < cond.size(); i++) {
				sql += " " + cond.get(i);
				if(i + 1 < cond.size())
					sql += " and";
			}
			
		}
	
		sql += ";";
		System.out.println(sql);
		try {
			return getFromResult(JDBC.runQuery(sql));
		} catch (Exception e) {
			throw new DatabaseException("Erro durante a consulta");
		}
	}

	@Override
	public List<Prat> listar() throws DatabaseException {
		String sql = "select * from Pratica;";
		System.out.println(sql);
		try {
			return getFromResult(JDBC.runQuery(sql));
		} catch (SQLException e) {
			throw new DatabaseException("Não foi possível realizar a operação solicitada");
		}
	}
	
	private ArrayList<Prat> getFromResult(ResultSet resultSet) throws DatabaseException {
		ArrayList<Prat> retorno = new ArrayList<>();

		try {
			while(resultSet.next()) {
				
				Integer codigo = (Integer)resultSet.getObject("codigoPratica");
				Date inicio = resultSet.getDate("dataInicio");
				Date termino = resultSet.getDate("dataTermino");
				Integer codigoProjeto = (Integer)resultSet.getObject("codigoProjeto");
				Integer codigoArea = (Integer)resultSet.getObject("codigoArea");
				
				Prat prat;
				
				try {
					prat = pratClass.getDeclaredConstructor().newInstance();
				} catch (InstantiationException | IllegalAccessException | IllegalArgumentException 
						| InvocationTargetException | NoSuchMethodException | SecurityException e) {
					throw new DatabaseException(e);
				}
				
				
			
				getProjectWithFlexibleAttributes(resultSet, prat);
				
				prat.setCodigo(codigo);
				prat.setDataInicio(inicio);
				prat.setDataTermino(termino);
				
				if(codigoProjeto != null) {
					try {
						prat.setProjeto(projClass.getDeclaredConstructor().newInstance());
						prat.getProjeto().setCodigo(codigoProjeto);
					} catch (InstantiationException | IllegalAccessException | IllegalArgumentException
							| InvocationTargetException | NoSuchMethodException | SecurityException e) {
						throw new DatabaseException(e);
					}
				}
				
				if(codigoArea != null) {
					try {
						prat.setArea(areaClass.getDeclaredConstructor().newInstance());
						prat.getArea().setCodigo(codigoArea);
					} catch (InstantiationException | IllegalAccessException | IllegalArgumentException
							| InvocationTargetException | NoSuchMethodException | SecurityException e) {
						throw new DatabaseException(e);
					}
				}
				
				retorno.add(prat);
			}
		} catch (SQLException e) {
			throw new DatabaseException(e);
		}
		return retorno;
	}
	
	/** Metodos que devem ser implementados*/
	protected abstract ArrayList<String> compInserir(ArrayList<String> sql, Prat a);
	protected abstract ArrayList<String> compRemover(ArrayList<String> sql, Prat a);
	protected abstract ArrayList<String> compAtualizar(ArrayList<String> sql, Prat a);
	protected abstract ArrayList<String> compConsultar(ArrayList<String> sql, Prat a);
	protected abstract void getProjectWithFlexibleAttributes(ResultSet resultSet, Prat p) throws SQLException;
}
