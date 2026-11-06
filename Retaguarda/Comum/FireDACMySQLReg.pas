unit FireDACMySQLReg;

{ Registra os drivers FireDAC usados pelo Dext na conexao (Camadas=2). }

interface

implementation

uses
  System.SysUtils,
  FireDAC.Phys.MySQL,
  FireDAC.Phys.PG;

const
  { DLLs ficam em ...\lib\; o driver PG acrescenta "lib\" ao VendorHome. }
  PG_LIB_FALLBACK = 'C:\repositorio\Exemplos_ERP-PDV\lib\';

var
  FDPhysMySQLDriverLink: TFDPhysMySQLDriverLink;
  FDPhysPgDriverLink: TFDPhysPgDriverLink;

function ResolvePgVendorHome(const AExeDir: string): string;
var
  FallbackHome: string;
begin
  { FireDAC PG: VendorHome + 'lib\' + VendorLib (nao incluir 'lib\' no VendorHome). }
  Result := '';
  if FileExists(AExeDir + 'lib\libpq.dll') then
    Exit(AExeDir);

  if not FileExists(PG_LIB_FALLBACK + 'libpq.dll') then
    Exit;

  FallbackHome := IncludeTrailingPathDelimiter(
    ExtractFilePath(ExcludeTrailingPathDelimiter(PG_LIB_FALLBACK)));
  if FileExists(FallbackHome + 'lib\libpq.dll') then
    Result := FallbackHome;
end;

procedure ConfigurePgVendorLib;
var
  ExeDir, VendorHome: string;
begin
  ExeDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  FDPhysPgDriverLink.VendorLib := 'libpq.dll';
  VendorHome := ResolvePgVendorHome(ExeDir);
  if VendorHome = '' then
    Exit;

  FDPhysPgDriverLink.VendorHome := VendorHome;
end;

initialization
  FDPhysMySQLDriverLink := TFDPhysMySQLDriverLink.Create(nil);
  FDPhysPgDriverLink := TFDPhysPgDriverLink.Create(nil);
  ConfigurePgVendorLib;

finalization
  FreeAndNil(FDPhysPgDriverLink);
  FreeAndNil(FDPhysMySQLDriverLink);

end.
