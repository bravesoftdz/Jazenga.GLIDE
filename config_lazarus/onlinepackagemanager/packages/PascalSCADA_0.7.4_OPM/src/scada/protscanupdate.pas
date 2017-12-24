{$i ../common/language.inc}
{$IFDEF PORTUGUES}
{:
@abstract(Atualiza os valores dos tags.)
@author(Fabio Luis Girardi fabio@pascalscada.com)
}
{$ELSE}
{:
@abstract(Updates the tag values.)
@author(Fabio Luis Girardi fabio@pascalscada.com)
}
{$ENDIF}
unit protscanupdate;

{$IFDEF FPC}
{$IFDEF DEBUG}
  {$DEFINE FDEBUG}
{$ENDIF}
{$ENDIF}

interface

uses
  Classes, SysUtils, CrossEvent, ProtocolTypes, MessageSpool, syncobjs, tag;

type

  TUserUpdateTimeProc = procedure (usertime: Double) of object;

  {$IFDEF PORTUGUES}
  {:
  @author(Fabio Luis Girardi <fabio@pascalscada.com>)
  Classe de thread responsável por atualizar os valores dos tags. Usado por
  TProtocolDriver.
  @seealso(TProtocolDriver)
  }
  {$ELSE}
  {:
  @author(Fabio Luis Girardi <fabio@pascalscada.com>)
  Class of thread that updates the tag values. Used by TProtocolDriver.
  @seealso(TProtocolDriver)
  }
  {$ENDIF}
  TScanUpdate = class(TCrossThread)
  private
    FUserUpdateTimePRoc:TUserUpdateTimeProc;
    FOwnerProtocolDriver:TComponent;
    FSleepInterruptable:TCrossEvent;
    FEnd:TCrossEvent;
    TagCBack:TTagCommandCallBack;
    FTagRec:PTagRec;
    Fvalues:TScanReadRec;
    FCmd:TTagCommand;
    PGetValues:TGetValues;
    PScanTags:TGetMultipleValues;
    FSpool:TMessageSpool;
    PScannedValues:TArrayOfScanUpdateRec;
    procedure SyncCallBack;
    procedure SyncException;
    procedure UpdateMultipleTags;
    procedure CheckScanReadOrWrite;
    function  WaitEnd(timeout:Cardinal):TWaitResult;
  protected
    //: @exclude
    procedure Execute; override;
  public
    //: @exclude
    constructor Create(StartSuspended:Boolean; OwnerProtocol:TComponent; usrUpdTime:TUserUpdateTimeProc);
    //: @exclude
    destructor Destroy; override;

    {$IFDEF PORTUGUES}
    //: Sinaliza para thread Terminar.
    {$ELSE}
    //: Requests the thread finalization.
    {$ENDIF}
    procedure Terminate;

    {$IFDEF PORTUGUES}
    {:
    Faz a atualização de um tag que solicitou uma LEITURA por scan.

    @param(Tag TTagRec. Estrutura com as informações do tag.)
    @raises(Exception caso a thread esteja suspensa ou não sinalize a sua
            inicialização em 5 segundos.)
    }
    {$ELSE}
    {:
    Updates the tag that requested a scan read.

    @param(Tag TTagRec. Structure with informations about the tag.)
    @raises(Exception if the thread was not initialized.)
    }
    {$ENDIF}
    procedure ScanRead(Tag:TTagRec);

    {$IFDEF PORTUGUES}
    {:
    Faz a atualização de um tag que solicitou uma ESCRITA por scan.

    @param(SWPkg PScanWriteRec. Ponteiro para estrutura com as informações
           da escrita por scan do tag.)
    @raises(Exception caso a thread esteja suspensa ou não sinalize a sua
            inicialização em 5 segundos.)
    }
    {$ELSE}
    {:
    Updates the the tag that requested a scan write.

    @param(SWPkg PScanWriteRec. Points to a structure with informations about
           the scan write and Tag.)
    @raises(Exception if the thread was not initialized.)
    }
    {$ENDIF}
    procedure ScanWriteCallBack(SWPkg:PScanWriteRec);
  published

    {$IFDEF PORTUGUES}
    //: Evento chamado pela thread para pegar e atualizar um tag.
    {$ELSE}
    //: Event called by thread to get values and update a tag.
    {$ENDIF}
    property OnGetValue:TGetValues read PGetValues write PGetValues;

    {$IFDEF PORTUGUES}
    //: função que retorna o tempo do proximo scan ou a lista de tags que estão na vez de serem lidos.
    {$ELSE}
    //: Returns the lists of tags to be updated or the next time to check has tags to be updated.
    {$ENDIF}
    property OnScanTags:TGetMultipleValues read PScanTags write PScanTags;
  end;

