{
 ***************************************************************************
 *                                                                         *
 *   This source is free software; you can redistribute it and/or modify   *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This code is distributed in the hope that it will be useful, but      *
 *   WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   General Public License for more details.                              *
 *                                                                         *
 *   A copy of the GNU General Public License is available on the World    *
 *   Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also      *
 *   obtain it by writing to the Free Software Foundation,                 *
 *   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.        *
 *                                                                         *
 ***************************************************************************
 
  Author: Tom Gregorovic

  Abstract:
    About Icon Editor dialog.
}
unit AboutDialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Buttons,
  StdCtrls, ExtCtrls;

type

  { TAboutDialogForm }

  TAboutDialogForm = class(TForm)
    ButtonClose: TButton;
    Image: TImage;
    LabelAuthor: TLabel;
    LabelVersion: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  AboutDialogForm: TAboutDialogForm;

implementation

uses IconStrConsts;
{ TAboutDialogForm }

procedure TAboutDialogForm.FormCreate(Sender: TObject);
begin
  Image.Picture.LoadFromFile('.\Images\icon.png');
  Caption:=lieAbouDialog;
  LabelVersion.Caption:=lieLabelVersion;
  LabelAuthor.Caption:=lieLabelAuthor;
  ButtonClose.Caption:=lieButtonClose;
end;

initialization

  {$I aboutdialog.lrs}

end.


