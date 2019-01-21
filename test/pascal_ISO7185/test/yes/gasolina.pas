{ Fonte: https://www.portugal-a-programar.pt/forums/topic/39536-pascal-v%C3%A1rios-programas-%C3%BAteis-para-quem-esta-a-come%C3%A7ar/ }
Program Pzim ;
{uses crt;}
VAR GASOLINA, INICIOKM, FIMKM, MEDIA100:REAL;


Begin
      writeln('*===============================*');
      writeln('|           MEDIA 100           |');
      writeln('| Programado por Fábio Oliveira |');
      writeln('*===============================*');
      writeln('');
  writeln('Prima qualquer tecla para continuar...');
      readkey;
      clrscr;
      writeln('Insira os km iniciais:');
      readln(INICIOKM);
      clrscr;
      writeln('Insira os km finais:');
      readln(FIMKM);
      clrscr;
      writeln('Insira gasolina gasta');
      readln(GASOLINA);
      clrscr;

      MEDIA100 := 	100 * GASOLINA / (FIMKM - INICIOKM);

      writeln('A media aos 100 de gasolina é ',MEDIA100,'.');
      writeln('Prima qualquer tecla para sair');
      readkey;
END. 