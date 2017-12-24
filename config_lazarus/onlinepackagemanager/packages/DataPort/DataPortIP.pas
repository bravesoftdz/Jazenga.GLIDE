{
Asynchronous wrapper around Synapse TBlockSocket.

Sergey Bodrov, 2012-2016

When using UDP, remember, that it not session protocol, data delivery and correct
order not guaranteed. To start receive tde data, you must send empty packet to
remote side, it tell remote side return address.

Properties:
  RemoteHost - IP-address or name of remote host
  RemotePort - remote UPD or TCP port number

Methods:
  Open() - Connect to remote port. Session establiched for TCP and just port initialised for UDP. Init string format:
    InitStr = 'RemoteHost:RemotePort'
    RemoteHost - IP-address or name of remote host
    RemotePort - remote UPD or TCP port number

Events:
  OnOpen - Triggered after UDP port init or TCP session establiched.
}
unit DataPortIP;

interface

uses SysUtils, Classes, DataPort, synsock, blcksock, synautil;

type
  TIpProtocolEnum = (ippTCP, ippUDP);

  TIpClient = class(TThread)
  private
    Socket: TBlockSocket;
    s: string;
    bConnect: boolean;
    FOnIncomingMsgEvent: TMsgEvent;
    FOnErrorEvent: TMsgEvent;
    FOnConnect: TNotifyEvent;
    procedure SyncProc();
  protected
    procedure Execute(); override;
  public
    remoteHost: string;
    remotePort: string;
    protocol: TIpProtocolEnum;
    bLock: boolean;
    property OnIncomingMsgEvent: TMsgEvent read FOnIncomingMsgEvent
      write FOnIncomingMsgEvent;
    property OnErrorEvent: TMsgEvent read FOnErrorEvent write FOnErrorEvent;
    property OnConnect: TNotifyEvent read FOnConnect write FOnConnect;
    function SendString(s: string): boolean;
    procedure SendStream(st: TStream; Dest: string);
  end;

  { TDataPortIP }

  TDataPortIP = class(TDataPort)
  private
    //slReadData: TStringList; // for storing every incoming data packet separately
    sReadData: AnsiString;
    lock: TMultiReadExclusiveWriteSynchronizer;
    IpClient: TIpClient;
    FRemoteHost: string;
    FRemotePort: string;
    procedure OnIncomingMsgHandler(Sender: TObject; const AMsg: string);
    procedure OnErrorHandler(Sender: TObject; const AMsg: string);
    procedure OnConnectHandler(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    { Open() - Connect to remote port. Session establiched for TCP and just port initialised for UDP. Init string format:
      InitStr = 'RemoteHost:RemotePort'
      RemoteHost - IP-address or name of remote host
      RemotePort - remote UPD or TCP port number }
    procedure Open(const AInitStr: string = ''); override;
    procedure Close(); override;
    function Push(const AData: AnsiString): boolean; override;
    function Pull(size: integer = MaxInt): AnsiString; override;
    function Peek(size: integer = MaxInt): AnsiString; override;
    function PeekSize(): Cardinal; override;
  published
    { IP-address or name of remote host }
    property RemoteHost: string read FRemoteHost write FRemoteHost;
    { remote UPD or TCP port number }
    property RemotePort: string read FRemotePort write FRemotePort;
    property Active;
    property OnDataAppear;
    property OnError;
    { Triggered after UDP port init or TCP session establiched }
    property OnOpen;
    property OnClose;
  end;

  TDataPortTCP = class(TDataPortIP)
  public
    procedure Open(const AInitStr: string = ''); override;
  end;

  TDataPortUDP = class(TDataPortIP)
  public
    procedure Open(const AInitStr: string = ''); override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('DataPort', [TDataPortTCP]);
  RegisterComponents('DataPort', [TDataPortUDP]);
end;

// === TIpClient ===
procedure TIpClient.SyncProc();
begin
  //if s:='' then Exit;
  if bConnect then
  begin
    if Assigned(self.FOnConnect) then
      FOnConnect(self);
    bConnect := False;
    Exit;
  end;

  bLock := True;
  if Socket.LastError = 0 then
  begin
    if Assigned(self.FOnIncomingMsgEvent) then
      FOnIncomingMsgEvent(self, s);
  end
  else
  begin
    if Assigned(self.FOnErrorEvent) then
      FOnErrorEvent(self, s);
    self.Terminate();
  end;
  s := '';
  bLock := False;
end;

procedure TIpClient.Execute();
begin
  if self.protocol = ippUDP then
    Socket := TUDPBlockSocket.Create()
  else if self.protocol = ippTCP then
    Socket := TTCPBlockSocket.Create();

  try
    bConnect := False;
    Socket.Connect(remoteHost, remotePort);
    {s:='Connect '+remoteHost+':'+remotePort+' '+UdpSocket.LastErrorDesc;
    Synchronize(SyncProc);
    Sleep(100);}
    if Socket.LastError <> 0 then
    begin
      s := IntToStr(Socket.LastError) + ' ' + Socket.LastErrorDesc;
      Synchronize(SyncProc);
      //Exit;
      Self.Terminate();
    end
    else
    begin
      // Connected event
      bConnect := True;
      Synchronize(SyncProc);
    end;

    while not Terminated do
    begin
      s := Socket.RecvPacket(100);
      if Socket.LastError = 0 then
      begin
        Synchronize(SyncProc);
      end
      else if Socket.LastError = WSAETIMEDOUT then
      begin
        s := '';
      end
      else
      begin
        s := IntToStr(Socket.LastError) + ' ' + Socket.LastErrorDesc;
        Synchronize(SyncProc);
      end;
      Sleep(1);
    end;
    Socket.CloseSocket();
  finally
    FreeAndNil(Socket);
  end;
end;

function TIpClient.SendString(s: string): boolean;
begin
  Result := False;
  if Assigned(Socket) then
  begin
    Socket.SendString(s);
    if Socket.LastError <> 0 then
    begin
      s := IntToStr(Socket.LastError) + ' ' + Socket.LastErrorDesc;
      //Synchronize(SyncProc);
      SyncProc();
      Exit;
    end;
    Result := True;
  end;
end;

procedure TIpClient.SendStream(st: TStream; Dest: string);
var
  n: integer;
  ss, sh, sp: string;
begin
  if not Assigned(Socket) then
    Exit;
  if Dest = '' then
  begin
    //UdpSocket.SetRemoteSin(remoteHost, remotePort);
  end
  else
  begin
    ss := Dest;
    n := Pos(':', ss);
    sh := Copy(ss, 1, n - 1);
    sp := Copy(ss, n + 1, MaxInt);
    Socket.SetRemoteSin(sh, sp);
  end;
  st.Position := 0;
  Socket.SendStreamRaw(st);
  if Socket.LastError <> 0 then
  begin
    s := IntToStr(Socket.LastError) + ' ' + Socket.LastErrorDesc;
    Synchronize(SyncProc);
  end;
end;


{ TDataPortIP }

constructor TDataPortIP.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  self.lock := TMultiReadExclusiveWriteSynchronizer.Create();
  Self.FRemoteHost := '';
  Self.FRemotePort := '';
  Self.FActive := False;
  Self.sReadData := '';
  Self.IpClient := nil;
end;

procedure TDataPortIP.Open(const AInitStr: string = '');
var
  n: integer;
begin
  // Set host and port from init string
  if AInitStr <> '' then
  begin
    n := Pos(':', AInitStr);
    if n > 0 then
    begin
      Self.FRemoteHost := Copy(AInitStr, 1, n - 1);
      Self.FRemotePort := Copy(AInitStr, n + 1, MaxInt);
    end
    else
      Self.FRemoteHost := AInitStr;
  end;

  if Assigned(self.IpClient) then
    FreeAndNil(self.IpClient);
  {$ifdef FPC}
  Self.IpClient := TIpClient.Create(True, 4*1024);
  {$else}
  Self.IpClient := TIpClient.Create(True);
  {$endif}
  Self.IpClient.OnIncomingMsgEvent := Self.OnIncomingMsgHandler;
  Self.IpClient.OnErrorEvent := Self.OnErrorHandler;
  Self.IpClient.OnConnect := Self.OnConnectHandler;
  Self.IpClient.remoteHost := Self.FRemoteHost;
  Self.IpClient.remotePort := Self.FRemotePort;
  Self.IpClient.bLock := False;
  // thread resumed in inherited classes
  //Self.IpClient.Resume();
  //Self.FActive:=True;

  // don't inherits Open() - OnOpen event will be after successfull connection
end;

procedure TDataPortIP.Close();
begin
  if Active then
  begin
    if Assigned(self.IpClient) then
      self.IpClient.Terminate();
  end;
  inherited Close();
end;

destructor TDataPortIP.Destroy();
begin
  if Assigned(self.IpClient) then
    FreeAndNil(self.IpClient);
  FreeAndNil(self.lock);
  inherited Destroy();
end;

procedure TDataPortIP.OnIncomingMsgHandler(Sender: TObject; const AMsg: string);
begin
  if AMsg <> '' then
  begin
    if lock.BeginWrite then
    begin
      sReadData := sReadData + AMsg;
      lock.EndWrite;

      if Assigned(FOnDataAppear) then
        FOnDataAppear(self);
    end;
  end;
end;

procedure TDataPortIP.OnErrorHandler(Sender: TObject; const AMsg: string);
begin
  if Assigned(Self.FOnError) then
    Self.FOnError(Self, AMsg);
  self.FActive := False;
end;

function TDataPortIP.Peek(size: integer = MaxInt): AnsiString;
begin
  lock.BeginRead();
  Result := Copy(sReadData, 1, size);
  lock.EndRead();
end;

function TDataPortIP.PeekSize(): Cardinal;
begin
  lock.BeginRead();
  Result := Cardinal(Length(sReadData));
  lock.EndRead();
end;

function TDataPortIP.Pull(size: integer = MaxInt): AnsiString;
begin
  Result := '';
  if lock.BeginWrite() then
  begin
    try
      Result := Copy(sReadData, 1, size);
      Delete(sReadData, 1, size);
    finally
      lock.EndWrite();
    end;
  end;
end;

function TDataPortIP.Push(const AData: AnsiString): boolean;
begin
  Result := False;
  if Assigned(self.IpClient) and lock.BeginWrite() then
  begin
    try
      self.IpClient.SendString(AData);
      Result := True;
    finally
      lock.EndWrite();
    end;
  end;
end;

procedure TDataPortTCP.Open(const AInitStr: string = '');
begin
  inherited Open(AInitStr);
  Self.IpClient.protocol := ippTCP;
  Self.IpClient.Suspended := False;
  Self.FActive := True;
end;

procedure TDataPortUDP.Open(const AInitStr: string = '');
begin
  inherited Open(AInitStr);
  Self.IpClient.protocol := ippUDP;
  Self.IpClient.Suspended := False;
  Self.FActive := True;
end;

procedure TDataPortIP.OnConnectHandler(Sender: TObject);
begin
  Self.FActive := True;
  if Assigned(OnOpen) then
    OnOpen(Self);
end;



end.
