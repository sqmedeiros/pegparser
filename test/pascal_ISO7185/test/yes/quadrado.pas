{ https://www.portugal-a-programar.pt/forums/topic/39536-pascal-v%C3%A1rios-programas-%C3%BAteis-para-quem-esta-a-come%C3%A7ar/ }

Program Pzim;
{uses crt;}
VAR LADO, AREA:REAL;
Begin
      writeln('*-------------------------------*');
      writeln('|       ÁREA DO QUADRADO        |');
      writeln('| Programado por Fábio Oliveira |');
      writeln('*-------------------------------*');
      writeln('');
      writeln('Prima qualquer tecla para continuar');
      readkey;
      clrscr;
      writeln('Introduza a medida do lado:');
      readln(LADO);
      clrscr;
      AREA := LADO * LADO;
      writeln('A área do quadrado é ',AREA:10:2,'.');
      writeln('Prima qualquer tecla para sair');
      readkey;
End.