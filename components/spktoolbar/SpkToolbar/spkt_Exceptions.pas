unit spkt_Exceptions;

(*******************************************************************************
*                                                                              *
*  Plik: spkt_Exceptions.pas                                                   *
*  Opis: Klasy wyj�tk�w toolbara                                               *
*  Copyright: (c) 2009 by Spook. Jakiekolwiek u�ycie komponentu bez            *
*             uprzedniego uzyskania licencji od autora stanowi z�amanie        *
*             prawa autorskiego!                                               *
*                                                                              *
*******************************************************************************)

interface

uses SysUtils;

type InternalException = class(Exception);
     AssignException = class(Exception);
     RuntimeException = class(Exception);
     ListException = class(Exception);

implementation

end.
