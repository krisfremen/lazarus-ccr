unit DataUnit;

interface

uses
  //Windows, Messages,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, OutPutUnit, Globals;

procedure GetFileData(VAR FName : string);
procedure Allocations;
procedure DeAllocations;

implementation

uses LinPro;

procedure GetFileData(VAR FName : string);

var
   F : TextFile;
   i, j : integer;

begin
     LinProFrm.OpenDialog1.DefaultExt := 'LPR';
     LinProFrm.OpenDialog1.Filter := 'Linear Programming File (*.LPR)|*.LPR|All Files (*.*)|*.*';
     LinProFrm.OpenDialog1.FilterIndex := 1;
     if LinProFrm.OpenDialog1.Execute then
     begin
        FName := LinProFrm.OpenDialog1.FileName;
        AssignFile(F,FName);
        Reset(F);
        readln(F,LinProFrm.NoVars);
        readln(F,LinProFrm.NoMax);
        readln(F,LinProFrm.NoMin);
        readln(F,LinProFrm.NoEql);
        readln(F,LinProFrm.MinMax);
        LinProFrm.NoCoefs := LinProFrm.NoMax + LinProFrm.NoMin + LinProFrm.NoEql;
        Alloc;
        for i := 1 to LinProFrm.NoVars do readln(F,LinProFrm.Objective[i]);
        for i := 1 to LinProFrm.NoMax do readln(F,LinProFrm.MaxConstraints[i]);
        for i := 1 to LinProFrm.NoMin do readln(F,LinProFrm.MinConstraints[i]);
        for i := 1 to LinProFrm.NoEql do readln(F,LinProFrm.EqlConstraints[i]);
        for i := 1 to LinProFrm.NoCoefs do
            for j := 1 to LinProFrm.NoVars do readln(F,LinProFrm.Coefficients[i,j]);
        CloseFile(F);
     end;
end;
//-------------------------------------------------------------------

procedure Allocations;
begin
     SetLength(LinProFrm.Objective,LinProFrm.NoVars + 1);
     SetLength(LinProFrm.MaxConstraints,LinProFrm.NoMax + 1);
     SetLength(LinProFrm.MinConstraints,LinProFrm.NoMin + 1);
     SetLength(LinProFrm.EqlConstraints,LinProFrm.NoEql+1);
     SetLength(LinProFrm.Coefficients,LinProFrm.NoCoefs+1,LinProFrm.NoVars+1);
end;
//-------------------------------------------------------------------

procedure DeAllocations;
begin
   // cleanup
   LinProFrm.Coefficients := nil;
   LinProFrm.EqlConstraints := nil;
   LinProFrm.MinConstraints := nil;
   LinProFrm.MaxConstraints := nil;
   LinProFrm.Objective := nil;
end;
//-------------------------------------------------------------------

end.
