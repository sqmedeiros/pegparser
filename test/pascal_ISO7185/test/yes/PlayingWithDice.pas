(*378A - Playing with Dice: Codeforces.com*)
program PlayingWithDice;

var
	i, a, b : integer;
	draw, aWin, bWin : integer;

function abs(x: integer): integer;
begin
	if x < 0 then
		abs := -x
	else
		abs := x;
end;

begin
	readln(a,b);
	draw := 0;
	aWin := 0;
	bWin := 0;
	for i := 1 to 6 do
	begin
		if abs(i-a) < abs(i-b) then
			aWin := aWin+1
		else
			if abs(i-a) = abs(i-b) then
				draw := draw+1
			else
				bWin := bWin+1;
	end;
	writeln(aWin, ' ', draw, ' ', bWin);
end.