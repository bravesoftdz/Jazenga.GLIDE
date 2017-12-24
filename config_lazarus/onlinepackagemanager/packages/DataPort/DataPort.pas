{
DataPort - thread-safe abstract port for data exchange

Sergey Bodrov (serbod@gmail.com) 2012-2016

TDataPort is abstract component for reading and writing data to some port.
It don't do anything and needs to be used as property or parent class for new components.

Properties:
Active - is port ready for data exchange

Methods:
Open() - Open data port. If InitStr specified, set parameters from InitStr
Push() - Send data to port
Pull() - Get data from port. Data readed from incoming buffer, and removed after that.
  You can specify number of bytes for read. If incoming buffer have less bytes,
  than specified, then will be returned while buffer.
  By default, return whole buffer and clear it after.
Peek() - Read data from incoming buffer, but don't remove. You can specify number
  of bytes for read. If incoming buffer have less bytes, than specified,
  then will be returned while buffer. By default, return whole buffer.
PeekSize() - Returns number of bytes in incoming buffer of port.

Events:
OnDataAppear - Triggered in data appear in incoming buffer of dataport.
OnOpen - Triggered after sucсessful opening connection.
OnClose - Triggered when connection gracefully closed.
OnError - Triggered on error, contain error description.
}

unit DataPort;

interface

uses Classes;

type
  TMsgEvent = procedure(Sender: TObject; const AMsg: string) of object;

  { TDataPort }

  TDataPort = class(TComponent)
  protected
    FOnDataAppear: TNotifyEvent;
    FOnOpen: TNotifyEvent;
    FOnClose: TNotifyEvent;
    FOnError: TMsgEvent;
    FActive: Boolean;
    procedure SetActive(Val: Boolean); virtual;
  public
    property Active: Boolean read FActive write SetActive;
    { Occurs when new data appears in incoming buffer }
    property OnDataAppear: TNotifyEvent read FOnDataAppear write FOnDataAppear;
    { Occurs immediately after dataport has been sucsessfully opened }
    property OnOpen: TNotifyEvent read FOnOpen write FOnOpen;
    { Occurs after dataport has been closed }
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
    { Occurs when dataport operations fails, contain error description }
    property OnError: TMsgEvent read FOnError write FOnError;
    { Open dataport with specified initialization string
      If AInitStr not specified, used default or designed settings }
    procedure Open(const AInitStr: string = ''); virtual;
    { Close dataport }
    procedure Close(); virtual;
    { Write data string to port }
    function Push(const AData: AnsiString): Boolean; virtual; abstract;
    { Read and remove <size> bytes from incoming buffer. By default, read all data. }
    function Pull(size: Integer = MaxInt): AnsiString; virtual; abstract;
    { Read, but not remove <size> bytes from incoming buffer. }
    function Peek(size: Integer = MaxInt): AnsiString; virtual; abstract;
    { Get number of bytes waiting in incoming buffer }
    function PeekSize(): Cardinal; virtual; abstract;
  end;


implementation

{ TDataPort }

procedure TDataPort.SetActive(Val: Boolean);
begin
  if FActive = Val then
    Exit;
  if Val then
    Open()
  else
    Close();
end;

procedure TDataPort.Open(const AInitStr: string);
begin
  FActive := True;
  if Assigned(OnOpen) then
    OnOpen(self);
end;

procedure TDataPort.Close();
begin
  FActive := False;
  if Assigned(OnClose) then
    OnClose(self);
end;

end.
