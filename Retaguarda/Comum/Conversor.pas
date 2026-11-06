unit Conversor;

interface

uses Classes, System.JSON, SysUtils;

type
  TConversor = class
  private
    class function ExtractValueFromJSONObjectStream(pStream: TStringStream): string;
    class function ExtractValueFromJSONPairStr(pStr: string): string;
  public
    class function JSONObjectStreamToBoolean(pStream: TStringStream): Boolean;
    class function JSONObjectStreamToInteger(pStream: TStringStream): Integer;
    class function JSONPairStrToBoolean(pStr: string): Boolean;
    class function JSONArrayStreamToJSONArray(pStream: TStringStream): TJSONArray;
    class function ListJSONArrayStreamToJSONArray(pStream: TStringStream; pIdx: Integer): TJSONArray;
  end;

implementation

class function TConversor.ExtractValueFromJSONObjectStream(pStream: TStringStream): string;
var
  JVal: TJSONValue;
  JObj: TJSONObject;
begin
  Result := '';
  JVal := TJSONObject.ParseJSONValue(pStream.DataString);
  try
    if JVal is TJSONObject then
    begin
      JObj := TJSONObject(JVal);
      if JObj.Count > 0 then
        Result := JObj.Pairs[0].JsonValue.Value;
    end;
  finally
    JVal.Free;
  end;

  if (Length(Result) >= 2) and (Result[1] = '"') then
    Result := Copy(Result, 2, Length(Result) - 2);
end;

class function TConversor.ExtractValueFromJSONPairStr(pStr: string): string;
var
  I: Integer;
  Valor: string;
begin
  Valor := pStr;

  I := Pos('[',Valor);
  Delete(Valor,1,I);

  I := Pos(']',Valor);
  Result := Copy(Valor,1,I-1);
end;

class function TConversor.JSONObjectStreamToBoolean(pStream: TStringStream): Boolean;
begin
  Result := StrToBoolDef(ExtractValueFromJSONObjectStream(pStream),False);
end;

class function TConversor.JSONObjectStreamToInteger(
  pStream: TStringStream): Integer;
begin
  Result := StrToIntDef(ExtractValueFromJSONObjectStream(pStream),-1);
end;

class function TConversor.JSONPairStrToBoolean(pStr: string): Boolean;
begin
  Result := StrToBoolDef(ExtractValueFromJSONPairStr(pStr),False);
end;

class function TConversor.JSONArrayStreamToJSONArray(pStream: TStringStream): TJSONArray;
var
  JVal: TJSONValue;
  JObj: TJSONObject;
  Inner: TJSONValue;
begin
  Result := nil;
  JVal := TJSONObject.ParseJSONValue(pStream.DataString);
  try
    if not (JVal is TJSONObject) then
      Exit;

    JObj := TJSONObject(JVal);
    if JObj.Count = 0 then
      Exit;

    Inner := JObj.Pairs[0].JsonValue;
    if Inner is TJSONArray then
    begin
      if TJSONArray(Inner).Count > 0 then
        Result := (TJSONArray(Inner).Items[0] as TJSONArray).Clone as TJSONArray;
    end;
  finally
    JVal.Free;
  end;
end;

class function TConversor.ListJSONArrayStreamToJSONArray(pStream: TStringStream; pIdx: Integer): TJSONArray;
var
  A: TJSONArray;
begin
  A := JSONArrayStreamToJSONArray(pStream);
  try
    Result := A.Get(pIdx).Clone as TJSONArray;
  finally
    A.Free;
  end;
end;

end.
