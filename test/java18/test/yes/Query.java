public class Query {

	public void main (String args[]) {
    Object o1=null;
    if(o instanceof Object[]){
      Object[] a= (Object[])o;
      if(a.length>0)o1=a[0];
    }
  }

  public String obj2str(Object o){
    String s="";
    if(o instanceof Object[]){
      Object[] a= (Object[]) o;
      for(Object ox:a)s=s+" "+ox; 
    }
    return s;
  }

  public void test () {
    for(int i=0;i<a1.size();i++){
      int s1=a1.get(i);Object s2=a2.get(i);Object s3[]=null;
      if(s2 instanceof Object[])s3=(byte[])s2;
    }
  }

  public void addRenderingHints(Map<?,?> hints) { 
    Object o;
    test(); 
    g.addRenderingHints((Map<?,?>) o);
  }

}
