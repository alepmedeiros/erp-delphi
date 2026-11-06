unit UDataModuleConexao;

interface

uses
  System.SysUtils, System.Classes,
  Dext.Entity.Drivers.Interfaces,
  Dext.Entity.Setup,
  T2TiDbContext;

type
  TFDataModuleConexao = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    FBanco: string;
    FContext: TT2TiDbContext;
    FOptions: TDbContextOptions;
    function ConnectionStringFromIni(const AFile, ABD: string): string;
  public
    procedure Conectar(BD: string);
    procedure Desconectar;
    function GetDbConnection: IDbConnection;
    function GetContext: TT2TiDbContext;
    function getBanco: string;
    /// Legado � retorna interface Dext (substitui TSQLConnection).
    function getConexao: IDbConnection;
  end;

var
  FDataModuleConexao: TFDataModuleConexao;

implementation

uses
  Constantes, Biblioteca;

{$R *.dfm}

procedure TFDataModuleConexao.DataModuleCreate(Sender: TObject);
begin
  Conectar('Postgres');
end;

function TFDataModuleConexao.ConnectionStringFromIni(const AFile, ABD: string): string;
var
  SL: TStringList;
  Host, DB, User, Pass, Porta, DriverId: string;
begin
  SL := TStringList.Create;
  try
    SL.LoadFromFile(AFile);
    Host := SL.Values['HostName'];
    if Host = '' then
      Host := 'localhost';
    DB := SL.Values['Database'];
    User := SL.Values['User_Name'];
    Pass := SL.Values['Password'];
    Porta := SL.Values['Port'];
    if Porta = '' then
      Porta := '5432';

    if SameText(ABD, 'Postgres') or SameText(ABD, 'PostgreSQL') then
    begin
      DriverId := 'PG';
      Result := Format('DriverID=%s;Server=%s;Port=%s;Database=%s;User_Name=%s;Password=%s',
        [DriverId, Host, Porta, DB, User, Pass]);
    end
    else
    begin
      DriverId := 'MySQL';
      Result := Format('DriverID=%s;Server=%s;Database=%s;User_Name=%s;Password=%s',
        [DriverId, Host, DB, User, Pass]);
    end;
  finally
    SL.Free;
  end;
end;

procedure TFDataModuleConexao.Conectar(BD: string);
var
  Arquivo: string;
begin
  Desconectar;

  if SameText(BD, 'MySQL') then
    Arquivo := gsAppPath + 'MySQL_DBExpress_conn.txt'
  else if SameText(BD, 'Firebird') then
    Arquivo := gsAppPath + 'Firebird_DBExpress_conn.txt'
  else if SameText(BD, 'Postgres') or SameText(BD, 'PostgreSQL') then
  begin
    Arquivo := gsAppPath + 'Postgres_DBExpress_conn.txt';
    if not FileExists(Arquivo) then
      Arquivo := gsAppPath + 'PostgreSQL_DBExpress_conn.txt';
  end
  else
    raise Exception.Create('Banco nao suportado: ' + BD);

  if not FileExists(Arquivo) then
    raise Exception.Create('Arquivo de conexao nao encontrado: ' + Arquivo);

  FOptions := TDbContextOptions.Create;
  FOptions.ConnectionString := ConnectionStringFromIni(Arquivo, BD);
  FContext := TT2TiDbContext.Create(FOptions);
  FContext.Connection.Connect;
  FBanco := BD;
end;

procedure TFDataModuleConexao.Desconectar;
begin
  FreeAndNil(FContext);
  FreeAndNil(FOptions);
end;

function TFDataModuleConexao.GetDbConnection: IDbConnection;
begin
  if FContext = nil then
    raise Exception.Create('Contexto Dext nao inicializado.');
  Result := FContext.Connection;
end;

function TFDataModuleConexao.GetContext: TT2TiDbContext;
begin
  if FContext = nil then
    raise Exception.Create('Contexto Dext nao inicializado.');
  Result := FContext;
end;

function TFDataModuleConexao.getBanco: string;
begin
  Result := FBanco;
end;

function TFDataModuleConexao.getConexao: IDbConnection;
begin
  Result := GetDbConnection;
end;

end.
