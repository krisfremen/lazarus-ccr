{ ���� ���� ��� ������������� ������ Lazarus. �� �������������!
�������� ��� ������������ ������ ��� ���������� � ��������� ������.
 }

unit rxnew; 

interface

uses
  rxlookup, vclutils, dateutil, dbutils, rxapputils, rxdconst, rxstrutils, 
    dbdateedit, registerrx, curredit, folderlister, rxdbgrid, rxmemds, 
    duallist, boxprocs, tooledit, rxswitch, rxdice, rxdbcomb, rxtoolbar, 
    rxtbrsetup, fduallst, rxxpman, pagemngr, rxappicon, seldsfrm, rxctrls, 
    rxlogin, rxdbgrid_findunit, rxdbgrid_columsunit, rxpopupunit, 
    rxcustomchartpanel, rxsortmemds, AutoPanel, pickdate, rxiconv, 
    LazarusPackageIntf; 

implementation

procedure Register; 
begin
  RegisterUnit('registerrx', @registerrx.Register); 
end; 

initialization
  RegisterPackage('rxnew', @Register); 
end.
