unit JSonVO;

interface

uses
  System.JSON, REST.Json, RTTI, TypInfo, Atributos, SysUtils,
  IOUtils, Generics.Collections, Classes, VO;

type
  TJSonVO = class
  public
    constructor Create; overload; virtual;

    class function ObjectToJSON<O: class>(objeto: O): TJSONValue;
    class function JSONToObject<O: class, constructor>(pObjetoJson: TJSONValue): O;
    class function SaveFileJSON<O: class>(pObj: O; const pFilePath: string): Boolean;
    class function LoadFileJSON<O: class, constructor>(const pFilePath: string): O;
  end;

implementation

constructor TJSonVO.Create;
begin
  inherited Create;
end;

class function TJSonVO.JSONToObject<O>(pObjetoJson: TJSONValue): O;
begin
  if (pObjetoJson = nil) or (pObjetoJson is TJSONNull) then
    Exit(nil);

  Result := TJson.JsonToObject<O>(pObjetoJson.ToJSON);
end;

class function TJSonVO.ObjectToJSON<O>(objeto: O): TJSONValue;
begin
  if Assigned(objeto) then
    Result := TJson.ObjectToJsonObject(objeto)
  else
    Result := TJSONNull.Create;
end;

class function TJSonVO.SaveFileJSON<O>(pObj: O; const pFilePath: string): Boolean;
var
  JsonText: string;
begin
  FormatSettings.DecimalSeparator := '.';
  try
    JsonText := TJson.ObjectToJsonString(pObj);
    TFile.WriteAllText(pFilePath, JsonText);
    Result := True;
  except
    Result := False;
    raise;
  end;
  FormatSettings.DecimalSeparator := ',';
end;

class function TJSonVO.LoadFileJSON<O>(const pFilePath: string): O;
begin
  if not FileExists(pFilePath) then
    Exit(nil);

  try
    Result := TJson.JsonToObject<O>(TFile.ReadAllText(pFilePath));
  except
    Result := nil;
  end;
end;

end.
