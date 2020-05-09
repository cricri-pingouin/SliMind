program slimind;

uses
  Forms,
  mmind in 'mmind.pas' {frmMind},
  HIGHSCORES in 'HIGHSCORES.pas' {frmScores},
  OPTIONS in 'OPTIONS.pas' {frmOptions};

{$R *.res}
{$SetPEFlags 1}

begin
  Application.Initialize;
  Application.Title := 'SliMind';
  Application.CreateForm(TfrmMind, frmMind);
  Application.CreateForm(TfrmScores, frmScores);
  Application.CreateForm(TfrmOptions, frmOptions);
  Application.Run;
end.
