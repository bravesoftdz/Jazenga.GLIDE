unit pUCFrame_Log;

interface

{$I 'UserControl.inc'}

uses
{$IFDEF DELPHI5_UP}
  Variants,
{$ENDIF}
  Buttons,
  Classes,
  ComCtrls,
  Controls,
  DB,
  DBGrids,
  Dialogs,
  ExtCtrls,
  Forms,
  Graphics,
  Grids,
  ImgList,
  Messages,
  StdCtrls,
  {$IFDEF WINDOWS}Windows,{$ELSE}LCLType,{$ENDIF}
  SysUtils,
  {$IFDEF FPC}
  EditBtn, DateTimePicker,
  {$ENDIF}
  UCBase;

type

  { TUCFrame_Log }

  TUCFrame_Log = class(TFrame)
    DataSource1: TDataSource;
    ImageList1: TImageList;
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    lbUsuario: TLabel;
    lbData: TLabel;
    lbNivel: TLabel;
    Bevel3: TBevel;
    btfiltro: TBitBtn;
    btfecha: TBitBtn;
    btexclui: TBitBtn;
    ComboUsuario: TComboBox;
//    {$IFNDEF FPC}
    Data1: TDateTimePicker;
    Data2: TDateTimePicker;
//    {$ELSE}
//    Data1: TDateEdit;
//    Data2: TDateEdit;
//    {$ENDIF}
    ComboNivel: TComboBox;
    procedure ComboNivelDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure ComboUsuarioChange(Sender: TObject);
    procedure btexcluiClick(Sender: TObject);
    procedure Data1Change(Sender: TObject);
    procedure btfiltroClick(Sender: TObject);
  private
    procedure AplicaFiltro;
  public
    ListIdUser: TStringList;
    DSLog, DSCmd: TDataset;
    FUsercontrol: TUserControl;
    procedure SetWindow;
    destructor Destroy; override;
  end;

implementation

uses
  UCDataInfo;

{$R *.dfm}

destructor TUCFrame_Log.Destroy;
begin
  FreeAndnil(DSLog);
  FreeAndnil(DSCmd);
  FreeAndnil(ListIdUser);
  inherited;
end;

procedure TUCFrame_Log.ComboNivelDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  TempImg: Graphics.TBitmap;
begin
  TempImg := Graphics.TBitmap.Create;
  ImageList1.GetBitmap(Index, TempImg);
  ComboNivel.Canvas.Draw(Rect.Left + 5, Rect.Top + 1, TempImg);
  ComboNivel.Canvas.TextRect(Rect, Rect.Left + 30, Rect.Top + 2,
    ComboNivel.items[Index]);
  ComboNivel.Canvas.Draw(Rect.Left + 5, Rect.Top + 1, TempImg);
  FreeAndnil(TempImg);
end;

procedure TUCFrame_Log.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  TempImg: Graphics.TBitmap;
  FData: System.TDateTime;
  TempData: String;
begin
  if DSLog.IsEmpty then
    Exit;

  if UpperCase(Column.FieldName) = 'NIVEL' then
  begin
    if Column.Field.AsInteger >= 0 then
    begin
      TempImg := Graphics.TBitmap.Create;
      ImageList1.GetBitmap(Column.Field.AsInteger, TempImg);
      DBGrid1.Canvas.Draw((((Rect.Left + Rect.Right) - TempImg.Width) div 2),
        Rect.Top, TempImg);
      FreeAndnil(TempImg);
    end
    else
      DBGrid1.Canvas.TextRect(Rect, Rect.Left + 2, Rect.Top + 2,
        Column.Field.AsString);
  end
  else if UpperCase(Column.FieldName) = 'DATA' then
  begin
    TempData := Column.Field.AsString;
    FData := EncodeDate(StrToInt(Copy(TempData, 1, 4)),
      StrToInt(Copy(TempData, 5, 2)), StrToInt(Copy(TempData, 7, 2))) +
      EncodeTime(StrToInt(Copy(TempData, 9, 2)), StrToInt(Copy(TempData, 11, 2)
      ), StrToInt(Copy(TempData, 13, 2)), 0);
    DBGrid1.Canvas.TextRect(Rect, Rect.Left + 2, Rect.Top + 2,
      DateTimeToStr(FData));
  end
  else
    DBGrid1.Canvas.TextRect(Rect, Rect.Left + 2, Rect.Top + 2,
      Column.Field.AsString);
