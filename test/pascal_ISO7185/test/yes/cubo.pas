{ Fonte: https://www.portugal-a-programar.pt/forums/topic/39536-pascal-v%C3%A1rios-programas-%C3%BAteis-para-quem-esta-a-come%C3%A7ar/ }

Program CUBOPAR;

{ uses crt; }
var tipo :string;
   NUM1,CUBO :real;
   cubo1:integer;

Begin

      writeln('*===============================*');
      writeln('|         CUBO PAR OU IMPAR     |');
      writeln('| Programado por Fábio Oliveira |');
      writeln('*===============================*');
      writeln('');
      writeln('Prima qualquer tecla para continuar...');
      readkey;
      clrscr;

      writeln('Insira o numero:');
      readln(NUM1);
      clrscr;



      CUBO := exp(3*ln(NUM1));

      CUBO1 := abs(CUBO);
  if CUBO1 MOD 2 = 0
     then tipo:='IMPAR'
	else tipo:='PAR';

      writeln('O cubo do número ',NUM1:0:0,' é ',CUBO:0:0,' e é ',tipo);
      writeln('Prima qualquer tecla para sair');
      readkey;
End.