implementation

uses {$IFDEF FDEBUG}LCLProc,{$ENDIF} ProtocolDriver, hsstrings, crossdatetime,
  dateutils;

////////////////////////////////////////////////////////////////////////////////
//                   inicio das declarações da TScanUpdate
//                    implementation of TScanUpdate class
////////////////////////////////////////////////////////////////////////////////
constructor TScanUpdate.Create(StartSuspended:Boolean; OwnerProtocol:TComponent; usrUpdTime:TUserUpdateTimeProc);
begin
  inherited Create(StartSuspended);
  if not (OwnerProtocol is TProtocolDriver) then
    raise Exception.Create(STheOwnerMustBeAProtocolDriver);

  FOwnerProtocolDriver:=OwnerProtocol;
  Priority := tpHighest;
  FUserUpdateTimePRoc:=usrUpdTime;
  FSpool := TMessageSpool.Create;
  FEnd := TCrossEvent.Create(true, false);
  FEnd.ResetEvent;
  FSleepInterruptable := TCrossEvent.Create(false, false);
end;

destructor TScanUpdate.Destroy;
begin
  inherited Destroy;
  FSleepInterruptable.SetEvent;
  FSleepInterruptable.Destroy;
  FSpool.Destroy;
  FEnd.Destroy;
end;

procedure TScanUpdate.Terminate;
begin
  TCrossThread(self).Terminate;
  FSleepInterruptable.SetEvent;
  repeat
     CheckSynchronize(1);
  until WaitEnd(1)=wrSignaled;
end;

function  TScanUpdate.WaitEnd(timeout:Cardinal):TWaitResult;
begin
   Result := FEnd.WaitFor(timeout);
end;

procedure TScanUpdate.Execute;
var
  timeout:LongInt;
  FInicio:TDateTime;
  FTempo, FVezes, FValor:LongInt;
  FMedia:Double;
begin
  FTempo:=0;
  FVezes:=0;
  while not Terminated do begin
    try
      CheckScanReadOrWrite;
      if Assigned(PScanTags) then begin
        SetLength(PScannedValues,0);
        timeout:=PScanTags(PScannedValues);
        if Length(PScannedValues)>0 then begin
          FInicio:=CrossNow;
          Synchronize(@UpdateMultipleTags);
          FValor:=MilliSecondsBetween(CrossNow,FInicio);

          FTempo:=FTempo+FValor;
          FVezes:=FVezes+1;
          timeout:=timeout-FValor;

          FMedia:=FTempo div FVezes;
          if Assigned(FUserUpdateTimePRoc) then
            FUserUpdateTimePRoc(FMedia);
        end;
      end else
        timeout:=1;

      if (timeout)>0 then
        FSleepInterruptable.WaitFor(timeout)
      else
        FSleepInterruptable.WaitFor(1);
    except
    //  on E: Exception do begin
    //    {$IFDEF FDEBUG}
    //    DebugLn('TScanUpdate.Execute:: ' + e.Message);
    //    DumpStack;
    //    {$ENDIF}
    //    Ferro := E;
    //    Synchronize(@SyncException);
    //  end;
    end;
  end;
  FEnd.SetEvent;
end;

procedure TScanUpdate.ScanRead(Tag:TTagRec);
var
  tagpkg:PTagRec;