end;

procedure TUCFrame_Log.ComboUsuarioChange(Sender: TObject);
begin
  btfiltro.Enabled := True;
end;

procedure TUCFrame_Log.btexcluiClick(Sender: TObject);
var
  FTabLog, Temp: String;
begin
  // modified by fduenas
  if MessageBox(Handle, PChar(FUsercontrol.UserSettings.Log.PromptDelete),
    PChar(FUsercontrol.UserSettings.Log.PromptDelete_WindowCaption), mb_YesNo)
    <> mrYes then
    Exit;

  btfiltro.Enabled := False;
  FTabLog := FUsercontrol.LogControl.TableLog;
  {$IFNDEF FPC}
  Temp := 'Delete from ' + FTabLog + ' Where (Data >=' +
    QuotedStr(FormatDateTime('yyyyMMddhhmmss', Data1.DateTime)) + ') ' +
    ' and (Data <=' + QuotedStr(FormatDateTime('yyyyMMddhhmmss', Data2.DateTime)
    ) + ') ' + ' and nivel >=' + IntToStr(ComboNivel.ItemIndex);
  {$ELSE}
  Temp := 'Delete from ' + FTabLog + ' Where (Data >=' +
    QuotedStr(FormatDateTime('yyyyMMddhhmmss', Data1.Date)) + ') ' +
    ' and (Data <=' + QuotedStr(FormatDateTime('yyyyMMddhhmmss', Data2.Date)
    ) + ') ' + ' and nivel >=' + IntToStr(ComboNivel.ItemIndex);
  {$ENDIF}

  if ComboUsuario.ItemIndex > 0 then
    Temp := Temp + ' and ' + FTabLog + '.idUser = ' + ListIdUser
      [ComboUsuario.ItemIndex];

  try
    FUsercontrol.DataConnector.UCExecSQL(Temp);
    AplicaFiltro;
    DBGrid1.Repaint;
  except
  end;

  try
    {$IFNDEF FPC}
    FUsercontrol.Log(Format(FUsercontrol.UserSettings.Log.DeletePerformed,
      [ComboUsuario.Text, DateTimeToStr(Data1.DateTime),
      DateTimeToStr(Data2.DateTime), ComboNivel.Text]), 2);
    {$ELSE}
    FUsercontrol.Log(Format(FUsercontrol.UserSettings.Log.DeletePerformed,
      [ComboUsuario.Text, DateTimeToStr(Data1.Date),
      DateTimeToStr(Data2.Date), ComboNivel.Text]), 2);
    {$ENDIF}
  except
    ;
  end;

end;

procedure TUCFrame_Log.Data1Change(Sender: TObject);
begin
  btfiltro.Enabled := True;
end;

procedure TUCFrame_Log.btfiltroClick(Sender: TObject);
begin
  AplicaFiltro;
end;

procedure TUCFrame_Log.AplicaFiltro;
var
  FTabUser, FTabLog: String;
  Temp: String;
