{ Fonte: https://www.portugal-a-programar.pt/forums/topic/39536-pascal-v%C3%A1rios-programas-%C3%BAteis-para-quem-esta-a-come%C3%A7ar/ }

Program Pzim ;
{uses crt;}
VAR NOTACOMP, NOTAT, NOTAFINAL:REAL;
{VAR }AVALIA:STRING;

Begin
      writeln('*-------------------------------*');
      writeln('|           NOTA FINAL          |');
      writeln('| Programado por Fábio Oliveira |');
      writeln('*-------------------------------*');
      writeln('');
  writeln('Prima qualquer tecla para continuar...');
      readkey;
      clrscr;
      writeln('Introduza nota do competência:');
      readln(NOTACOMP);
      clrscr;
      writeln('Introduza a nota atitude:');
      readln(NOTAT);
      clrscr;
      NOTAFINAL := (0.60 * NOTACOMP) + (0.40 * NOTAT);
  IF NOTAFINAL <= 9.49
     THEN
         AVALIA := 'REPROVADO'
     ELSE
         AVALIA := 'APROVADO';
      writeln('A nota final é ',NOTAFINAL:10:2,' que significa que foi ',AVALIA);
      writeln('Prima qualquer tecla para sair');
      readkey;
End.