unit ScriptEditorUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, FileCtrl;

type

  { TScriptEditorFrm }

  TScriptEditorFrm = class(TForm)
    HorCenterBevel: TBevel;
    Bevel2: TBevel;
    DirChangeBtn: TButton;
    LineEdit: TEdit;
    Memo1: TLabel;
    OpenDialog1: TOpenDialog;
    SaveBtn: TButton;
    CancelBtn: TButton;
    ReturnBtn: TButton;
    FileListBox1: TFileListBox;
    Label2: TLabel;
    Label3: TLabel;
    RadioGroup1: TRadioGroup;
    SaveDialog1: TSaveDialog;
    ScriptList: TListBox;
    ScriptFileEdit: TEdit;
    Label1: TLabel;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    procedure DirChangeBtnClick(Sender: TObject);
    procedure FileListBox1DblClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LineEditKeyPress(Sender: TObject; var Key: char);
    procedure RadioGroup1Click(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure ScriptListClick(Sender: TObject);
  private
    { private declarations }
    EditOption : integer;
    index : integer;
    currdir : string;
  public
    { public declarations }
  end; 

var
  ScriptEditorFrm: TScriptEditorFrm;

implementation

uses
  Math,
  MatManUnit;

{ TScriptEditorFrm }

procedure TScriptEditorFrm.FormActivate(Sender: TObject);
var
  w: Integer;
begin
  w := MaxValue([SaveBtn.Width, CancelBtn.Width, ReturnBtn.Width]);
  SaveBtn.Constraints.MinWidth := w;
  CancelBtn.Constraints.MinWidth := w;
  ReturnBtn.Constraints.MinWidth := w;
end;

procedure TScriptEditorFrm.FormShow(Sender: TObject);
begin
     //Label4.Visible := false;
     LineEdit.Visible := false;
//     currdir := GetCurrentDir;
//     FileListBox1.Directory := currdir;
end;

procedure TScriptEditorFrm.FileListBox1DblClick(Sender: TObject);
var
   delfile, prmptstr, info : string;
   aindex : integer;

begin
     aindex := FileListBox1.ItemIndex;
     delfile := FileListBox1.Items.Strings[aindex];
     prmptstr := 'Delete ' + delfile + '?';
     info := InputBox('DELETE?',prmptstr,'Y');
     if info <> 'Y' then exit
     else DeleteFile(delfile);
     FileListBox1.Update;
end;

procedure TScriptEditorFrm.DirChangeBtnClick(Sender: TObject);
begin
     if SelectDirectoryDialog1.Execute then
     begin
          currdir := GetCurrentDir;
          FileListBox1.Directory := currdir;
     end;
end;

procedure TScriptEditorFrm.LineEditKeyPress(Sender: TObject; var Key: char);
begin
     if ord(Key) = 13 then
     begin
          ScriptList.Items.Insert(index,LineEdit.Text);
          LineEdit.Text := '';
          LineEdit.Visible := false;
          Label3.Visible := false;
     end;
end;

procedure TScriptEditorFrm.RadioGroup1Click(Sender: TObject);
var
   SaveFile : TextFile;
   CurrentObjType : integer;
   CurrentObjName, cellstring : string;
   Count, i : integer;

begin
     EditOption := RadioGroup1.ItemIndex + 1;
     case EditOption of
     1 : begin // delete a line
               label3.Visible := false;
               LineEdit.Visible := false;
               ScriptList.Items.Delete(index);
               ScriptList.SetFocus;
               RadioGroup1.ItemIndex := -1;
         end;
     2 : begin // insert a line
               label3.Visible := true;
               label3.Caption := 'Enter a new line. End by pressing the Enter key.';
               LineEdit.Visible := true;
               LineEdit.Text := '';
               LineEdit.SetFocus;
               RadioGroup1.ItemIndex := -1;
         end;
     3 : begin // edit a line
               label3.Visible := true;
               label3.Caption := 'Edit the line. End by pressing the Enter key.';
               LineEdit.Visible := true;
               if index >= 0 then
               begin
                    LineEdit.Text := ScriptList.Items.Strings[index];
                    ScriptList.Items.Delete(index);
                    LineEdit.SetFocus;
               end;
               RadioGroup1.ItemIndex := -1;
         end;
     4 : begin  // append another script file
                OpenDialog1.DefaultExt := '.SCP';
                OpenDialog1.Filter := 'Script (*.SCP)|*.SCP|All (*.*)|*.*';
                OpenDialog1.FilterIndex := 1;
                if OpenDialog1.Execute then
                begin
                     AssignFile(SaveFile, OpenDialog1.FileName);
                     Reset(SaveFile);
                     Readln(SaveFile,CurrentObjType);
                     if CurrentObjType <> 5 then
                     begin
                          ShowMessage('Not a script file!');
                          CloseFile(SaveFile);
                          exit;
                     end;
                     Readln(SaveFile,CurrentObjName);
                     Readln(SaveFile,Count);
                     for i := 0 to Count - 1 do
                     begin
                          Readln(SaveFile,cellstring);
                          ScriptList.Items.Add(cellstring);
                     end;
                     CloseFile(SaveFile);
                end;
         end; // end case 4
     end; // end cases
end;

procedure TScriptEditorFrm.SaveBtnClick(Sender: TObject);
var
   SaveFile : TextFile;
   i, Count, CurrentObjType : integer;
   CurrentObjName, edititem : string;

begin
  Assert(MatManFrm <> nil);

  Count := ScriptList.Items.Count;
  if Count < 1 then exit;
  CurrentObjType := 5;
  CurrentObjName := ScriptFileEdit.Text;
  SaveDialog1.FileName := ScriptFileEdit.Text;
  SaveDialog1.Filter := 'Script (*.SCP)|*.SCP|All(*.*)|*.*';
  SaveDialog1.DefaultExt := '.SCP';
  SaveDialog1.FilterIndex := 1;
  if SaveDialog1.Execute then
  begin
     AssignFile(SaveFile, SaveDialog1.FileName);
     Rewrite(SaveFile);
     Writeln(SaveFile,CurrentObjType);
     Writeln(SaveFile,CurrentObjName);
     Writeln(SaveFile,Count);
     MatManFrm.ScriptList.Clear;
     for i := 0 to Count - 1 do
     begin
         edititem := ScriptList.Items.Strings[i];
         Writeln(SaveFile,edititem);
         MatManFrm.ScriptList.Items.Add(edititem);
     end;
     CloseFile(SaveFile);
  end;
end;

procedure TScriptEditorFrm.ScriptListClick(Sender: TObject);
begin
     index := ScriptList.ItemIndex;
end;

initialization
  {$I scripteditorunit.lrs}

end.

