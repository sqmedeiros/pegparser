{ Fonte: https://www.portugal-a-programar.pt/forums/topic/39536-pascal-v%C3%A1rios-programas-%C3%BAteis-para-quem-esta-a-come%C3%A7ar/ }
Program Pzim ;
{uses crt;}
VAR NUM1, NUM2, NUM3, PRODUTO, SOMA:integer;


Begin
      writeln('*===============================*');
      writeln('|         SOMA E PRODUTO        |');
      writeln('| Programado por Fábio Oliveira |');
      writeln('*===============================*');
      writeln('');
  writeln('Prima qualquer tecla para continuar...');
      readkey;
      clrscr;

      writeln('Insira o primeiro numero:');
      readln(NUM1);
      clrscr;

      writeln('Insira o segundo numero:');
      readln(NUM2);
      clrscr;

      writeln('Insira o terceiro numero:');
      readln(NUM3);
      clrscr;

      SOMA := NUM1 + NUM2 + NUM3;
      PRODUTO := NUM1 * NUM2 * NUM3;

      writeln('A soma dos três números é ',SOMA,' e o produto  é ',PRODUTO,'.');
      writeln('Prima qualquer tecla para sair');
      readkey;
End.