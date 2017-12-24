unit DropDownButton;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DropDownManager, DropDownBaseButtons, Controls, LCLType, Buttons, Forms,
  Graphics;

type

  TDropDownButton = class;

  { TOwnedDropDownManager }

  TOwnedDropDownManager = class(TCustomDropDownManager)
  private
    FButton: TDropDownButton;
  protected
    procedure DoHide; override;
    procedure DoInitialize(Data: PtrInt); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Control;
    property Options;
    property OnCreateControl;
    property OnHide;
    property OnShow;
  end;

  { TDropDownButton }

  TDropDownButton = class(TCustomDropDownButton)
  private
    FDropDown: TOwnedDropDownManager;
    procedure SetDropDown(AValue: TOwnedDropDownManager);
  protected
    procedure DoShowDropDown; override;
    procedure DoHideDropDown; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property DropDown: TOwnedDropDownManager read FDropDown write SetDropDown;
    property Options;
    property Style;
    //
    property Action;
    property Align;
    property Anchors;
    property AutoSize;
    property BorderSpacing;
    property Constraints;
    property Caption;
    property Color;
    property Enabled;
    property Flat;
    property Font;
    property Glyph;
    property Layout;
    property Margin;
    property NumGlyphs;
    property Spacing;
    property Transparent;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnPaint;
    property OnResize;
    property OnChangeBounds;
    property ShowCaption;
    property ShowHint;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
  end;

implementation

type
  TToggleSpeedButtonAccess = class(TToggleSpeedButton)

  end;

{ TOwnedDropDownManager }

procedure TOwnedDropDownManager.DoHide;
begin
  TToggleSpeedButtonAccess(FButton).UpdateDown(False);
  FButton.DropDownClosed;
  inherited DoHide;
end;

procedure TOwnedDropDownManager.DoInitialize(Data: PtrInt);
begin
  TToggleSpeedButtonAccess(FButton).UpdateDown(Visible);
  inherited DoInitialize(Data);
end;

constructor TOwnedDropDownManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetSubComponent(True);
  Name := 'OwnedDropDown';
  FButton := AOwner as TDropDownButton;
  MasterControl := FButton;
end;

{ TDropDownButton }

procedure TDropDownButton.SetDropDown(AValue: TOwnedDropDownManager);
begin
  FDropDown.Assign(AValue);
end;

procedure TDropDownButton.DoShowDropDown;
begin
  FDropDown.Visible := True;
end;

procedure TDropDownButton.DoHideDropDown;
begin
  FDropDown.Visible := False;
end;

constructor TDropDownButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDropDown := TOwnedDropDownManager.Create(Self);
  //necessary to the button toggle
  AllowAllUp := True;
  GroupIndex := 1;
end;

end.