begin
  btfiltro.Enabled := False;
  DSLog.Close;
  FTabLog := FUsercontrol.LogControl.TableLog;
  FTabUser := FUsercontrol.TableUsers.TableName;

  {$IFNDEF FPC}
  Temp := Format('Select TabUser.' + FUsercontrol.TableUsers.FieldUserName +
    ' as nome, ' + FTabLog + '.* ' + 'from ' + FTabLog +
    '  Left outer join %s TabUser on ' + FTabLog + '.idUser = TabUser.%s ' +
    'Where (data >= ' + QuotedStr(FormatDateTime('yyyyMMddhhmmss',
    Data1.DateTime)) + ') ' + 'and (Data <= ' +
    QuotedStr(FormatDateTime('yyyyMMddhhmmss', Data2.DateTime)) + ') ' +
    'and nivel >= ' + IntToStr(ComboNivel.ItemIndex),
    [FUsercontrol.TableUsers.TableName, FUsercontrol.TableUsers.FieldUserID]);
  {$ELSE}
  Temp := Format('Select TabUser.' + FUsercontrol.TableUsers.FieldUserName +
    ' as nome, ' + FTabLog + '.* ' + 'from ' + FTabLog +
    '  Left outer join %s TabUser on ' + FTabLog + '.idUser = TabUser.%s ' +
    'Where (data >= ' + QuotedStr(FormatDateTime('yyyyMMddhhmmss',
    Data1.Date)) + ') ' + 'and (Data <= ' +
    QuotedStr(FormatDateTime('yyyyMMddhhmmss', Data2.Date)) + ') ' +
    'and nivel >= ' + IntToStr(ComboNivel.ItemIndex),
    [FUsercontrol.TableUsers.TableName, FUsercontrol.TableUsers.FieldUserID]);
  {$ENDIF}

  if ComboUsuario.ItemIndex > 0 then
    Temp := Temp + ' and ' + FTabLog + '.idUser = ' + ListIdUser
      [ComboUsuario.ItemIndex];

  Temp := Temp + ' order by data desc';

  FreeAndnil(DSLog);
  DataSource1.DataSet := nil;
  DSLog := FUsercontrol.DataConnector.UCGetSQLDataset(Temp);
  DataSource1.DataSet := DSLog;
  btexclui.Enabled := not DSLog.IsEmpty;
end;

procedure TUCFrame_Log.SetWindow;
var
  TabelaLog: String;
  SQLStmt: String;
