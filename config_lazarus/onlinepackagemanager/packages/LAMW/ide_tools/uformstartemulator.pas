unit uFormStartEmulator;

{$mode objfpc}{$H+}

interface

uses
  {$ifdef Windows}Windows{$else}XWindow{$endif},
  Classes, SysUtils, process, FileUtil, Forms, Controls, Graphics, Dialogs,
  Grids, ExtCtrls, Buttons, ActnList;

type
  TRunAndGetOutputProc = function (const cmd, params: string; Aout: TStrings): Integer of object;

  TAvdState = (asUnknown, asOffLine, asOnLine);

  { TfrmStartEmulator }

  TfrmStartEmulator = class(TForm)
    acRefresh: TAction;
    acStart: TAction;
    ActionList1: TActionList;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    bbOK: TBitBtn;
    BitBtn4: TBitBtn;
    bbAvdManager: TBitBtn;
    DrawGrid1: TDrawGrid;
    Panel1: TPanel;
    Timer1: TTimer;
    procedure acRefreshExecute(Sender: TObject);
    procedure acStartExecute(Sender: TObject);
    procedure acStartUpdate(Sender: TObject);
    procedure bbAvdManagerClick(Sender: TObject);
    procedure DrawGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; {%H-}aState: TGridDrawState);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
    FSDKPath: string;
    FRun: TRunAndGetOutputProc;
    devs, avds, emul_wnds: TStringList;
    StartPushed: Integer;
    function GetAvdState(Index: Integer): TAvdState;
  public
    { public declarations }
    constructor Create(ASDKPath: string; run: TRunAndGetOutputProc); reintroduce;
    destructor Destroy; override;
    procedure GetAVDList;
  end;

var
  frmStartEmulator: TfrmStartEmulator;

function FindEmulatorWindows(_para1: HWND; _para2: LPARAM): WINBOOL; stdcall;

implementation

uses LazFileUtils, UTF8Process, LamwSettings;

{$R *.lfm}

{ TfrmStartEmulator }

function FindEmulatorWindows(_para1: HWND; _para2: LPARAM): WINBOOL; stdcall;
var s: string;
begin
  SetLength(s, 255);
  {$ifdef windows}
  GetClassName(_para1, PChar(s), Length(s));
  if PChar(s) = 'SDL_app' then
  {$endif}
  begin
    GetWindowText(_para1, PChar(s), Length(s));
    TStrings(_para2).AddObject(PChar(s), TObject(_para1));
  end;
  Result := True;
end;

function TfrmStartEmulator.GetAvdState(Index: Integer): TAvdState;
var
  str: string;
  i, j: Integer;
begin
  Result := asOffLine;
  str := ':' + avds[Index];
  for i := 0 to emul_wnds.Count - 1 do
    if Pos(str, emul_wnds[i]) > 0 then
    begin
      str := emul_wnds[i];
      str := 'emulator-' + Copy(str, 1, Pos(':', str) - 1);
      Result := asUnknown;
      for j := 0 to devs.Count - 1 do
        if Pos(str, devs[j]) > 0 then
        begin
          Result := asOnLine;
          Break;
        end;
      Break;
    end;
end;

procedure TfrmStartEmulator.DrawGrid1DrawCell(Sender: TObject;
  aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
const
  AvdStateString: array [TAvdState] of string = ('unknown', 'off-line', 'on-line');
var
  s: string;
begin
  s := '';
  if aRow = 0 then Exit;
  if avds.Count = 0 then
    with DrawGrid1, Canvas do
    begin
      Brush.Color := clWindow;
      FillRect(aRect);
      Font.Color := clGrayText;
      Font.Style := [fsItalic];
      aRect := CellRect(0, 1);
      s := '(use AVD Manager to create AVDs)';
      TextOut(aRect.Left + (ClientWidth - TextWidth(s)) div 2, aRect.Top + 2, s);
      Exit;
    end;
  case aCol of
  0: s := avds[aRow - 1];
  1: s := AvdStateString[GetAvdState(aRow - 1)];
  end;
  if s <> '' then
    with DrawGrid1.Canvas do
      TextOut(aRect.Left + 2, aRect.Top + 2, s);
end;

procedure TfrmStartEmulator.Timer1Timer(Sender: TObject);
begin
  GetAVDList
end;

procedure TfrmStartEmulator.acStartUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (avds.Count > 0)
    and (DrawGrid1.Row <> StartPushed)
    and (GetAvdState(DrawGrid1.Row - 1) = asOffLine);
end;

procedure TfrmStartEmulator.bbAvdManagerClick(Sender: TObject);
begin
  with TProcessUTF8.Create(nil) do
  try
    Executable := LamwGlobalSettings.PathToAndroidSDK + 'tools'
      + PathDelim + 'android' {$ifdef windows} + '.bat'{$endif};
    Parameters.Add('avd');
    ShowWindow := swoHIDE;
    Execute;
  finally
    Free;
  end;
end;

procedure TfrmStartEmulator.acStartExecute(Sender: TObject);
begin
  StartPushed := DrawGrid1.Row;
  bbOK.SetFocus;
  with TProcessUTF8.Create(nil) do
  try
    ShowWindow := swoHIDE;
    Executable := AppendPathDelim(FSDKPath) + 'tools' + PathDelim + 'emulator';
    Parameters.Add('@' + avds[DrawGrid1.Row - 1]);
    Execute;
  finally
    Free;
  end;
end;

procedure TfrmStartEmulator.acRefreshExecute(Sender: TObject);
begin
  GetAVDList;
  StartPushed := 0;
end;

constructor TfrmStartEmulator.Create(ASDKPath: string;
  run: TRunAndGetOutputProc);
begin
  inherited Create(nil);
  FSDKPath := ASDKPath;
  FRun := run;
  avds := TStringList.Create;
  avds.Sorted := True;
  avds.Duplicates := dupIgnore;
  devs := TStringList.Create;
  emul_wnds := TStringList.Create;
  GetAVDList;
  if avds.Count = 0 then
    ActiveControl := bbAvdManager;
end;

destructor TfrmStartEmulator.Destroy;
begin
  avds.Free;
  devs.Free;
  emul_wnds.Free;
  inherited Destroy;
end;

procedure TfrmStartEmulator.GetAVDList;
var
  i, j: Integer;
begin
  devs.Clear;
  emul_wnds.Clear;

  avds.Sorted := False;
  FRun(AppendPathDelim(FSDKPath) + 'tools' + PathDelim + 'android'
    {$ifdef Windows} + '.bat'{$endif}, 'list' + sLineBreak + 'avds', avds);
  for i := avds.Count - 1 downto 0 do
  begin
    j := Pos(' Name: ', avds[i]);
    if j > 0 then
      avds[i] := Trim(Copy(avds[i], j + 7, MaxInt))
    else
      avds.Delete(i);
  end;
  avds.Sorted := True;

  for i := avds.Count - 1 downto 0 do
    if Trim(avds[i]) = '' then avds.Delete(i);
  FRun(AppendPathDelim(FSDKPath) + 'platform-tools' + PathDelim + 'adb', 'devices', devs);
  DrawGrid1.RowCount := avds.Count + 1 + Ord(avds.Count = 0);
  EnumWindows(@FindEmulatorWindows, LPARAM(emul_wnds));
  DrawGrid1.Invalidate;
end;

end.

