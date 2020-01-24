unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, usplashabout, Forms, Controls, Graphics, Dialogs,
  Buttons, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    SplashAbout1: TSplashAbout;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  SplashAbout1.ShowAbout;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
  SplashAbout1.ShowSplash;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SplashAbout1.ShowSplash;
end;

end.

