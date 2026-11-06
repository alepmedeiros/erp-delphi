unit LabeledCtrls;

{ Compatibilidade D13: substituto m�nimo dos controles LabeledCtrls legados (Rx/terceiros). }

interface

uses
  Classes, SysUtils, Controls, StdCtrls, Mask, Vcl.ComCtrls;

type
  TEditLabel = class(TLabel)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TLabeledEdit = class(TEdit)
  private
    FEditLabel: TEditLabel;
    procedure SyncLabelPosition;
  protected
    procedure Loaded; override;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property EditLabel: TEditLabel read FEditLabel;
  end;

  TLabeledMaskEdit = class(TMaskEdit)
  private
    FEditLabel: TEditLabel;
    FRequired: Boolean;
    procedure SyncLabelPosition;
  protected
    procedure Loaded; override;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property EditLabel: TEditLabel read FEditLabel;
    property Required: Boolean read FRequired write FRequired default False;
  end;

  TLabeledCalcEdit = class(TEdit)
  private
    FEditLabel: TEditLabel;
    function GetValue: Currency;
    procedure SetValue(const AValue: Currency);
    function GetAsInteger: Integer;
    procedure SetAsInteger(const AValue: Integer);
    procedure SyncLabelPosition;
  protected
    procedure Loaded; override;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property EditLabel: TEditLabel read FEditLabel;
    property CalcEditLabel: TEditLabel read FEditLabel;
    property Value: Currency read GetValue write SetValue;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
  end;

  TLabeledComboBox = class(TComboBox)
  private
    FEditLabel: TEditLabel;
    procedure SyncLabelPosition;
  protected
    procedure Loaded; override;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property EditLabel: TEditLabel read FEditLabel;
  end;

  TLabeledMemo = class(TMemo)
  private
    FEditLabel: TEditLabel;
    procedure SyncLabelPosition;
  protected
    procedure Loaded; override;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property EditLabel: TEditLabel read FEditLabel;
  end;

  TLabeledDateEdit = class(TDateTimePicker)
  private
    FEditLabel: TEditLabel;
    procedure SyncLabelPosition;
  protected
    procedure Loaded; override;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Clear;
  published
    property EditLabel: TEditLabel read FEditLabel;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('T2Ti', [
    TEditLabel, TLabeledEdit, TLabeledMaskEdit, TLabeledCalcEdit,
    TLabeledComboBox, TLabeledMemo, TLabeledDateEdit]);
end;

{ TEditLabel }

constructor TEditLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AutoSize := True;
end;

{ helpers }

procedure SyncLabeledLabel(AControl: TWinControl; ALabel: TEditLabel);
begin
  if (AControl = nil) or (ALabel = nil) or (AControl.Parent = nil) then
    Exit;
  if ALabel.Parent <> AControl.Parent then
    ALabel.Parent := AControl.Parent;
  ALabel.Left := AControl.Left;
  if ALabel.Height <= 0 then
    ALabel.Height := 13;
  ALabel.Top := AControl.Top - ALabel.Height - 2;
end;

{ TLabeledEdit }

constructor TLabeledEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEditLabel := TEditLabel.Create(Self);
  FEditLabel.SetSubComponent(True);
end;

procedure TLabeledEdit.Loaded;
begin
  inherited Loaded;
  SyncLabelPosition;
end;

procedure TLabeledEdit.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  SyncLabelPosition;
end;

procedure TLabeledEdit.SyncLabelPosition;
begin
  SyncLabeledLabel(Self, FEditLabel);
end;

{ TLabeledMaskEdit }

constructor TLabeledMaskEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEditLabel := TEditLabel.Create(Self);
  FEditLabel.SetSubComponent(True);
end;

procedure TLabeledMaskEdit.Loaded;
begin
  inherited Loaded;
  SyncLabelPosition;
end;

procedure TLabeledMaskEdit.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  SyncLabelPosition;
end;

procedure TLabeledMaskEdit.SyncLabelPosition;
begin
  SyncLabeledLabel(Self, FEditLabel);
end;

{ TLabeledCalcEdit }

constructor TLabeledCalcEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEditLabel := TEditLabel.Create(Self);
  FEditLabel.SetSubComponent(True);
end;

function TLabeledCalcEdit.GetValue: Currency;
begin
  Result := StrToCurrDef(StringReplace(Text, '.', '', [rfReplaceAll]), 0);
end;

procedure TLabeledCalcEdit.SetValue(const AValue: Currency);
begin
  Text := CurrToStrF(AValue, ffFixed, 2);
end;

function TLabeledCalcEdit.GetAsInteger: Integer;
begin
  Result := StrToIntDef(StringReplace(Text, '.', '', [rfReplaceAll]), 0);
end;

procedure TLabeledCalcEdit.SetAsInteger(const AValue: Integer);
begin
  Text := IntToStr(AValue);
end;

procedure TLabeledCalcEdit.Loaded;
begin
  inherited Loaded;
  SyncLabelPosition;
end;

procedure TLabeledCalcEdit.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  SyncLabelPosition;
end;

procedure TLabeledCalcEdit.SyncLabelPosition;
begin
  SyncLabeledLabel(Self, FEditLabel);
end;

{ TLabeledComboBox }

constructor TLabeledComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEditLabel := TEditLabel.Create(Self);
  FEditLabel.SetSubComponent(True);
end;

procedure TLabeledComboBox.Loaded;
begin
  inherited Loaded;
  SyncLabelPosition;
end;

procedure TLabeledComboBox.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  SyncLabelPosition;
end;

procedure TLabeledComboBox.SyncLabelPosition;
begin
  SyncLabeledLabel(Self, FEditLabel);
end;

{ TLabeledMemo }

constructor TLabeledMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEditLabel := TEditLabel.Create(Self);
  FEditLabel.SetSubComponent(True);
end;

procedure TLabeledMemo.Loaded;
begin
  inherited Loaded;
  SyncLabelPosition;
end;

procedure TLabeledMemo.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  SyncLabelPosition;
end;

procedure TLabeledMemo.SyncLabelPosition;
begin
  SyncLabeledLabel(Self, FEditLabel);
end;

{ TLabeledDateEdit }

constructor TLabeledDateEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEditLabel := TEditLabel.Create(Self);
  FEditLabel.SetSubComponent(True);
end;

procedure TLabeledDateEdit.Clear;
begin
  Checked := False;
end;

procedure TLabeledDateEdit.Loaded;
begin
  inherited Loaded;
  SyncLabelPosition;
end;

procedure TLabeledDateEdit.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  SyncLabelPosition;
end;

procedure TLabeledDateEdit.SyncLabelPosition;
begin
  SyncLabeledLabel(Self, FEditLabel);
end;

end.
