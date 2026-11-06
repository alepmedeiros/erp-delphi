unit LabeledDBCtrls;

{ Compatibilidade D13: substituto m�nimo dos controles LabeledDBCtrls legados. }

interface

uses
  Classes, Controls, StdCtrls, DBCtrls, LabeledCtrls;

type
  TLabeledDBLookupComboBox = class(TDBLookupComboBox)
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

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('T2Ti', [TLabeledDBLookupComboBox]);
end;

constructor TLabeledDBLookupComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEditLabel := TEditLabel.Create(Self);
  FEditLabel.SetSubComponent(True);
end;

procedure TLabeledDBLookupComboBox.Loaded;
begin
  inherited Loaded;
  SyncLabelPosition;
end;

procedure TLabeledDBLookupComboBox.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  SyncLabelPosition;
end;

procedure TLabeledDBLookupComboBox.SyncLabelPosition;
begin
  if (Parent <> nil) and (FEditLabel <> nil) then
  begin
    if FEditLabel.Parent <> Parent then
      FEditLabel.Parent := Parent;
    FEditLabel.Left := Left;
    if FEditLabel.Height <= 0 then
      FEditLabel.Height := 13;
    FEditLabel.Top := Top - FEditLabel.Height - 2;
  end;
end;

end.
