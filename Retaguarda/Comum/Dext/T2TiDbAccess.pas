unit T2TiDbAccess;

interface

uses
  System.SysUtils, System.Rtti, System.Variants,
  Dext.Entity.Drivers.Interfaces;

function T2TiExecuteSQL(const AConnection: IDbConnection; const ASQL: string): Boolean;
function T2TiExecuteScalarInt(const AConnection: IDbConnection; const ASQL: string): Integer;
function T2TiOpenQuery(const AConnection: IDbConnection; const ASQL: string): IDbReader;

implementation

function T2TiExecuteSQL(const AConnection: IDbConnection; const ASQL: string): Boolean;
var
  Cmd: IDbCommand;
begin
  Cmd := AConnection.CreateCommand(ASQL);
  Cmd.ExecuteNonQuery;
  Result := True;
end;

function T2TiExecuteScalarInt(const AConnection: IDbConnection; const ASQL: string): Integer;
var
  Cmd: IDbCommand;
  V: TValue;
begin
  Result := 0;
  Cmd := AConnection.CreateCommand(ASQL);
  V := Cmd.ExecuteScalar;
  if not V.IsEmpty then
  begin
    if V.IsOrdinal then
      Result := V.AsInteger
    else
      Result := StrToIntDef(V.ToString, 0);
  end;
end;

function T2TiOpenQuery(const AConnection: IDbConnection; const ASQL: string): IDbReader;
var
  Cmd: IDbCommand;
begin
  Cmd := AConnection.CreateCommand(ASQL);
  Result := Cmd.ExecuteQuery;
end;

end.
