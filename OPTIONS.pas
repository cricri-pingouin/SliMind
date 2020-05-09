unit OPTIONS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, mmind, IniFiles;

type
  tfrmOptions = class(TForm)
    btnKids: TButton;
    btnMastermind: TButton;
    btnDeluxe: TButton;
    lblPegs: TLabel;
    scrlPegs: TScrollBar;
    lblPegsVal: TLabel;
    lblColours: TLabel;
    scrlColours: TScrollBar;
    lblColoursVal: TLabel;
    lblAttempts: TLabel;
    scrlAttempts: TScrollBar;
    lblAttemptsVal: TLabel;
    chkRepeatColours: TCheckBox;
    btnCancel: TButton;
    btnOk: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure scrlPegsChange(Sender: TObject);
    procedure scrlColoursChange(Sender: TObject);
    procedure scrlAttemptsChange(Sender: TObject);
    procedure btnKidsClick(Sender: TObject);
    procedure btnMastermindClick(Sender: TObject);
    procedure btnDeluxeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmOptions: tfrmOptions;

implementation

{$R *.dfm}

procedure tfrmOptions.btnKidsClick(Sender: TObject);
begin
  scrlPegs.Position := 3;
  scrlColours.Position := 6;
  scrlAttempts.Position := 9;
end;

procedure tfrmOptions.btnMastermindClick(Sender: TObject);
begin
  scrlPegs.Position := 4;
  scrlColours.Position := 6;
  scrlAttempts.Position := 10;
end;

procedure tfrmOptions.btnDeluxeClick(Sender: TObject);
begin
  scrlPegs.Position := 5;
  scrlColours.Position := 8;
  scrlAttempts.Position := 12;
end;

procedure tfrmOptions.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure tfrmOptions.btnOkClick(Sender: TObject);
var
  myINI: TINIFile;
begin
  if (chkRepeatColours.Checked = False) and (scrlPegs.Position > scrlColours.Position) then
  begin
    showmessage('You cannot have more pegs than colours if you don''t allow repeat colours!' + sLineBreak + 'Please change your settings to eliminate this conflict.');
    Exit;
  end;
  frmMind.NumPegs := scrlPegs.Position;
  frmMind.NumColours := scrlColours.Position;
  frmMind.NumAllowedAttempts := scrlAttempts.Position;
  frmMind.RepeatColours := chkRepeatColours.Checked;
  //Save settings to INI file
  myINI := TINIFile.Create(ExtractFilePath(Application.EXEName) + 'SliMind.ini');
  myINI.WriteInteger('Settings', 'Pegs', frmMind.NumPegs);
  myINI.WriteInteger('Settings', 'Colours', frmMind.NumColours);
  myINI.WriteInteger('Settings', 'AllowedAttempts', frmMind.NumAllowedAttempts);
  myINI.WriteBool('Settings', 'AllowRepeatColours', frmMind.RepeatColours);
  myINI.Free;
  Close;
end;

procedure tfrmOptions.FormCreate(Sender: TObject);
begin
  scrlPegs.Position := frmMind.NumPegs;
  lblPegsVal.Caption := IntToStr(scrlPegs.Position);
  scrlColours.Position := frmMind.NumColours;
  lblColoursVal.Caption := IntToStr(scrlColours.Position);
  scrlAttempts.Position := frmMind.NumAllowedAttempts;
  lblAttemptsVal.Caption := IntToStr(scrlAttempts.Position);
  chkRepeatColours.Checked := frmMind.RepeatColours;
end;

procedure tfrmOptions.scrlPegsChange(Sender: TObject);
begin
  lblPegsVal.Caption := IntToStr(scrlPegs.Position);
end;

procedure tfrmOptions.scrlColoursChange(Sender: TObject);
begin
  lblColoursVal.Caption := IntToStr(scrlColours.Position);
end;

procedure tfrmOptions.scrlAttemptsChange(Sender: TObject);
begin
  lblAttemptsVal.Caption := IntToStr(scrlAttempts.Position);
end;

end.

