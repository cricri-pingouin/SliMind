unit mmind;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Buttons, Menus, INIfiles;

type
  TfrmMind = class(TForm)
    mnuMain: TMainMenu;
    mnuGame: TMenuItem;
    mnuNewGame: TMenuItem;
    mnuSep1: TMenuItem;
    mnuExit: TMenuItem;
    mnuCheck: TMenuItem;
    img0: TImage;
    img1: TImage;
    img2: TImage;
    img3: TImage;
    img4: TImage;
    img5: TImage;
    img6: TImage;
    img7: TImage;
    img8: TImage;
    img9: TImage;
    imgm0: TImage;
    imgm1: TImage;
    imgm2: TImage;
    mnuScores: TMenuItem;
    mnuSettings: TMenuItem;
    mnuHelp: TMenuItem;
    procedure DrawPeg(X, Y, PegIndex: Integer);
    procedure DrawMarker(X, Y, MarkerIndex: Integer);
    procedure NewGame();
    procedure mnuNewGameClick(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure mnuScoresClick(Sender: TObject);
    procedure mnuCheckClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure mnuSettingsClick(Sender: TObject);
    procedure mnuHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    //High scores
    HSname: array[1..10] of string;
    HSguesses: array[1..10] of DWORD;
    NumPegs, NumColours, NumAllowedAttempts: Integer;
    RepeatColours: Boolean;
    procedure Paint; override; //Paint override needed to display new game from FormCreate
  end;

const
  PegSize = 52; //Size of a peg in pixels
  MarkerSize = 18; //Size of a marker in pixels
  MaxNumPegs = 9;
  MaxGuesses = 25;
  PegsMarkersGapWidth = MarkerSize; //One marker gap

var
  frmMind: TfrmMind;
  Secret, Guess, PreviousGuess, TestCode: array[1..MaxNumPegs] of Byte;
  PegPic: array[0..9] of^TBitmap;
  MarkerPic: array[0..2] of^TBitmap; //0: blank; 1: correct/black; 2: misplaced/white
  GuessNumber: Byte;

implementation

{$R *.dfm}

uses
  HIGHSCORES, OPTIONS;

procedure TfrmMind.Paint;
//Paint override needed, otherwise won't display game if started from FormCreate
begin
  NewGame();
end;

procedure TfrmMind.DrawPeg(X, Y, PegIndex: Integer);
begin
  frmMind.Canvas.Draw((X - 1) * PegSize, (NumAllowedAttempts + 2 - Y) * PegSize, PegPic[PegIndex]^);
end;

procedure TfrmMind.DrawMarker(X, Y, MarkerIndex: Integer);
begin
  frmMind.Canvas.Draw(NumPegs * PegSize + PegsMarkersGapWidth + (X - 1) * MarkerSize, (NumAllowedAttempts + 2 - Y) * PegSize + (PegSize - MarkerSize) div 2, MarkerPic[MarkerIndex]^);
end;

procedure TfrmMind.NewGame();
var
  X, Y: Integer;
begin
  with frmMind do
  begin
    canvas.pen.color := clwhite;
    canvas.brush.color := clwhite;
    canvas.rectangle(0, 0, width - 1, height - 1);
  end;
  frmMind.ClientWidth := NumPegs * PegSize + PegsMarkersGapWidth + NumPegs * MarkerSize;
  frmMind.ClientHeight := (NumAllowedAttempts + 2) * PegSize; //+2 is for solution and a gap
  //Initialise board and secret code
  for X := 1 to NumPegs do
    for Y := 1 to NumAllowedAttempts do
    begin
      DrawPeg(X, Y, 9);
      DrawMarker(X, Y, 0);
    end;
  //Leave blank between guesses and solution
  //DrawPeg(X, NumAllowedAttempts + 1, 0);
  Randomize();
  //Reuse as flag for colour already used in case repeat colours not allowed
  for X := 1 to NumColours do
    TestCode[X] := 1;
  //Set secret code
  for X := 1 to NumPegs do
  begin
    Guess[X] := 0;
    //Colours can be repeated: just pick any colour
    if RepeatColours then
      Secret[X] := random(NumColours) + 1
    else
    begin
      //Colours cannot be repeated: pick an unused colour
      repeat
        Secret[X] := random(NumColours) + 1;
      until (TestCode[Secret[X]] = 1);
      //Flag as used
      TestCode[Secret[X]] := 0;
    end;
  end;
  //Set flag as game running
  GuessNumber := 1;
  mnuCheck.Enabled := True;
end;

procedure TfrmMind.mnuNewGameClick(Sender: TObject);
begin
  NewGame();
end;

procedure TfrmMind.mnuScoresClick(Sender: TObject);
begin
  if frmScores.Visible = False then
    frmScores.Show
  else
    frmScores.Hide;
end;

procedure TfrmMind.mnuSettingsClick(Sender: TObject);
begin
  if frmOptions.Visible = False then
    frmOptions.Show
  else
    frmOptions.Hide;
end;

procedure TfrmMind.mnuExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMind.mnuCheckClick(Sender: TObject);
var
  X, Y, Correct, Misplaced: Byte;
  //High score
  WinnerName: string;
  myINI: TINIFile;
begin
  //Test that guess is complete
  for X := 1 to NumPegs do
    if (Guess[X] = 0) then
    begin
      showmessage('You didn''t finish entering your guess!');
      Exit;
    end;
  //Initialise counts
  Correct := 0;
  Misplaced := 0;
  //Make copy of secret and backup of guess
  TestCode := Secret;
  PreviousGuess := Guess;
  //Count correct pegs
  for X := 1 to NumPegs do
    if (Guess[X] = TestCode[X]) then
    begin
      //+1 black marker
      Inc(Correct);
      //Remove it for misplaced test
      Guess[X] := 0;
      TestCode[X] := 0;
    end;
  //Count misplaced pegs
  for X := 1 to NumPegs do
    for Y := 1 to NumPegs do
      if (Guess[X] = TestCode[Y]) and (Guess[X] <> 0) then
      begin
        //+1 white marker
        Inc(Misplaced);
        //Remove it for subsequent misplaced test
        Guess[X] := 0;
        TestCode[Y] := 0;
      end;
  //Put markers
  if (Correct > 0) then
    for X := 1 to Correct do
      DrawMarker(X, GuessNumber, 1);
  if (Misplaced > 0) then
    for X := 1 to Misplaced do
      DrawMarker(Correct + X, GuessNumber, 2);
  //Check game end
  if (Correct = NumPegs) then
  begin
    //Winner!
    mnuCheck.Enabled := False;
    //Show solution
    for X := 1 to NumPegs do
      DrawPeg(X, NumAllowedAttempts + 2, Secret[X]);
    //Highscore?
    for X := 1 to 10 do
    begin
      if (GuessNumber < HSguesses[X]) then
      begin
        //Get name
        WinnerName := InputBox('You''re Winner!', 'You placed #' + IntToStr(X) + ' by guessing in ' + IntToStr(GuessNumber) + ' attempts.' + slinebreak + 'Enter your name:', HSname[1]);
        //Shift high scores downwards; If placed 10, skip as we'll simply overwrite last score
        if (X < 10) then
          for Y := 10 downto X + 1 do
          begin
            HSname[Y] := HSname[Y - 1];
            HSguesses[Y] := HSguesses[Y - 1];
          end;
        //Set new high score
        HSname[X] := WinnerName;
        HSguesses[X] := GuessNumber;
        //Save high scores to INI file
        myINI := TINIFile.Create(ExtractFilePath(Application.EXEName) + 'SliMind.ini');
        for Y := 1 to 10 do
        begin
          myINI.WriteString('HighScores', 'Name' + IntToStr(Y), HSname[Y]);
          myINI.WriteInteger('HighScores', 'Time' + IntToStr(Y), HSguesses[Y]);
        end;
        //Close INI file
        myINI.Free;
        //Exit so that we only get 1 high score!
        Exit;
      end;
    end;
    ShowMessage('You win but guessing in ' + IntToStr(GuessNumber) + ' turns is not a high score.');
    Exit;
  end
  else if (GuessNumber = NumAllowedAttempts) then
  begin
    //Loser!
    mnuCheck.Enabled := True;
    //Show solution
    for X := 1 to NumPegs do
      DrawPeg(X, NumAllowedAttempts + 2, Secret[X]);
    showmessage('You lost!');
    Exit;
  end;
  //Initialise guess so that we can test when it's complete again
  for X := 1 to NumPegs do
    Guess[X] := 0;
  //Next guess index
  Inc(GuessNumber);
end;

procedure TfrmMind.mnuHelpClick(Sender: TObject);
begin
  ShowMessage('Left click on a column to change the colour up'+sLineBreak+'Right click on a column to change the colour down.'+sLineBreak+'Middle click on a column to use the same colour as in the previous guess'+sLineBreak+'Left click anywhere in the markers area (right of colour pegs) to check your guess');
end;

procedure TfrmMind.FormCreate(Sender: TObject);
var
  myINI: TINIFile;
  i: Byte;
begin
  //Initialise options from INI file
  myINI := TINIFile.Create(ExtractFilePath(Application.EXEName) + 'SliMind.ini');
  //Read settings from INI file
  NumPegs := myINI.ReadInteger('Settings', 'Pegs', 4);
  NumColours := myINI.ReadInteger('Settings', 'Colours', 6);
  NumAllowedAttempts := myINI.ReadInteger('Settings', 'AllowedAttempts', 12);
  RepeatColours := myINI.ReadBool('Settings', 'AllowRepeatColours', True);
  if (RepeatColours = False) and (NumPegs > NumColours) then
  begin
    showmessage('You cannot have more pegs than colours if you don''t allow repeat colours!' + sLineBreak + 'Allowing repeat colours again.');
    RepeatColours := True;
  end;
  //Read high scores from INI file
  for i := 1 to 10 do
  begin
    HSname[i] := myINI.ReadString('HighScores', 'Name' + IntToStr(i), 'Nobody');
    HSguesses[i] := myINI.ReadInteger('HighScores', 'Guesses' + IntToStr(i), 10 + i * 2);
  end;
  myINI.Free;
  //Initialise shapes images: 0-8: uncovered, 9=blank, 10=flag, 11=maybe
  New(PegPic[0]);
  PegPic[0]^ := img0.Picture.Bitmap;
  New(PegPic[1]);
  PegPic[1]^ := img1.Picture.Bitmap;
  New(PegPic[2]);
  PegPic[2]^ := img2.Picture.Bitmap;
  New(PegPic[3]);
  PegPic[3]^ := img3.Picture.Bitmap;
  New(PegPic[4]);
  PegPic[4]^ := img4.Picture.Bitmap;
  New(PegPic[5]);
  PegPic[5]^ := img5.Picture.Bitmap;
  New(PegPic[6]);
  PegPic[6]^ := img6.Picture.Bitmap;
  New(PegPic[7]);
  PegPic[7]^ := img7.Picture.Bitmap;
  New(PegPic[8]);
  PegPic[8]^ := img8.Picture.Bitmap;
  New(PegPic[9]);
  PegPic[9]^ := img9.Picture.Bitmap;
  New(MarkerPic[0]);
  MarkerPic[0]^ := imgm0.Picture.Bitmap;
  New(MarkerPic[1]);
  MarkerPic[1]^ := imgm1.Picture.Bitmap;
  New(MarkerPic[2]);
  MarkerPic[2]^ := imgm2.Picture.Bitmap;
  //Start new game
  NewGame();
end;

procedure TfrmMind.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
begin
  //Get clicked peg position; we will ignore Y, i.e. don't need to click on peg, just on peg "column"
  i := X div PegSize + 1;
  //Not a peg (e.g. a marker): exit
  if (i > NumPegs) then
  begin
    mnuCheckClick(frmMind);
    Exit;
  end;
  if Button = mbLeft then
  begin
    //Colour = NumColours: loop back to first one
    if (Guess[i] < NumColours) then
      Guess[i] := Guess[i] + 1
    else
      Guess[i] := 1;
  end
  else if Button = mbRight then
  begin
    //Colour = 1: loop back to last one
    if (Guess[i] > 1) then
      Guess[i] := Guess[i] - 1
    else
      Guess[i] := NumColours;
  end
  else if Button = mbMiddle then
    Guess[i] := PreviousGuess[i];
  //Update peg colour on board
  DrawPeg(i, GuessNumber, Guess[i]);
end;

end.

