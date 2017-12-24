{**********************************************************************
 Package pl_ExControls.pkg
 From PilotLogic Software House(http://www.pilotlogic.com/)
 This unit is part of CodeTyphon Studio
***********************************************************************}

unit TplComboBoxPenStyleUnit;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, Messages, LMessages,
  Classes, Forms, Controls, Graphics, StdCtrls, plUtils,
  SysUtils, comctrls ,dialogs, TplComboBoxUnit;

type

TplPenStyleComboBox = class(TplCustomComboBox)
  private
   FDrawLabel: TDrawItemLabelEvent;
  protected
   procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
   procedure CreateWnd; override;
   function  GetSelection: TPenStyle;
   procedure SetSelection(Value: TPenStyle);
  public
   constructor Create(AOwner: TComponent); override;
   destructor Destroy; override;
  published
   property Selection: TPenStyle read GetSelection write SetSelection default psSolid;
   property OnDrawItemLabel: TDrawItemLabelEvent read FDrawLabel write FDrawLabel;

  end;

implementation   

//======================== TplPenStyleComboBox =============================
const PenStyleArray: array[0..6] of string = ('Clear', 'Dash', 'Dash-Dot', 'Dash-Dot-Dot', 'Dot', 'Inside Frame', 'Solid');

constructor TplPenStyleComboBox.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 //ParentColor := false;
 //DoubleBuffered := true;
 Style := csOwnerDrawFixed;
end;

destructor TplPenStyleComboBox.Destroy;
begin
 inherited Destroy;
end;

function TplPenStyleComboBox.GetSelection: TPenStyle;
begin
 Result := psSolid;

 if (csDesigning in ComponentState) then Exit;  // ct9999

 if Items.Strings[ItemIndex] = 'Solid' then
  Result := psSolid
 else
  if Items.Strings[ItemIndex] = 'Dash' then
   Result := psDash
  else
   if Items.Strings[ItemIndex] = 'Dash-Dot' then
    Result := psDashDot
   else
    if Items.Strings[ItemIndex] = 'Dash-Dot-Dot' then
     Result := psDashDotDot
    else
     if Items.Strings[ItemIndex] = 'Dot' then
      Result := psDot
     else
      if Items.Strings[ItemIndex] = 'Inside Frame' then
       Result := psInsideFrame
      else
       if Items.Strings[ItemIndex] = 'Clear' then
        Result := psClear;
end;

procedure TplPenStyleComboBox.SetSelection(Value: TPenStyle);
begin
 case Value of
  psClear: ItemIndex := 0;
  psDash: ItemIndex := 1;
  psDashDot: ItemIndex := 2;
  psDashDotDot: ItemIndex := 3;
  psDot: ItemIndex := 4;
  psInsideFrame: ItemIndex := 5;
  psSolid: ItemIndex := 6;
 end;
end;

procedure TplPenStyleComboBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
 R, IR: TRect;
 y: integer;
 tc: TColor;
begin
 Canvas.Font := Font;
 if odSelected in State then
  begin
   Canvas.Brush.Color := clHighlight;
   Canvas.Pen.Color := clHighlightText;
   Canvas.Font.Color := clHighlightText;
  end
 else
  begin
   Canvas.Brush.Color := Color;
   Canvas.Pen.Color := clWindowText;
   Canvas.Font.Color := clWindowText;
  end;
 tc := Canvas.Font.Color;
 if Assigned(FDrawLabel) then FDrawLabel(Self, Index, Canvas.Font, State);
 if Canvas.Font.Color <> tc then
  Canvas.Pen.Color := Canvas.Font.Color;
 Canvas.FillRect(Rect);
 // set icon rect
 R := Rect;
 Inc(R.Left, 1);
 Inc(R.Top, 1);
 Dec(R.Bottom, 1);
 R.Right := R.Left + 2*(R.Bottom - R.Top);
 // draw icon
 Canvas.Pen.Style := psSolid;
 Canvas.Rectangle(R);
 y := R.Top + (R.Bottom - R.Top) div 2;
 Canvas.MoveTo(R.Left, y);
 case Index of
  0: Canvas.Pen.Style := psClear;
  1: Canvas.Pen.Style := psDash;
  2: Canvas.Pen.Style := psDashDot;
  3: Canvas.Pen.Style := psDashDotDot;
  4: Canvas.Pen.Style := psDot;
  5: Canvas.Pen.Style := psInsideFrame;
  6: Canvas.Pen.Style := psSolid;
 end;
 Canvas.LineTo(R.Right, y);
 // draw text
 Canvas.Brush.Style := bsClear;
 IR := Rect;
 IR.Left := R.Right + 4;
 DrawText(Canvas.Handle, PChar(Items.Strings[index]), Length(Items.Strings[index]), IR, DT_VCENTER or DT_SINGLELINE);
 if Assigned(OnDrawItem) then
  OnDrawItem(Self, Index, Rect, State);
end;

procedure TplPenStyleComboBox.CreateWnd;
var
 c: integer;
begin
 inherited CreateWnd;
 Items.Clear;
 for c := 0 to High(PenStyleArray) do
  Items.Add(PenStyleArray[c]);
 SetSelection(psSolid);
end;

end.