begin
  ComboNivel.items.Clear;
  ComboNivel.items.Append(FUsercontrol.UserSettings.Log.OptionLevelLow); // BGM
  ComboNivel.items.Append(FUsercontrol.UserSettings.Log.OptionLevelNormal);
  // BGM
  ComboNivel.items.Append(FUsercontrol.UserSettings.Log.OptionLevelHigh); // BGM
  ComboNivel.items.Append(FUsercontrol.UserSettings.Log.OptionLevelCritic);
  // BGM
  ComboNivel.ItemIndex := 0;
  ComboUsuario.items.Clear;
  Data1.Date := EncodeDate(StrToInt(FormatDateTime('yyyy', Date)), 1, 1);
  {$IFNDEF FPC}
  Data2.DateTime := Now;
  {$ELSE}
  Data2.Date := Now;
  {$ENDIF}

  if Assigned(ListIdUser) = False then
    ListIdUser := TStringList.Create
  else
    ListIdUser.Clear;

  with FUsercontrol do
    if ((FUsercontrol.CurrentUser.Privileged = True) or
      (FUsercontrol.CurrentUser.UserLogin = FUsercontrol.Login.InitialLogin.
      User)) then
    begin
      DSCmd := DataConnector.UCGetSQLDataset
        (Format('SELECT %s AS IDUSER, %s AS NOME , %s AS LOGIN FROM %s WHERE %s  = %s ORDER BY %s',
        [TableUsers.FieldUserID, TableUsers.FieldUserName,
        TableUsers.FieldLogin, TableUsers.TableName, TableUsers.FieldTypeRec,
        QuotedStr('U'), TableUsers.FieldUserName]));
      ComboUsuario.items.Append(FUsercontrol.UserSettings.Log.OptionUserAll);
      ListIdUser.Append('0');
    end
    else
      DSCmd := DataConnector.UCGetSQLDataset
        (Format('SELECT %s AS IDUSER, %s AS NOME , %s AS LOGIN FROM %s WHERE %s  = %s and %s = %s ORDER BY %s',
        [TableUsers.FieldUserID, TableUsers.FieldUserName,
        TableUsers.FieldLogin, TableUsers.TableName, TableUsers.FieldTypeRec,
        QuotedStr('U'), TableUsers.FieldLogin,
        QuotedStr(FUsercontrol.CurrentUser.UserLogin),
        TableUsers.FieldUserName]));

  while not DSCmd.EOF do
  begin
    ComboUsuario.items.Append(DSCmd.FieldByName('Nome').AsString);
    ListIdUser.Append(DSCmd.FieldByName('idUser').AsString);
    DSCmd.Next;
  end;

  DSCmd.Close;
  FreeAndnil(DSCmd);

  ComboUsuario.ItemIndex := 0;

  TabelaLog := FUsercontrol.LogControl.TableLog;
  with FUsercontrol do
  begin
    {$IFNDEF FPC}
    SQLStmt := 'SELECT ' + TableUsers.TableName + '.' + TableUsers.FieldUserName
      + ' AS NOME, ' + TabelaLog + '.* from ' + TabelaLog + ' LEFT OUTER JOIN '
      + TableUsers.TableName + ' on ' + TabelaLog + '.idUser = ' +
      TableUsers.TableName + '.' + TableUsers.FieldUserID + ' WHERE (DATA >=' +
      QuotedStr(FormatDateTime('yyyyMMddhhmmss', Data1.DateTime)) +
      ') AND (DATA<=' + QuotedStr(FormatDateTime('yyyyMMddhhmmss',
      Data2.DateTime)) + ') ORDER BY DATA DESC';
    {$ELSE}
    SQLStmt := 'SELECT ' + TableUsers.TableName + '.' + TableUsers.FieldUserName
      + ' AS NOME, ' + TabelaLog + '.* from ' + TabelaLog + ' LEFT OUTER JOIN '
      + TableUsers.TableName + ' on ' + TabelaLog + '.idUser = ' +
      TableUsers.TableName + '.' + TableUsers.FieldUserID + ' WHERE (DATA >=' +
      QuotedStr(FormatDateTime('yyyyMMddhhmmss', Data1.Date)) +
      ') AND (DATA<=' + QuotedStr(FormatDateTime('yyyyMMddhhmmss',
      Data2.Date)) + ') ORDER BY DATA DESC';
    {$ENDIF}
    DSLog := DataConnector.UCGetSQLDataset(SQLStmt);
  end;
  DataSource1.DataSet := DSLog;
  btexclui.Enabled := not DSLog.IsEmpty;

  with FUsercontrol.UserSettings.Log, DBGrid1 do
  begin
    lbUsuario.Caption := LabelUser;
    lbData.Caption := LabelDate;
    lbNivel.Caption := LabelLevel;
    btfiltro.Caption := BtFilter;
    btexclui.Caption := BtDelete;
    btfecha.Caption := BtClose;

    { Columns[0].Title.Caption := ColAppID;
      Columns[0].FieldName     := 'APPLICATIONID';
      Columns[0].Width         := 60; }
    Columns[0].Title.Caption := ColLevel;
    Columns[0].FieldName := 'NIVEL';
    Columns[0].Width := 32;
    Columns[1].Title.Caption := ColMessage;
    Columns[1].FieldName := 'MSG';
    Columns[1].Width := 290;
    Columns[2].Title.Caption := ColUser;
    Columns[2].FieldName := 'NOME';
    Columns[2].Width := 120;
    Columns[3].Title.Caption := ColDate;
    Columns[3].FieldName := 'DATA';
    Columns[3].Width := 120;
  end;

  Bevel3.Width := Panel1.Width - 32;
  Bevel3.Left := 16;
end;

end.
