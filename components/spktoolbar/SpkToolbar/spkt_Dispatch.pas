unit spkt_Dispatch;

(*******************************************************************************
*                                                                              *
*  Plik: spkt_Dispatch.pas                                                     *
*  Opis: Bazowe klasy dyspozytor�w po�rednicz�cych pomi�dzy elementami         *
*        toolbara.                                                             *
*  Copyright: (c) 2009 by Spook. Jakiekolwiek u�ycie komponentu bez            *
*             uprzedniego uzyskania licencji od autora stanowi z�amanie        *
*             prawa autorskiego!                                               *
*                                                                              *
*******************************************************************************)

interface

uses Windows, Classes, Controls, Graphics,
     SpkMath;

type TSpkBaseDispatch = class abstract(TObject)
     private
     protected
     public
     end;

type TSpkBaseAppearanceDispatch = class abstract(TSpkBaseDispatch)
     private
     protected
     public
       procedure NotifyAppearanceChanged; virtual; abstract;
     end;

type TSpkBaseToolbarDispatch = class abstract(TSpkBaseAppearanceDispatch)
     private
     protected
     public
       procedure NotifyItemsChanged; virtual; abstract;
       procedure NotifyMetricsChanged; virtual; abstract;
       procedure NotifyVisualsChanged; virtual; abstract;
       function GetTempBitmap : TBitmap; virtual; abstract;
       function ClientToScreen(Point : T2DIntPoint) : T2DIntPoint; virtual; abstract;
     end;

implementation

end.
