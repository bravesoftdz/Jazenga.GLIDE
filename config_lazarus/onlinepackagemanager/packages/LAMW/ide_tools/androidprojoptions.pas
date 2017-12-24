unit AndroidProjOptions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, strings, LazFileUtils, laz2_XMLRead, Laz2_DOM,
  AvgLvlTree, IDEOptionsIntf, ProjectIntf, SourceChanger, Forms, Controls,
  Dialogs, Grids, StdCtrls, LResources, ExtCtrls, Spin, ComCtrls, Buttons,
  Themes;

type

  { TLamwAndroidManifestOptions }

  TLamwAndroidManifestOptions = class
  private
    xml: TXMLDocument; // AndroidManifest.xml
    FFileName: string;
    FPermissions: TStringList;
    FPermNames: TStringToStringTree;
    FUsesSDKNode: TDOMElement;
    FApplicationNode: TDOMElement;
    FMinSdkVersion, FTargetSdkVersion: Integer;
    FVersionCode: Integer;
    FVersionName: string;
    FLabelAvailable: Boolean;
    FLabel, FRealLabel: string;
    FIconFileName: string;
    FTheme: string;
    function GetString(const XMLPath, Ref: string; out Res: string): Boolean;
    function GetThemeName: string;
    procedure SetString(const XMLPath, Ref, NewValue: string);
    procedure Clear;
    procedure UpdateBuildXML;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Load(AFileName: string);
    procedure Save;

    function GetThemeName(API: Integer): string;

    property Permissions: TStringList read FPermissions;
    property PermNames: TStringToStringTree read FPermNames;
    property MinSDKVersion: Integer read FMinSdkVersion write FMinSdkVersion;
    property TargetSDKVersion: Integer read FTargetSdkVersion write FTargetSdkVersion;
    property VersionCode: Integer read FVersionCode write FVersionCode;
    property VersionName: string read FVersionName write FVersionName;
    property AppLabel: string read FRealLabel write FRealLabel;
    property IconFileName: string read FIconFileName;
    property ThemeName: string read GetThemeName;
  end;

  { TLamwProjectOptions }

  TLamwProjectOptions = class(TAbstractIDEOptionsEditor)
    cbTheme: TComboBox;
    cbLaunchIconSize: TComboBox;
    edLabel: TEdit;
    edVersionName: TEdit;
    ErrorPanel: TPanel;
    gbVersion: TGroupBox;
    GroupBox1: TGroupBox;
    ImageList1: TImageList;
    imLauncherIcon: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    lblErrorMessage: TLabel;
    PageControl1: TPageControl;
    PermissonGrid: TStringGrid;
    rbOrientation: TRadioGroup;
    seMinSdkVersion: TSpinEdit;
    seTargetSdkVersion: TComboBox;
    seVersionCode: TSpinEdit;
    SpeedButton1: TSpeedButton;
    SpeedButtonHintTheme: TSpeedButton;
    tsAppl: TTabSheet;
    tsManifest: TTabSheet;
    procedure cbLaunchIconSizeSelect(Sender: TObject);
    procedure PermissonGridCheckboxToggled({%H-}sender: TObject; {%H-}aCol,
      {%H-}aRow: Integer; {%H-}aState: TCheckboxState);
    procedure PermissonGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; {%H-}aState: TGridDrawState);
    procedure PermissonGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PermissonGridMouseMove(Sender: TObject; {%H-}Shift: TShiftState; X,
      Y: Integer);
    procedure seTargetSdkVersionEditingDone(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { private declarations }
    const
      Drawable: array [0..4] of record
        Size: Integer;
        Suffix: string;
      end = ((Size:36;  Suffix:'ldpi'),
             (Size:48;  Suffix:'mdpi'),
             (Size:72;  Suffix:'hdpi'),
             (Size:96;  Suffix:'xhdpi'),
             (Size:144; Suffix:'xxhdpi'));
  private
    FManifest: TLamwAndroidManifestOptions;
    FIconsPath: string; // ".../res/drawable-"
    FChkBoxDrawData: array [TCheckBoxState] of record
      Details, DetailsHot: TThemedElementDetails;
      CSize: TSize;
    end;
    FAllPermissionsState: TCheckBoxState;
    FAllPermissionsHot: Boolean;
    function GetAllPermissonsCheckBoxBounds(InRect: TRect): TRect;
    procedure ErrorMessage(const msg: string);
    procedure FillPermissionGrid(Permissions: TStringList; PermNames: TStringToStringTree);
    procedure SetControlsEnabled(ts: TTabSheet; en: Boolean);
    procedure ShowLauncherIcon;
  private
    // gApp.Screen.Style := <orientation> statements
    function GetCurrentAppScreenStyle: string;
    function FindAppScreenStyleStatement(out StartPos, ssConstStartPos,
      EndPos: integer): boolean;
    function GetAppScreenStyleStatement(ssConstStartPos: integer;
      out ssConstVal: string): boolean;
    function SetAppScreenStyleStatement(const ssNewConstVal: string): boolean;
    function RemoveAppScreenStyleStatement: boolean;
  public
    { public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function SupportedOptionsClass: TAbstractIDEOptionsClass; override;
    function GetTitle: String; override;
    procedure Setup({%H-}ADialog: TAbstractOptionsEditorDialog); override;
    procedure ReadSettings({%H-}AOptions: TAbstractIDEOptions); override;
    procedure WriteSettings({%H-}AOptions: TAbstractIDEOptions); override;
  end;

implementation

uses
  LazIDEIntf, laz2_XMLWrite, FileUtil, CodeToolManager, CodeTree, LinkScanner,
  CodeAtom, Graphics, ExtDlgs, AndroidWizard_intf, LamwDesigner, LamwSettings,
  FPCanvas, FPimage, FPReadPNG, FPWritePNG, strutils;

{$R *.lfm}

type

  { TMyCanvas }

  TMyCanvas = class(TCanvas)
  private
    FImage: TFPMemoryImage;
  protected
    procedure SetColor(x, y: integer; const Value: TFPColor); override;
  public
    constructor Create;
    destructor Destroy; override;
    property Image: TFPMemoryImage read FImage;
  end;

procedure ResizePNG(p: TPortableNetworkGraphic; NeedSize: Integer);
var
  ms: TMemoryStream;
  r: TFPReaderPNG;
  mi: TFPMemoryImage;
  c: TMyCanvas;
begin
  ms := TMemoryStream.Create;
  p.SaveToStream(ms);
  ms.Position := 0;
  mi := TFPMemoryImage.Create(0,0);
  r := TFPReaderPNG.Create;
  mi.LoadFromStream(ms, r);
  r.Free;
  ms.Free;
  c := TMyCanvas.Create;
  c.Image.SetSize(NeedSize, NeedSize);
  TFPCustomCanvas(c).StretchDraw(0, 0, NeedSize, NeedSize, mi);
  mi.Free;
  p.Assign(c.Image);
  c.Free;
end;

{ TMyCanvas }

procedure TMyCanvas.SetColor(x, y: integer; const Value: TFPColor);
begin
  FImage.Colors[x, y] := Value;
end;

constructor TMyCanvas.Create;
begin
  inherited;
  FImage := TFPMemoryImage.create(0,0);
end;

destructor TMyCanvas.Destroy;
begin
  FImage.Free;
  inherited;
end;

{ TLamwAndroidManifestOptions }

function TLamwAndroidManifestOptions.GetString(const XMLPath, Ref: string;
  out Res: string): Boolean;
var
  x: TXMLDocument;
  tag, name: string;
  n: TDOMNode;
begin
  Result := False;
  tag := Copy(Ref, 2, Pos('/', Ref) - 2);
  name := Copy(Ref, Pos('/', Ref) + 1, MaxInt);
  if not FileExists(XMLPath) then Exit;
  ReadXMLFile(x, XMLPath);
  try
    n := x.DocumentElement.FirstChild;
    while n <> nil do
    begin
      if (n is TDOMElement) then
        with TDOMElement(n) do
          if (TagName = tag) and (AttribStrings['name'] = name) then
          begin
            Res := TextContent;
            Result := True;
            Exit;
          end;
      n := n.NextSibling
    end;
  finally
    x.Free
  end;
end;

function TLamwAndroidManifestOptions.GetThemeName: string;
begin
  Result := GetThemeName(FTargetSdkVersion);
end;

procedure TLamwAndroidManifestOptions.SetString(const XMLPath, Ref, NewValue: string);
var
  x: TXMLDocument;
  n: TDOMNode;
  tag, name: string;
  Changed: Boolean;
begin
  tag := Copy(Ref, 2, Pos('/', Ref) - 2);
  name := Copy(Ref, Pos('/', Ref) + 1, MaxInt);
  ReadXMLFile(x, XMLPath);
  try
    n := x.DocumentElement.FirstChild;
    Changed := False;
    while n <> nil do
    begin
      if n is TDOMElement then
        with TDOMElement(n) do
          if (TagName = tag) and (AttribStrings['name'] = name) then
          begin
            TextContent := NewValue;
            Changed := True;
            Break;
          end;
      n := n.NextSibling;
    end;
    if not Changed then
    begin
      n := x.CreateElement(tag);
      with TDOMElement(n) do
      begin
        AttribStrings['name'] := name;
        TextContent := NewValue;
      end;
      x.DocumentElement.AppendChild(n);
    end;
    WriteXMLFile(x, XMLPath);
  finally
    x.Free
  end;
end;

procedure TLamwAndroidManifestOptions.Clear;
begin
  xml.Free;
  FUsesSDKNode := nil;
  FMinSdkVersion := 11;
  FTargetSdkVersion := 19;
  FPermissions.Clear;
end;

procedure TLamwAndroidManifestOptions.UpdateBuildXML;
var
  fn: string;
  build: TXMLDocument;
  n: TDOMNode;
begin
  fn := ExtractFilePath(FFileName) + 'build.xml';
  if not FileExists(fn) then Exit;
  ReadXMLFile(build, fn);
  try
    n := build.DocumentElement.FirstChild;
    while n <> nil do
    begin
      if n is TDOMElement then
        with TDOMElement(n) do
          if (TagName = 'property') and (AttribStrings['name'] = 'target') then
          begin
            AttribStrings['value'] := 'android-' + IntToStr(FTargetSdkVersion);
            WriteXMLFile(build, fn);
            Break;
          end;
      n := n.NextSibling;
    end;
  finally
    build.Free
  end;
end;

constructor TLamwAndroidManifestOptions.Create;

  procedure AddPerm(PermVisibleName: string; android_name: string = '');
  begin
    if android_name = '' then
      android_name := 'android.permission.'
        + StringReplace(UpperCase(PermVisibleName), ' ', '_', [rfReplaceAll]);
    FPermNames[android_name] := PermVisibleName;
  end;

begin
  FIconFileName := 'ic_launcher'; // ".png"
  FPermissions := TStringList.Create;
  FPermNames := TStringToStringTree.Create(True);
  AddPerm('Bluetooth');
  AddPerm('Access bluetooth share');
  AddPerm('Access coarse location');
  AddPerm('Access fine location');
  AddPerm('Access network state');
  AddPerm('Access wifi state');
  AddPerm('Bluetooth admin');
  AddPerm('Call phone');
  AddPerm('Camera');
  AddPerm('Change network state');
  AddPerm('Change wifi state');
  AddPerm('Internet');
  AddPerm('NFC');
  AddPerm('Read contacts');
  AddPerm('Read external storage');
  AddPerm('Read owner data');
  AddPerm('Read phone state');
  AddPerm('Receive SMS');
  AddPerm('Restart packages');
  AddPerm('Send SMS');
  AddPerm('Vibrate');
  AddPerm('Write contacts');
  AddPerm('Write external storage');
  AddPerm('Write owner data');
  AddPerm('Write user dictionary');
  AddPerm('Wake lock');
  { todo:
  Access location extra commands
  Access mock location
  Add voicemail
  Authenticate accounts
  Battery stats
  Bind accessibility service
  Bind device admin
  Bind input method
  Bind remoteviews
  Bind text service
  Bind vpn service
  Bind wallpaper
  Broadcast sticky
  Change configuration
  Change wifi multicast state
  Clear app cache
  Disable keyguard
  Expand status bar
  Flashlight
  Get accounts
  Get package size
  Get tasks
  Global search
  Kill background processes
  Manage accounts
  Modify audio settings
  Process outgoing calls
  Read calendar
  Read call log
  Read history bookmarks
  Read profile
  Read SMS
  Read social stream
  Read sync settings
  Read sync stats
  Read user dictionary
  Receive boot completed
  Receive MMS
  Receive WAP push
  Record audio
  Reorder tasks
  Set alarm
  Set time zone
  Set wallpaper
  Subscribed feeds read
  Subscribed feeds write
  System alert window
  Use credentials
  Use SIP
  Vending billing (In-app Billing)
  Write calendar
  Write call log
  Write history bookmarks
  Write profile
  Write settings
  Write SMS
  Write social stream
  Write sync settings
  Write user dictionary
  + Advanced...
  }
  FPermissions.Sorted := True;
end;

destructor TLamwAndroidManifestOptions.Destroy;
begin
  FPermNames.Free;
  FPermissions.Free;
  xml.Free;
  inherited Destroy;
end;

procedure TLamwAndroidManifestOptions.Load(AFileName: string);
var
  i, j: Integer;
  s, v: string;
  n: TDOMNode;
begin
  Clear;
  ReadXMLFile(xml, AFileName);
  FFileName := AFileName;
  if (xml = nil) or (xml.DocumentElement = nil) then Exit;
  with xml.DocumentElement do
  begin
    FVersionCode := StrToIntDef(AttribStrings['android:versionCode'], 1);
    FVersionName := AttribStrings['android:versionName'];
  end;
  with xml.DocumentElement.ChildNodes do
  begin
    FPermNames.GetNames(FPermissions);
    for i := Count - 1 downto 0 do
      if Item[i].NodeName = 'uses-permission' then
      begin
        s := Item[i].Attributes.GetNamedItem('android:name').TextContent;
        j := FPermissions.IndexOf(s);
        if j >= 0 then
          FPermissions.Objects[j] := TObject(PtrUInt(1))
        else begin
          v := Copy(s, RPos('.', s) + 1, MaxInt);
          FPermNames[s] := v;
          FPermissions.AddObject(s, TObject(PtrUInt(1)));
        end;
        xml.ChildNodes[0].DetachChild(Item[i]).Free;
      end else
      if Item[i].NodeName = 'uses-sdk' then
      begin
        FUsesSDKNode := Item[i] as TDOMElement;
        n := FUsesSDKNode.Attributes.GetNamedItem('android:minSdkVersion');
        if Assigned(n) then
          FMinSdkVersion := StrToIntDef(n.TextContent, FMinSdkVersion);
        n := FUsesSDKNode.Attributes.GetNamedItem('android:targetSdkVersion');
        if Assigned(n) then
          FTargetSdkVersion := StrToIntDef(n.TextContent, FTargetSdkVersion);
      end;
  end;
  n := xml.DocumentElement.FindNode('application');
  if n is TDOMElement then
  begin
    FApplicationNode := TDOMElement(n);
    FLabelAvailable := True;
    FLabel := TDOMElement(n).AttribStrings['android:label'];
    if (FLabel <> '') and (FLabel[1] = '@') then
    begin
      // @string/app_name
      // <string name="app_name">LamwGUIProject1</string>
      if not GetString(ExtractFilePath(FFileName) + PathDelim
        + 'res' + PathDelim + 'values' + PathDelim + 'strings.xml', FLabel, FRealLabel)
      then begin
        FRealLabel := '<null>';
        FLabelAvailable := False;
      end;
    end else
      FRealLabel := FLabel;

    FTheme := FApplicationNode.AttribStrings['android:theme'];
  end;
end;

procedure TLamwAndroidManifestOptions.Save;
var
  i: Integer;
  r: TDOMNode;
  n: TDOMElement;
  fn: string;
begin
  // writing manifest
  if not Assigned(xml) then Exit;

  xml.DocumentElement.AttribStrings['android:versionCode'] := IntToStr(FVersionCode);
  xml.DocumentElement.AttribStrings['android:versionName'] := FVersionName;

  if not Assigned(FUsesSDKNode) then
  begin
    FUsesSDKNode := xml.CreateElement('uses-sdk');
    with xml.DocumentElement do
      if ChildNodes.Count = 0 then
        AppendChild(FUsesSDKNode)
      else
        InsertBefore(FUsesSDKNode, ChildNodes[0]);
  end;
  with FUsesSDKNode do
  begin
    AttribStrings['android:minSdkVersion'] := IntToStr(FMinSdkVersion);
    AttribStrings['android:targetSdkVersion'] := IntToStr(FTargetSdkVersion);
  end;

  // permissions
  r := FUsesSDKNode.NextSibling;
  for i := 0 to FPermissions.Count - 1 do
  begin
    n := xml.CreateElement('uses-permission');
    n.AttribStrings['android:name'] := FPermissions[i];
    if Assigned(r) then
      xml.ChildNodes[0].InsertBefore(n, r)
    else
      xml.ChildNodes[0].AppendChild(n);
  end;
  UpdateBuildXML;

  if FLabelAvailable and (FLabel <> '') and (FLabel[1] <> '@')
  and (FApplicationNode <> nil) then
    FApplicationNode.AttribStrings['android:label'] := FLabel;
  WriteXMLFile(xml, FFileName);

  if FLabelAvailable and (FLabel <> '') and (FLabel[1] = '@') then
  begin
    fn := ExtractFilePath(FFileName) + PathDelim + 'res' + PathDelim;
    fn := fn + 'values' + PathDelim + 'strings.xml';
    if FileExists(fn) then
      SetString(fn, FLabel, FRealLabel)
  end;

  // refresh theme
  with LazarusIDE do
    if (ActiveProject.FileCount > 1) and (ActiveProject.CustomData['LAMW'] = 'GUI') then
      (TAndroidModule(GetDesignerWithProjectFile(ActiveProject.Files[1], True).LookupRoot).Designer as TAndroidWidgetMediator).UpdateTheme;
end;

function TLamwAndroidManifestOptions.GetThemeName(API: Integer): string;
var
  fn, base: string;
  x: TXMLDocument;
  n: TDOMNode;
begin
  Result := FTheme;
  if Copy(FTheme, 1, 7) <> '@style/' then Exit;
  Delete(Result, 1, 7);
  base := ExtractFilePath(FFileName) + 'res' + PathDelim + 'values';
  fn := base + PathDelim + 'styles.xml';
  repeat
    if not FileExists(fn) then Exit;
    ReadXMLFile(x, fn);
    try
      n := x.DocumentElement.FirstChild;
      while n <> nil do
      begin
        if n is TDOMElement then
          with TDOMElement(n) do
          begin
            if (TagName = 'style') and (AttribStrings['name'] = Result) then
              if AttribStrings['parent'] <> '' then
                Result := AttribStrings['parent']
              else
                Exit;
          end;
        n := n.NextSibling;
      end;
      repeat
        fn := base + '-v' + IntToStr(API) + PathDelim + 'styles.xml';
        Dec(API);
      until FileExists(fn) or (API = 0);
    finally
      x.Free;
    end;
  until strlcomp('android:', PChar(Result), 8) = 0;
  Delete(Result, 1, 8);
end;

{ TLamwProjectOptions }

procedure TLamwProjectOptions.SetControlsEnabled(ts: TTabSheet;
  en: Boolean);
var
  i: Integer;
begin
  with ts do
    for i := 0 to ControlCount - 1 do
      Controls[i].Enabled := en;
  ErrorPanel.Enabled := True;
end;

procedure TLamwProjectOptions.ShowLauncherIcon;
var
  p: TPortableNetworkGraphic;
  fn: string;
begin
  with cbLaunchIconSize do
    p := TPortableNetworkGraphic(Items.Objects[ItemIndex]);
  if p <> nil then
  begin
    imLauncherIcon.Picture.Assign(p);
    Exit;
  end;
  fn := FIconsPath + Drawable[cbLaunchIconSize.ItemIndex].Suffix + PathDelim
    + FManifest.IconFileName + '.png';
  if FileExists(fn) then
    imLauncherIcon.Picture.LoadFromFile(fn)
  else
    imLauncherIcon.Picture.Clear;
end;

function TLamwProjectOptions.GetCurrentAppScreenStyle: string;
var
  StyleStartPos, StartPos, EndPos: integer;
begin
  if FindAppScreenStyleStatement(StartPos, StyleStartPos, EndPos) then
    GetAppScreenStyleStatement(StyleStartPos, Result)
  else
    Result := '';
end;

function TLamwProjectOptions.FindAppScreenStyleStatement(
  out StartPos, ssConstStartPos, EndPos: integer): boolean;
var
  MainBeginNode: TCodeTreeNode;
  Position: Integer;
begin
  Result := False;
  StartPos := -1;
  ssConstStartPos := -1;
  EndPos := -1;
  with CodeToolBoss do
  begin
    InitCurCodeTool(FindFile(LazarusIDE.ActiveProject.MainFile.GetFullFilename));
    if CurCodeTool = nil then Exit;
    with CurCodeTool do
    begin
      BuildTree(lsrEnd);
      MainBeginNode := FindMainBeginEndNode;
      if MainBeginNode = nil then Exit;
      Position := MainBeginNode.StartPos;
      if Position < 1 then Exit;
      MoveCursorToCleanPos(Position);
      repeat
        ReadNextAtom;
        if UpAtomIs('GAPP') then
        begin
          StartPos := CurPos.StartPos;
          if ReadNextAtomIsChar('.') and ReadNextUpAtomIs('SCREEN')
          and ReadNextUpAtomIs('.') and ReadNextUpAtomIs('STYLE')
          and ReadNextUpAtomIs(':=') then
          begin
            // read till semicolon or end
            repeat
              ReadNextAtom;
              if ssConstStartPos < 1 then
                ssConstStartPos := CurPos.StartPos;
              EndPos := CurPos.EndPos;
              if CurPos.Flag in [cafEnd, cafSemicolon] then begin
                Result := True;
                Exit;
              end;
            until CurPos.StartPos > SrcLen;
          end;
        end;
      until CurPos.StartPos > SrcLen;
    end;
  end;
end;

function TLamwProjectOptions.GetAppScreenStyleStatement(
  ssConstStartPos: integer; out ssConstVal: string): boolean;
begin
  Result := False;
  ssConstVal := '';
  with CodeToolBoss do
  begin
    InitCurCodeTool(FindFile(LazarusIDE.ActiveProject.MainFile.GetFullFilename));
    if CurCodeTool = nil then Exit;
    with CurCodeTool do
    begin
      if (ssConstStartPos < 1) or (ssConstStartPos > SrcLen) then Exit;
      MoveCursorToCleanPos(ssConstStartPos);
      ReadNextAtom;
      if not AtomIsIdentifier then Exit;
      ssConstVal := GetAtom;
      Result := True;
    end;
  end;
end;

function TLamwProjectOptions.SetAppScreenStyleStatement(
  const ssNewConstVal: string): boolean;
var
  StartPos, ssConstStartPos, EndPos: integer;
  OldExists, Found: Boolean;
  NewStatement: String;
  Indent: Integer;
  MainBeginNode: TCodeTreeNode;
  Beauty: TBeautifyCodeOptions;
begin
  Result := False;
  with CodeToolBoss do
  begin
    InitCurCodeTool(FindFile(LazarusIDE.ActiveProject.MainFile.GetFullFilename));
    if CurCodeTool = nil then Exit;
    with CurCodeTool do
    begin
      // search old Application.Title:= statement
      Beauty := SourceChangeCache.BeautifyCodeOptions;
      OldExists := FindAppScreenStyleStatement(StartPos, ssConstStartPos, EndPos);
      if OldExists then
      begin
        // replace old statement
        Indent := 0;
        Indent := Beauty.GetLineIndent(Src, StartPos)
      end else begin
        // insert as first line after "gApp := ...;" in program begin..end block
        MainBeginNode := FindMainBeginEndNode;
        if MainBeginNode = nil then Exit;
        MoveCursorToNodeStart(MainBeginNode);
        Found := False;
        ReadNextAtom;
        repeat
          if UpAtomIs('GAPP') and ReadNextAtomIs(':=') then
          begin
            while CurPos.StartPos < SrcLen do
            begin
              ReadNextAtom;
              if AtomIs(';') then
              begin
                Found := True;
                Break;
              end;
            end;
            if not Found then Exit;
          end;
          if Found then Break;
          ReadNextAtom;
        until CurPos.StartPos > SrcLen;
        StartPos := CurPos.EndPos;
        EndPos := StartPos;
        Indent := Beauty.GetLineIndent(Src, StartPos);
      end;
      // create statement
      NewStatement := 'gApp.Screen.Style:=' + ssNewConstVal + ';';
      NewStatement := Beauty.BeautifyStatement(NewStatement, Indent);
      SourceChangeCache.MainScanner := Scanner;
      if not SourceChangeCache.Replace(gtNewLine, gtNewLine, StartPos, EndPos,
                                       NewStatement)
      then
        Exit;
      if not SourceChangeCache.Apply then Exit;
      Result := True;
    end;
  end;
end;

function TLamwProjectOptions.RemoveAppScreenStyleStatement: boolean;
var
  StartPos, StringConstStartPos, EndPos: integer;
  OldExists: Boolean;
  FromPos: Integer;
  ToPos: Integer;
begin
  Result := False;
  // search old Application.Title:= statement
  OldExists := FindAppScreenStyleStatement(StartPos, StringConstStartPos, EndPos);
  if not OldExists then begin
    Result := True;
    Exit;
  end;
  with CodeToolBoss do
  begin
    InitCurCodeTool(FindFile(LazarusIDE.ActiveProject.MainFile.GetFullFilename));
    if CurCodeTool = nil then Exit;
    with CurCodeTool do
    begin
      // -> delete whole line
      FromPos := FindLineEndOrCodeInFrontOfPosition(StartPos);
      ToPos := FindLineEndOrCodeAfterPosition(EndPos);
      SourceChangeCache.MainScanner := Scanner;
      if not SourceChangeCache.Replace(gtNone, gtNone, FromPos, ToPos, '') then
        Exit;
      if not SourceChangeCache.Apply then Exit;
      Result := True;
    end;
  end;
end;

constructor TLamwProjectOptions.Create(AOwner: TComponent);
const
  chk_st: array [TCheckboxState] of TThemedButton = (
    tbCheckBoxUncheckedNormal,
    tbCheckBoxCheckedNormal,
    tbCheckBoxMixedNormal
  );
  chk_st_hot: array [TCheckboxState] of TThemedButton = (
    tbCheckBoxUncheckedHot,
    tbCheckBoxCheckedHot,
    tbCheckBoxMixedHot
  );
var
  s: TCheckBoxState;
  sl: TStringList;
  i: Integer;
begin
  inherited Create(AOwner);
  FManifest := TLamwAndroidManifestOptions.Create;
  PageControl1.ActivePageIndex := 0;

  for s := Low(TCheckBoxState) to High(TCheckBoxState) do
    with FChkBoxDrawData[s] do
    begin
      Details := ThemeServices.GetElementDetails(chk_st[s]);
      DetailsHot := ThemeServices.GetElementDetails(chk_st_hot[s]);
      CSize := ThemeServices.GetDetailSize(Details);
    end;

  sl := FindAllDirectories(LamwGlobalSettings.PathToAndroidSDK + PathDelim + 'platforms', False);
  try
    for i := 0 to sl.Count - 1 do
    begin
      sl[i] := ExtractFileName(sl[i]);
      if Copy(sl[i], 1, 8) = 'android-' then
        seTargetSdkVersion.Items.Add(Copy(sl[i], 9, MaxInt))
    end;
  finally
    sl.Free;
  end;

  PermissonGrid.DoubleBuffered := True;
end;

destructor TLamwProjectOptions.Destroy;
var
  i: Integer;
begin
  with cbLaunchIconSize.Items do
    for i := 0 to Count - 1 do
      TObject(Objects[i]).Free;
  FManifest.Free;
  inherited Destroy;
end;

procedure TLamwProjectOptions.cbLaunchIconSizeSelect(Sender: TObject);
begin
  ShowLauncherIcon;
end;

procedure TLamwProjectOptions.PermissonGridCheckboxToggled(sender: TObject;
  aCol, aRow: Integer; aState: TCheckboxState);
var
  r: Integer;
begin
  if PermissonGrid.Cells[1, 1] = '1' then
    FAllPermissionsState := cbChecked
  else
    FAllPermissionsState := cbUnchecked;
  for r := 2 to PermissonGrid.RowCount - 1 do
    if (PermissonGrid.Cells[1, r] = '1') and (FAllPermissionsState = cbUnchecked)
    or (PermissonGrid.Cells[1, r] = '0') and (FAllPermissionsState = cbChecked) then
    begin
      FAllPermissionsState := cbGrayed;
      Break;
    end;
  PermissonGrid.InvalidateCell(1, 0);
end;

procedure TLamwProjectOptions.PermissonGridDrawCell(Sender: TObject; aCol,
  aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  d: TThemedElementDetails;
  r: TRect;
begin
  if (aCol = 1) and (aRow = 0) then
  begin
    r := GetAllPermissonsCheckBoxBounds(aRect);
    if FAllPermissionsHot then
      d := FChkBoxDrawData[FAllPermissionsState].DetailsHot
    else
      d := FChkBoxDrawData[FAllPermissionsState].Details;
    ThemeServices.DrawElement(PermissonGrid.Canvas.Handle, d, r, nil)
  end;
 end;

procedure TLamwProjectOptions.PermissonGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  c, r: Integer;
  NewVal: Char;
begin
  if (Button = mbLeft) and ([ssShift,ssCtrl] * Shift = []) then
  begin
    with PermissonGrid.MouseCoord(X, Y) do
    begin
      c := X; r := Y;
    end;
    if (c = 1) and (r = 0)
    and PtInRect(GetAllPermissonsCheckBoxBounds(PermissonGrid.CellRect(c, r)), Point(X, Y)) then
    begin
      if FAllPermissionsState = cbChecked then
      begin
        FAllPermissionsState := cbUnchecked;
        NewVal := '0';
      end else begin
        FAllPermissionsState := cbChecked;
        NewVal := '1';
      end;
      PermissonGrid.BeginUpdate;
      try
        for r := 1 to PermissonGrid.RowCount - 1 do
          PermissonGrid.Cells[1, r] := NewVal;
      finally
        PermissonGrid.EndUpdate;
      end;
    end;
  end;
end;

procedure TLamwProjectOptions.PermissonGridMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  c, r: LongInt;
  b: Boolean;
begin
  with PermissonGrid.MouseCoord(X, Y) do
  begin
    c := X; r := Y;
  end;
  if (c = 1) and (r = 0) then
  begin
    b := PtInRect(
      GetAllPermissonsCheckBoxBounds(PermissonGrid.CellRect(c, r)),
      Point(X, Y));
    if FAllPermissionsHot <> b then
    begin
      FAllPermissionsHot := b;
      PermissonGrid.InvalidateCell(c, r);
    end;
  end;
end;

procedure TLamwProjectOptions.seTargetSdkVersionEditingDone(Sender: TObject);
var
  i: Integer;
begin
  if not TryStrToInt(seTargetSdkVersion.Text, i) then
    seTargetSdkVersion.Color := RGBToColor(255,205,205)
  else begin
    seTargetSdkVersion.Color := clDefault;
    cbTheme.Text := FManifest.GetThemeName(i);
  end;
end;

procedure TLamwProjectOptions.SpeedButton1Click(Sender: TObject);

  function CreateAllIcons(p: TPortableNetworkGraphic; fname: string): Boolean;
  var
    i: Integer;
    p1: TPortableNetworkGraphic;
  begin
    Result := MessageDlg(
      Format('Do you want to prepare all other icons by resizing "%s"?',
        [ExtractFileName(fname)]),
      mtConfirmation, mbYesNo, 0) = mrYes;
    if Result then
      with cbLaunchIconSize.Items do
      begin
        for i := 0 to Count - 1 do
        begin
          p1 := TPortableNetworkGraphic.Create;
          p1.Assign(p);
          if p1.Width <> Drawable[i].Size then
            ResizePNG(p1, Drawable[i].Size);
          Objects[i] := p1;
        end;
        p.Free;
      end;
  end;

var
  p: TPortableNetworkGraphic;
begin
  with TOpenPictureDialog.Create(nil) do
  try
    Title := Format('%s (%s)', [GroupBox1.Caption, cbLaunchIconSize.Text]);
    Filter := 'PNG|*.png';
    if Execute then
    begin
      p := TPortableNetworkGraphic.Create;
      p.LoadFromFile(FileName);
      with Drawable[cbLaunchIconSize.ItemIndex] do
        if (p.Width <> Size) or (p.Height <> Size) then
          case MessageDlg(
            Format('The size of "%s" is %dx%d but should be %dx%d. Do you want to resize?',
              [ExtractFileName(FileName), p.Width, p.Height, Size, Size]),
            mtConfirmation, mbYesNoCancel, 0) of
          mrYes:
            begin
              if (p.Width = p.Height) and (p.Height > 90) then
                if CreateAllIcons(p, FileName) then Exit;
              ResizePNG(p, Size);
            end
          else
            p.Free;
            Exit;
          end
        else
          if (Size > 90) then
            if CreateAllIcons(p, FileName) then Exit;
      with cbLaunchIconSize do
        Items.Objects[ItemIndex] := p;
    end;
  finally
    Free;
    ShowLauncherIcon;
  end;
end;

function TLamwProjectOptions.GetAllPermissonsCheckBoxBounds(InRect: TRect): TRect;
begin
  Result := InRect;
  with FChkBoxDrawData[FAllPermissionsState], Result do
  begin
    Left := Left + 2;
    Top := (Top + Bottom - CSize.cy) div 2;
    Right := Left + CSize.cx;
    Bottom := Top + CSize.cy;
  end;
end;

procedure TLamwProjectOptions.ErrorMessage(const msg: string);
begin
  lblErrorMessage.Caption := msg;
  ErrorPanel.Visible := True;
  ErrorPanel.Enabled := True;
end;

procedure TLamwProjectOptions.FillPermissionGrid(Permissions: TStringList;
  PermNames: TStringToStringTree);
var
  i: Integer;
  n: string;
begin
  PermissonGrid.BeginUpdate;
  try
    PermissonGrid.RowCount := Permissions.Count + 1;
    with PermissonGrid do
      for i := 0 to Permissions.Count - 1 do
      begin
        n := PermNames[Permissions[i]];
        if n = '' then
          n := Permissions[i];
        Cells[0, i + 1] := n;
        if Permissions.Objects[i] = nil then
        begin
          if i = 0 then
            FAllPermissionsState := cbUnchecked
          else
          if FAllPermissionsState = cbChecked then
            FAllPermissionsState := cbGrayed;
          Cells[1, i + 1] := '0';
        end else begin
          if i = 0 then
            FAllPermissionsState := cbChecked
          else
          if FAllPermissionsState = cbUnchecked then
            FAllPermissionsState := cbGrayed;
          Cells[1, i + 1] := '1';
        end;
      end;
  finally
    PermissonGrid.EndUpdate;
  end;
end;

class function TLamwProjectOptions.SupportedOptionsClass: TAbstractIDEOptionsClass;
begin
  Result := nil;
end;

function TLamwProjectOptions.GetTitle: string;
begin
  Result := '[Lamw] Android Project Options';
end;

procedure TLamwProjectOptions.Setup(ADialog: TAbstractOptionsEditorDialog);
begin
  // localization
end;

procedure TLamwProjectOptions.ReadSettings(AOptions: TAbstractIDEOptions);
var
  proj: TLazProject;
  fn, s: string;
begin
  // reading manifest
  SetControlsEnabled(tsManifest, False);
  proj := LazarusIDE.ActiveProject;
  if (proj = nil) or (proj.IsVirtual) then Exit;
  fn := proj.MainFile.Filename;
  fn := Copy(fn, 1, Pos(PathDelim + 'jni' + PathDelim, fn));
  fn := fn + 'AndroidManifest.xml';
  if not FileExists(fn) then
  begin
    ErrorMessage('"' + fn + '" not found!');
    tsAppl.Enabled := False;
    Exit;
  end;
  try
    FIconsPath := ExtractFilePath(fn) + 'res' + PathDelim + 'drawable-';
    ShowLauncherIcon;
    with FManifest do
    begin
      Load(fn);
      FillPermissionGrid(Permissions, PermNames);
      seMinSdkVersion.Value := MinSDKVersion;
      seTargetSdkVersion.Text := IntToStr(TargetSDKVersion);
      seVersionCode.Value := VersionCode;
      edVersionName.Text := VersionName;
      edLabel.Text := AppLabel;
    end;
  except
    on e: Exception do
    begin
      ErrorMessage(e.Message);
      Exit;
    end
  end;
  cbTheme.Text := FManifest.ThemeName;
  s := GetCurrentAppScreenStyle;
  if SameText(s, 'ssPortrait') then
    rbOrientation.ItemIndex := 1
  else
  if SameText(s, 'ssLandscape') then
    rbOrientation.ItemIndex := 2
  else
    rbOrientation.ItemIndex := 0;
  SetControlsEnabled(tsManifest, True);
end;

procedure TLamwProjectOptions.WriteSettings(AOptions: TAbstractIDEOptions);
const
  ScreenStyles: array [0..2] of string = (
    'ssSensor', 'ssPortrait', 'ssLandscape'
  );
var
  i: Integer;
  s: string;
begin
  with FManifest do
  begin
    for i := PermissonGrid.RowCount - 1 downto 1 do
      if PermissonGrid.Cells[1, i] <> '1' then
        Permissions.Delete(i - 1);
    MinSDKVersion := seMinSdkVersion.Value;
    if TryStrToInt(seTargetSdkVersion.Text, i) then
      TargetSDKVersion := i;
    VersionCode := seVersionCode.Value;
    VersionName := edVersionName.Text;
    AppLabel := edLabel.Text;
    Save;
  end;

  s := GetCurrentAppScreenStyle;
  if s = '' then s := ScreenStyles[0];
  if s <> ScreenStyles[rbOrientation.ItemIndex] then
  begin
    if rbOrientation.ItemIndex = 0 then
      RemoveAppScreenStyleStatement
    else
      SetAppScreenStyleStatement(ScreenStyles[rbOrientation.ItemIndex]);
  end;

  with cbLaunchIconSize.Items do
    for i := 0 to Count - 1 do
      if Assigned(Objects[i]) then
        TPortableNetworkGraphic(Objects[i]).SaveToFile(FIconsPath
          + Drawable[i].Suffix + PathDelim + FManifest.IconFileName + '.png');
end;

initialization
  RegisterIDEOptionsEditor(GroupProject, TLamwProjectOptions, 1000);

end.