begin
  New(tagpkg);
  Move(tag,tagpkg^,sizeof(TTagRec));
  FSpool.PostMessage(PSM_TAGSCANREAD,tagpkg,nil,false);
  FSleepInterruptable.SetEvent;
end;

procedure TScanUpdate.ScanWriteCallBack(SWPkg:PScanWriteRec);
begin
   FSpool.PostMessage(PSM_TAGSCANWRITE,SWPkg,nil,true);
   FSleepInterruptable.SetEvent;
end;

procedure TScanUpdate.SyncException;
begin
  //try
  //  Application.ShowException(Ferro);
  //except
  //end;
end;

procedure TScanUpdate.UpdateMultipleTags;
var
  c:LongInt;
  found:Boolean;
begin
  for c:=0 to High(PScannedValues) do begin
    found:=false;
    if TProtocolDriver(FOwnerProtocolDriver).IsMyTag(TTag(TMethod(PScannedValues[c].CallBack).Data)) and ((TTag(TMethod(PScannedValues[c].CallBack).Data).ComponentState*[csDestroying])=[]) then begin
      found:=true;
    end;
    if not found then continue;
    with PScannedValues[c] do
      try
        CallBack(Values, ValueTimeStamp, tcScanRead, LastResult, 0);
        SetLength(Values,0);
      finally
      end;
  end;
  SetLength(PScannedValues,0);
end;

procedure TScanUpdate.CheckScanReadOrWrite;
var
  x:PScanWriteRec;
  PMsg:TMSMsg;
begin
  while (not Terminated) and FSpool.PeekMessage(PMsg,PSM_TAGSCANREAD,PSM_TAGSCANWRITE,true) do begin
    //try
      case PMsg.MsgID of
        PSM_TAGSCANWRITE: begin
          x := PScanWriteRec(PMsg.wParam);

          TagCBack                := x^.Tag.CallBack;
          Fvalues.Values          := x^.ValuesToWrite;
          Fvalues.Offset          := x^.Tag.OffSet;
          Fvalues.RealOffset      := x^.Tag.RealOffset;
          Fvalues.ValuesTimestamp := x^.ValueTimeStamp;
          Fvalues.LastQueryResult := x^.WriteResult;
          FCmd:=tcScanWrite;

          //sincroniza com o tag.
          //sync tag (update it)
          Synchronize(@SyncCallBack);

          //libera a memoria ocupada
          //pelo pacote
          //free the memory of the request
          SetLength(x^.ValuesToWrite,0);
          Dispose(x);
          TagCBack:=nil;
        end;
        PSM_TAGSCANREAD: begin
          FTagRec := PTagRec(PMsg.wParam);
          TagCBack:=FTagRec^.CallBack;
          Fvalues.Offset:=FTagRec^.OffSet;
          Fvalues.RealOffset:=FTagRec^.RealOffset;

          if Assigned(PGetValues) then begin
            PGetValues(FTagRec^, Fvalues)
          end else
            Fvalues.LastQueryResult := ioDriverError;

          FCmd:=tcScanRead;

          Synchronize(@SyncCallBack);

          //libera a memoria ocupada pelos pacotes
          //free the memory of the request
          SetLength(Fvalues.Values, 0);
          Dispose(FTagRec);
          TagCBack:=nil;
        end;
      end;
    //except
    //  on E: Exception do begin
    //    {$IFDEF FDEBUG}
    //    DebugLn('TScanUpdate.Execute:: ' + e.Message);
    //    DumpStack;
    //    {$ENDIF}
    //    Ferro := E;
    //    Synchronize(@SyncException);
    //  end;
    //end;
  end;
end;

procedure TScanUpdate.SyncCallBack;
begin
  if Terminated then exit;
  //try
    if Assigned(TagCBack) then
      TagCBack(Fvalues.Values,Fvalues.ValuesTimestamp,FCmd,Fvalues.LastQueryResult, Fvalues.RealOffset);
  //except
  //  on erro:Exception do begin
  //    Ferro:=erro;
  //    SyncException;
  //  end;
  //end;
end;

end.

