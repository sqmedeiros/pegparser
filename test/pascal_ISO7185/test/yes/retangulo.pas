{ Fonte: https://www.portugal-a-programar.pt/forums/topic/39536-pascal-v%C3%A1rios-programas-%C3%BAteis-para-quem-esta-a-come%C3%A7ar/ }
Program Pzim ;
{uses crt;}
VAR COMPRIMENTO, LARGURA, AREA:REAL;
Begin
      writeln('*-------------------------------*');
      writeln('|       ÁREA DO RECTÂNGULO      |');
      writeln('| Programado por Fábio Oliveira |');
      writeln('*-------------------------------*');
      writeln('');
  writeln('Prima qualquer tecla para continuar');
      readkey;
      clrscr;
      writeln('Introduza o comprimento do rectângulo:');
      readln(COMPRIMENTO);
      clrscr;
      writeln('Introduza a largura do rectângulo:');
      readln(LARGURA);
      clrscr;
      AREA := COMPRIMENTO * LARGURA;
      writeln('A área do rectângulo é ',AREA:10:2,'.');
      writeln('Prima qualquer tecla para sair');
      readkey;
End.