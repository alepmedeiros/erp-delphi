{ *******************************************************************************
Title: T2Ti ERP
Description: Framework ORM da T2Ti

The MIT License

Copyright: Copyright (C) 2014 T2Ti.COM

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

The author may be contacted at:
t2ti.com@gmail.com</p>

@author Albert Eije (T2Ti.COM)
@version 2.0
******************************************************************************* }
unit T2TiORM;

interface

uses Atributos, Rtti, SysUtils, TypInfo, VO, Classes,
    Generics.Collections, UDataModuleConexao, T2TiDbAccess,
    Dext.Entity.Drivers.Interfaces;

type
  TT2TiORM = class
  private
    class function FormatarFiltro(pFiltro: String): String;
    class function ValorPropriedadeObjeto(pObjeto: TObject; pCampo: String): Variant;
  public
    class function Inserir(pObjeto: TObject): Integer;
    class function Alterar(pObjeto: TObject): Boolean; overload;
    class function Alterar(pObjeto, pObjetoOld: TObject): Boolean; overload;
    class function Excluir(pObjeto: TObject): Boolean;
    class function Consultar<T: class>(pFiltro: String; pPagina: String = '0'; pConsultaCompleta: Boolean = False): TObjectList<T>; overload;
    class function Consultar(pObjeto: TObject; pFiltro: String; pPagina: String): IDbReader; overload;
    class function Consultar(pConsulta: String; pFiltro: String; pPagina: String): IDbReader; overload;
    class function ConsultarUmObjeto<T: class>(pFiltro: String; pConsultaCompleta: Boolean): T;

    class procedure PopularObjetosRelacionados(pObjeto: TVO);

    class function ComandoSQL(pConsulta: String): Boolean;
    class function SelectMax(pTabela: String; pFiltro: String): Integer;
    class function SelectMin(pTabela: String; pFiltro: String): Integer;
    class function SelectCount(pTabela: String): Integer;
  end;

var
  ConsultaCompleta: Boolean;

implementation

uses
  Constantes;

{ TT2TiORM }

{$Region 'Infra'}
class function TT2TiORM.FormatarFiltro(pFiltro: String): String;
begin
  Result := pFiltro;
  Result := StringReplace(Result, '*', '%', [rfReplaceAll]);
  Result := StringReplace(Result, '|', '/', [rfReplaceAll]);
  Result := StringReplace(Result, '\"', '"', [rfReplaceAll]);
end;

class function TT2TiORM.ValorPropriedadeObjeto(pObjeto: TObject; pCampo: String): Variant;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Atributo: TCustomAttribute;
  Propriedade: TRttiProperty;
begin
  Result := 0;
  Contexto := TRttiContext.Create;
  try
    Tipo := Contexto.GetType(pObjeto.ClassType);

    for Propriedade in Tipo.GetProperties do
    begin
      for Atributo in Propriedade.GetAttributes do
      begin
        // se est? pesquisando pelo ID
        if Atributo is TId then
        begin
          if (Atributo as TId).NameField = pCampo then
          begin
            Result := Propriedade.GetValue(pObjeto).AsInteger;
          end;
        end;

        // se est? pesquisando por outro campo
        if Atributo is TColumn then
        begin
          if (Atributo as TColumn).Name = pCampo then
          begin
            if (Propriedade.PropertyType.TypeKind in [tkInteger, tkInt64]) then
              Result := Propriedade.GetValue(pObjeto).AsInteger
            else if (Propriedade.PropertyType.TypeKind in [tkString, tkUString]) then
              Result := Propriedade.GetValue(pObjeto).AsString;
          end;
        end;
      end;
    end;
  finally
    Contexto.Free;
  end;
end;

class procedure TT2TiORM.PopularObjetosRelacionados(pObjeto: TVO);
var
  i: Integer;
  DbReader: IDbReader;
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Atributo: TCustomAttribute;
  Propriedade: TRttiProperty;

  NomeTipoObjeto: String;
  NomeClasseObjeto: String;

  Lista: TObjectList<TVO>;
  ItemLista: TVO;

  ObjetoLocal: TVO;
  RttiInstanceType: TRttiInstanceType;
  ObjetoLocalRtti: TValue;
begin
  Contexto := TRttiContext.Create;
  try
    Tipo := Contexto.GetType(pObjeto.ClassType);

    // Percorre propriedades
    for Propriedade in Tipo.GetProperties do
    begin
      // Percorre atributos
      for Atributo in Propriedade.GetAttributes do
      begin

        // Verifica se o atributo ? um atributo de associa??o para muitos
        if Atributo is TManyValuedAssociation then
        begin
          // Se for uma consulta completa, carrega as listas
          if ConsultaCompleta then
          begin
            // Se a propriedade for uma classe
            if Propriedade.PropertyType.TypeKind = tkClass then
            begin
              NomeTipoObjeto := Propriedade.PropertyType.Name;
              if (Pos('TList', NomeTipoObjeto) > 0) or (Pos('TObjectList', NomeTipoObjeto) > 0) then
              begin
                // Captura o tipo de classe da lista (TList<Unit.TNomeClasse>)
                i := Pos('<', NomeTipoObjeto);
                NomeClasseObjeto := Copy(NomeTipoObjeto, i + 1, Length(NomeTipoObjeto) - 1 - i);

                try
                  // Cria objeto tempor?rio
                  RttiInstanceType := (Contexto.FindType(NomeClasseObjeto) as TRttiInstanceType);
                  ObjetoLocalRtti := RttiInstanceType.GetMethod('Create').Invoke(RttiInstanceType.MetaclassType,[]);
                  ObjetoLocal := TVO(ObjetoLocalRtti.AsObject);
                  if Assigned(ObjetoLocal) then
                  begin
                    Lista := TObjectList<TVO>(Propriedade.GetValue(pObjeto).AsObject);

                    // Se a lista tiver sido instanciada
                    if Assigned(Lista) then
                    begin
                      // Consulta a lista de objetos
                      DbReader := Consultar(ObjetoLocal, (Atributo as TManyValuedAssociation).ForeingColumn + ' = ' + QuotedStr( String( ValorPropriedadeObjeto(pObjeto, (Atributo as TManyValuedAssociation).LocalColumn))), '-1');
                      try
                        while DbReader.Next do
                        begin
                          // Cria nova inst?ncia do objeto tempor?rio
                          ObjetoLocalRtti := RttiInstanceType.GetMethod('Create').Invoke(RttiInstanceType.MetaclassType,[]);
                          ItemLista := TVO(ObjetoLocalRtti.AsObject);
                          // Popula Objeto
                          ItemLista := VOFromDbReader(TVO(ItemLista), DbReader);
                          // Inclui objeto na lista
                          Lista.Add(ItemLista);
                          // Continua populando as associa??es dentro do objeto at? que todos sejam populados recursivamente
                          PopularObjetosRelacionados(TVO(ItemLista));
                        end;
                      finally
                        DbReader.Close;
                        DbReader := nil;
                      end;
                    end;
                    // Destroi objeto tempor?rio
                    FreeAndNil(ObjetoLocal);
                  end;
                finally
                end;
              end;
            end;
          end;
        end

        // Verifica se o atributo ? um atributo de associa??o para uma classe
        else if Atributo is TAssociation then
        begin
          // Se a propriedade for uma classe
          if Propriedade.PropertyType.TypeKind = tkClass then
          begin
            // Captura o tipo de classe da lista (Unit.TNomeClasse)
            NomeClasseObjeto := Propriedade.PropertyType.QualifiedName;

            // Verifica se o objeto j? est? instanciado
            ObjetoLocal := Propriedade.GetValue(pObjeto).AsObject as TVO;

            // Se conseguiu capturar uma inst?ncia do objeto, popula...
            if Assigned(ObjetoLocal) then
            begin
              // Consulta o objeto relacionado
              DbReader := Consultar(ObjetoLocal, (Atributo as TAssociation).ForeingColumn + ' = ' + QuotedStr( String( ValorPropriedadeObjeto(pObjeto, (Atributo as TAssociation).LocalColumn))), '0');
              try
                if DbReader.Next then
                begin
                  // Popula Objeto
                  ObjetoLocal := VOFromDbReader(ObjetoLocal, DbReader);
                  // Inclui objeto no objeto principal
                  Propriedade.SetValue(pObjeto, ObjetoLocal);
                  // Continua populando as associa??es dentro do objeto at? que todos sejam populados recursivamente
                  PopularObjetosRelacionados(ObjetoLocal);
                end;
              finally
                if DbReader <> nil then
                  DbReader.Close;
                DbReader := nil;
              end;
            end;
          end;
        end;
      end;
    end;
  finally
    Contexto.Free;
 end;
end;
{$EndRegion}

{$Region 'Inser??o de Dados'}
class function TT2TiORM.Inserir(pObjeto: TObject): Integer;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
  Atributo: TCustomAttribute;
  ConsultaSQL, CamposSQL, ValoresSQL: String;
  UltimoID: Integer;
  Tabela: String;
  NomeTipo: String;
begin
  try
    Contexto := TRttiContext.Create;
    Tipo := Contexto.GetType(pObjeto.ClassType);

    // localiza o nome da tabela
    for Atributo in Tipo.GetAttributes do
    begin
      if Atributo is TTable then
      begin
        ConsultaSQL := 'INSERT INTO ' + (Atributo as TTable).Name;
        Tabela := (Atributo as TTable).Name;
      end;
    end;

    // preenche os nomes dos campos e valores
    for Propriedade in Tipo.GetProperties do
    begin
      for Atributo in Propriedade.GetAttributes do
      begin
        if Atributo is TColumn then
        begin
          if not(Atributo as TColumn).Transiente then
          begin
            if (Propriedade.PropertyType.TypeKind in [tkInteger, tkInt64]) then
            begin
              if (Propriedade.GetValue(pObjeto).AsInteger <> 0) then
              begin
                CamposSQL := CamposSQL + (Atributo as TColumn).Name + ',';
                ValoresSQL := ValoresSQL + Propriedade.GetValue(pObjeto).ToString + ',';
              end;
            end
            else if (Propriedade.PropertyType.TypeKind in [tkString, tkUString]) then
            begin
              if (Propriedade.GetValue(pObjeto).AsString <> '') then
              begin
                CamposSQL := CamposSQL + (Atributo as TColumn).Name + ',';
                ValoresSQL := ValoresSQL + QuotedStr(Propriedade.GetValue(pObjeto).ToString) + ',';
              end;
            end
            else if (Propriedade.PropertyType.TypeKind = tkFloat) then
            begin
              NomeTipo := LowerCase(Propriedade.PropertyType.Name);
              if NomeTipo = 'tdatetime' then
              begin
                CamposSQL := CamposSQL + (Atributo as TColumn).Name + ',';

                if Propriedade.GetValue(pObjeto).AsExtended > 0 then
                  ValoresSQL := ValoresSQL + QuotedStr(FormatDateTime('yyyy-mm-dd', Propriedade.GetValue(pObjeto).AsExtended)) + ','
                else
                  ValoresSQL := ValoresSQL + 'null,';
              end
              else
              begin
                CamposSQL := CamposSQL + (Atributo as TColumn).Name + ',';
                ValoresSQL := ValoresSQL + QuotedStr(FormatFloat('0.000000', Propriedade.GetValue(pObjeto).AsExtended)) + ',';
              end;
            end
            else
            begin
              CamposSQL := CamposSQL + (Atributo as TColumn).Name + ',';
              ValoresSQL := ValoresSQL + QuotedStr(Propriedade.GetValue(pObjeto).ToString) + ',';
            end;
          end;
        end
        else if Atributo is TId then
        begin
          if (Propriedade.GetValue(pObjeto).AsInteger <> 0) then
          begin
            CamposSQL := CamposSQL + (Atributo as TId).NameField + ',';
            ValoresSQL := ValoresSQL + Propriedade.GetValue(pObjeto).ToString + ',';
          end;
        end;
      end;
    end;

    // retirando as v?rgulas que sobraram no final
    Delete(CamposSQL, Length(CamposSQL), 1);
    Delete(ValoresSQL, Length(ValoresSQL), 1);

    ConsultaSQL := ConsultaSQL + '(' + CamposSQL + ') VALUES (' + ValoresSQL + ')';

    if FDataModuleConexao.getBanco = 'Firebird' then
    begin
      ConsultaSQL := ConsultaSQL + ' RETURNING ID ';
    end;

    T2TiExecuteSQL(FDataModuleConexao.GetDbConnection, ConsultaSQL);

    UltimoID := 0;
    if FDataModuleConexao.getBanco = 'MySQL' then
      UltimoID := T2TiExecuteScalarInt(FDataModuleConexao.GetDbConnection, 'select LAST_INSERT_ID() as id')
    else if FDataModuleConexao.getBanco = 'Firebird' then
      UltimoID := T2TiExecuteScalarInt(FDataModuleConexao.GetDbConnection, ConsultaSQL)
    else if FDataModuleConexao.getBanco = 'Postgres' then
      UltimoID := T2TiExecuteScalarInt(FDataModuleConexao.GetDbConnection, 'select Max(id) as id from ' + Tabela)
    else if FDataModuleConexao.getBanco = 'MSSQL' then
      UltimoID := T2TiExecuteScalarInt(FDataModuleConexao.GetDbConnection, 'select Max(id) as id from ' + Tabela);

    Result := UltimoID;
  finally
    Contexto.Free;
  end;
end;
{$EndRegion}

{$Region 'Altera??o de Dados'}
class function TT2TiORM.Alterar(pObjeto, pObjetoOld: TObject): Boolean;
var
  Contexto: TRttiContext;
  Tipo, TipoOld: TRttiType;
  Propriedade, PropriedadeOld: TRttiProperty;
  Atributo, AtributoOld: TCustomAttribute;
  ConsultaSQL, CamposSQL, FiltroSQL: String;
  NomeTipo: String;
  ValorNew, ValorOld: Variant;
  AchouValorOld: Boolean;
  QuantidadeCamposAlterados: Integer;
begin
  try
    QuantidadeCamposAlterados := 0;

    Contexto := TRttiContext.Create;
    Tipo := Contexto.GetType(pObjeto.ClassType);
    TipoOld := Contexto.GetType(pObjetoOld.ClassType);

    // localiza o nome da tabela
    for Atributo in Tipo.GetAttributes do
    begin
      if Atributo is TTable then
        ConsultaSQL := 'UPDATE ' + (Atributo as TTable).Name + ' SET ';
    end;

    // preenche os nomes dos campos e filtro
    for Propriedade in Tipo.GetProperties do
    begin
      for Atributo in Propriedade.GetAttributes do
      begin
        if Atributo is TColumn then
        begin
          if not(Atributo as TColumn).Transiente then
          begin
            AchouValorOld := False;
            ValorNew := Propriedade.GetValue(pObjeto).ToString;

            // Compara os dois VOs e s? considera para a consulta os campos que foram alterados
            for PropriedadeOld in TipoOld.GetProperties do
            begin
              for AtributoOld in PropriedadeOld.GetAttributes do
              begin
                if AtributoOld is TColumn then
                begin
                  if (AtributoOld as TColumn).Name = (Atributo as TColumn).Name then
                  begin
                    AchouValorOld := True;
                    ValorOld := Propriedade.GetValue(pObjetoOld).ToString;

                    // s? continua a execu??o se o valor que subiu em NewVO for diferente do OldVO
                    if ValorNew <> ValorOld then
                    begin

                      Inc(QuantidadeCamposAlterados);

                      if (Propriedade.PropertyType.TypeKind in [tkInteger, tkInt64]) then
                      begin
                        if (Propriedade.GetValue(pObjeto).AsInteger <> 0) then
                          CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' + Propriedade.GetValue(pObjeto).ToString + ','
                        else
                          CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' + 'null' + ',';
                      end

                      else if (Propriedade.PropertyType.TypeKind in [tkString, tkUString]) then
                      begin
                        if (Propriedade.GetValue(pObjeto).AsString <> '') then
                          CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' + QuotedStr(Propriedade.GetValue(pObjeto).ToString) + ','
                        else
                          CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' + 'null' + ',';
                      end

                      else if (Propriedade.PropertyType.TypeKind = tkFloat) then
                      begin
                        if Propriedade.GetValue(pObjeto).AsExtended <> 0 then
                        begin
                          NomeTipo := LowerCase(Propriedade.PropertyType.Name);
                          if NomeTipo = 'tdatetime' then
                            CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' + QuotedStr(FormatDateTime('yyyy-mm-dd', Propriedade.GetValue(pObjeto).AsExtended)) + ','
                          else
                            CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' + QuotedStr(FormatFloat('0.000000', Propriedade.GetValue(pObjeto).AsExtended)) + ',';
                        end
                        //else
                          //CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' + 'null' + ',';
                      end

                      else if Propriedade.GetValue(pObjeto).ToString <> '' then
                        CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' + QuotedStr(Propriedade.GetValue(pObjeto).ToString) + ','
                      else
                        CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' + 'null' + ',';

                    end;
                  end;
                end;
              end;
              // Quebra o for, pois j? encontrou o valor Old correspondente
              if AchouValorOld then
                Break;
            end;

          end;
        end
        else if Atributo is TId then
          FiltroSQL := ' WHERE ' + (Atributo as TId).NameField + ' = ' + QuotedStr(Propriedade.GetValue(pObjeto).ToString);
      end;
    end;

    if QuantidadeCamposAlterados > 0 then
    begin
      // retirando as v?rgulas que sobraram no final
      Delete(CamposSQL, Length(CamposSQL), 1);

      ConsultaSQL := ConsultaSQL + CamposSQL + FiltroSQL;

      T2TiExecuteSQL(FDataModuleConexao.GetDbConnection, ConsultaSQL);
    end;

    Result := True;
  finally
    Contexto.Free;
  end;
end;

class function TT2TiORM.Alterar(pObjeto: TObject): Boolean;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
  Atributo: TCustomAttribute;
  ConsultaSQL, CamposSQL, FiltroSQL: String;
  NomeTipo: String;
begin
  try
    Contexto := TRttiContext.Create;
    Tipo := Contexto.GetType(pObjeto.ClassType);

    // localiza o nome da tabela
    for Atributo in Tipo.GetAttributes do
    begin
      if Atributo is TTable then
        ConsultaSQL := 'UPDATE ' + (Atributo as TTable).Name + ' SET ';
    end;

    // preenche os nomes dos campos e filtro
    for Propriedade in Tipo.GetProperties do
    begin
      for Atributo in Propriedade.GetAttributes do
      begin
        if Atributo is TColumn then
        begin
          if not(Atributo as TColumn).Transiente then
          begin

            if (Propriedade.PropertyType.TypeKind in [tkInteger, tkInt64]) then
            begin
              if (Propriedade.GetValue(pObjeto).AsInteger <> 0) then
                CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' + Propriedade.GetValue(pObjeto).ToString + ','
              else
                CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' + 'null' + ',';
            end

            else if (Propriedade.PropertyType.TypeKind in [tkString, tkUString]) then
            begin
              if (Propriedade.GetValue(pObjeto).AsString <> '') then
                CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' + QuotedStr(Propriedade.GetValue(pObjeto).ToString) + ','
              else
                CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' + 'null' + ',';
            end

            else if (Propriedade.PropertyType.TypeKind = tkFloat) then
            begin
              if Propriedade.GetValue(pObjeto).AsExtended <> 0 then
              begin
                NomeTipo := LowerCase(Propriedade.PropertyType.Name);
                if NomeTipo = 'tdatetime' then
                  CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' + QuotedStr(FormatDateTime('yyyy-mm-dd', Propriedade.GetValue(pObjeto).AsExtended)) + ','
                else
                  CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' + QuotedStr(FormatFloat('0.000000', Propriedade.GetValue(pObjeto).AsExtended)) + ',';
              end
              // else
              // CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' + 'null' + ',';
            end

            else if Propriedade.GetValue(pObjeto).ToString <> '' then
              CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' + QuotedStr(Propriedade.GetValue(pObjeto).ToString) + ','
            else
              CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' + 'null' + ',';

          end;
        end
        else if Atributo is TId then
          FiltroSQL := ' WHERE ' + (Atributo as TId).NameField + ' = ' + QuotedStr(Propriedade.GetValue(pObjeto).ToString);
      end;
    end;

    // retirando as v?rgulas que sobraram no final
    Delete(CamposSQL, Length(CamposSQL), 1);

    ConsultaSQL := ConsultaSQL + CamposSQL + FiltroSQL;

    T2TiExecuteSQL(FDataModuleConexao.GetDbConnection, ConsultaSQL);

    Result := True;
  finally
    Contexto.Free;
  end;
end;
{$EndRegion}

{$Region 'Exclus?o de Dados'}
class function TT2TiORM.Excluir(pObjeto: TObject): Boolean;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
  Atributo: TCustomAttribute;
  ConsultaSQL, FiltroSQL: String;
begin
  try
    Contexto := TRttiContext.Create;
    Tipo := Contexto.GetType(pObjeto.ClassType);

    // localiza o nome da tabela
    for Atributo in Tipo.GetAttributes do
    begin
      if Atributo is TTable then
        ConsultaSQL := 'DELETE FROM ' + (Atributo as TTable).Name;
    end;

    // preenche o filtro
    for Propriedade in Tipo.GetProperties do
    begin
      for Atributo in Propriedade.GetAttributes do
      begin
        if Atributo is TId then
        begin
          FiltroSQL := ' WHERE ' + (Atributo as TId).NameField + ' = ' + QuotedStr(Propriedade.GetValue(pObjeto).ToString);
        end;
      end;
    end;

    ConsultaSQL := ConsultaSQL + FiltroSQL;

    T2TiExecuteSQL(FDataModuleConexao.GetDbConnection, ConsultaSQL);

    Result := True;
  finally
    Contexto.Free;
  end;
end;
{$EndRegion}

{$Region 'Consultas'}
class function TT2TiORM.Consultar(pObjeto: TObject; pFiltro: String; pPagina: String): IDbReader;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Atributo: TCustomAttribute;
  Propriedade: TRttiProperty;
  ConsultaSQL, FiltroSQL, Campo, NomeTabelaPrincipal, Joins: String;
begin
  try
    try
      Contexto := TRttiContext.Create;
      Tipo := Contexto.GetType(pObjeto.ClassType);

      // pega o nome da tabela principal
      for Atributo in Tipo.GetAttributes do
      begin
        if Atributo is TTable then
        begin
          NomeTabelaPrincipal := (Atributo as TTable).Name;
        end;
      end;

      // monta o inicio da consulta
      for Atributo in Tipo.GetAttributes do
      begin
        if Atributo is TTable then
        begin
          if (FDataModuleConexao.getBanco = 'Firebird') and (StrToInt(pPagina) >= 0) then
          begin
            ConsultaSQL := 'SELECT first ' + IntToStr(TConstantes.QUANTIDADE_POR_PAGINA) + ' skip ' + pPagina + ' * FROM ' + (Atributo as TTable).Name;
          end
          else
          begin
            ConsultaSQL := 'SELECT * FROM ' + (Atributo as TTable).Name;
          end;
        end;
      end;

      if FDataModuleConexao.getBanco = 'Postgres' then
      begin
        if pFiltro <> '' then
        begin
          // N?o diferenciar letras mai?sculas de min?sculas e nem acentuadas de n?o acentuadas.
          pFiltro := StringReplace(pFiltro, 'LIKE', 'ILIKE', [rfReplaceAll]);
          pFiltro := StringReplace(pFiltro, '[', ' CAST(', [rfReplaceAll]);
          pFiltro := StringReplace(pFiltro, ']', ' as VARCHAR)',[rfReplaceAll]);
          pFiltro := StringReplace(pFiltro, '"', chr(39), [rfReplaceAll]);
          FiltroSQL := ' WHERE ' + FormatarFiltro(pFiltro);
        end;
      end

      else if FDataModuleConexao.getBanco = 'Firebird' then
      begin
        if pFiltro <> '' then
        begin
          // N?o diferenciar letras mai?sculas de min?sculas e nem acentuadas de n?o acentuadas.
          pFiltro := StringReplace(pFiltro, '[', ' CAST([', [rfReplaceAll]);
          pFiltro := StringReplace(pFiltro, ']', ' as TEXT)] ',[rfReplaceAll]);
          pFiltro := StringReplace(pFiltro, '', chr(39), [rfReplaceAll]);
          FiltroSQL := ' WHERE ' + FormatarFiltro(pFiltro);
        end;
      end

      else if pFiltro <> '' then
      begin
        FiltroSQL := ' WHERE ' + FormatarFiltro(pFiltro);
      end;

      ConsultaSQL := ConsultaSQL + FiltroSQL;

      if (FDataModuleConexao.getBanco = 'MySQL') and (StrToInt(pPagina) >= 0) then
      begin
        ConsultaSQL := ConsultaSQL + ' limit ' + IntToStr(TConstantes.QUANTIDADE_POR_PAGINA) + ' offset ' + pPagina;
      end
      else if (FDataModuleConexao.getBanco = 'Postgres') and (StrToInt(pPagina) >= 0) then
      begin
        ConsultaSQL := ConsultaSQL + ' limit ' + IntToStr(TConstantes.QUANTIDADE_POR_PAGINA) + ' offset ' + pPagina;
      end;

      // Retira os [] da consulta
      ConsultaSQL := StringReplace(ConsultaSQL, '[', '', [rfReplaceAll]);
      ConsultaSQL := StringReplace(ConsultaSQL, ']', '', [rfReplaceAll]);

      Result := T2TiOpenQuery(FDataModuleConexao.GetDbConnection, ConsultaSQL);
    except
      raise ;
    end;
  finally
    Contexto.Free;
  end;
end;

class function TT2TiORM.Consultar(pConsulta: String; pFiltro: String; pPagina: String): IDbReader;
var
  FiltroSQL: String;
begin
  try
    try
      if FDataModuleConexao.getBanco = 'Postgres' then
      begin
        if pFiltro <> '' then
        begin
          pFiltro := StringReplace(FormatarFiltro(pFiltro), '"', chr(39), [rfReplaceAll]);
          FiltroSQL := ' and ' + pFiltro;
        end;
      end
      else
      begin
        if pFiltro <> '' then
        begin
          pFiltro := FormatarFiltro(pFiltro);
          FiltroSQL := ' and ' + pFiltro;
        end;
      end;

      Result := T2TiOpenQuery(FDataModuleConexao.GetDbConnection, pConsulta + FiltroSQL);
    except
      raise ;
    end;
  finally

  end;
end;

class function TT2TiORM.Consultar<T>(pFiltro: String; pPagina: String; pConsultaCompleta: Boolean): TObjectList<T>;
var
  DbReader: IDbReader;
  ObjConsulta: TObject;
  ObjetoLocal: T;
begin
  ConsultaCompleta := pConsultaCompleta;
  Result := TObjectList<T>.Create;
  ObjConsulta := TClass(T).Create;
  try
    DbReader := Consultar(ObjConsulta, pFiltro, pPagina);
    try
      while DbReader.Next do
      begin
        ObjetoLocal := TGenericVO<T>.FromDbReader(DbReader);
        PopularObjetosRelacionados(TVO(ObjetoLocal));
        Result.Add(ObjetoLocal);
      end;
    finally
      if DbReader <> nil then
        DbReader.Close;
      DbReader := nil;
    end;
  finally
    ObjConsulta.Free;
  end;
end;

class function TT2TiORM.ConsultarUmObjeto<T>(pFiltro: String; pConsultaCompleta: Boolean): T;
var
  DbReader: IDbReader;
  ObjConsulta: TObject;
  ObjetoLocal: T;
begin
  ConsultaCompleta := pConsultaCompleta;
  ObjConsulta := TClass(T).Create;
  try
    DbReader := Consultar(ObjConsulta, pFiltro, '0');
    try
      if DbReader.Next then
      begin
        ObjetoLocal := TGenericVO<T>.FromDbReader(DbReader);
        PopularObjetosRelacionados(TVO(ObjetoLocal));
        Result := ObjetoLocal;
      end
      else
        Result := Nil;
    finally
      if DbReader <> nil then
        DbReader.Close;
      DbReader := nil;
    end;
  finally
    ObjConsulta.Free;
  end;
end;
{$EndRegion}

{$Region 'SQL Outros'}
class function TT2TiORM.ComandoSQL(pConsulta: String): Boolean;
begin
  try
    Result := T2TiExecuteSQL(FDataModuleConexao.GetDbConnection, pConsulta);
  except
    Result := False;
  end;
end;

class function TT2TiORM.SelectMax(pTabela: String; pFiltro: String): Integer;
var
  ConsultaSQL: String;
  Reader: IDbReader;
begin
  ConsultaSQL := 'SELECT MAX(ID) AS MAXIMO FROM ' + pTabela;
  if pFiltro <> '' then
    ConsultaSQL := ConsultaSQL + ' WHERE ' + pFiltro;
  try
    Reader := T2TiOpenQuery(FDataModuleConexao.GetDbConnection, ConsultaSQL);
    try
      if Reader.Next then
        Result := Reader.GetValue(0).AsType<Integer>
      else
        Result := -1;
    finally
      Reader.Close;
    end;
  except
    Result := -1;
  end;
end;

class function TT2TiORM.SelectMin(pTabela: String; pFiltro: String): Integer;
var
  ConsultaSQL: String;
  Reader: IDbReader;
begin
  ConsultaSQL := 'SELECT MIN(ID) AS MINIMO FROM ' + pTabela;
  if pFiltro <> '' then
    ConsultaSQL := ConsultaSQL + ' WHERE ' + pFiltro;
  try
    Reader := T2TiOpenQuery(FDataModuleConexao.GetDbConnection, ConsultaSQL);
    try
      if Reader.Next then
        Result := Reader.GetValue(0).AsType<Integer>
      else
        Result := -1;
    finally
      Reader.Close;
    end;
  except
    Result := -1;
  end;
end;

class function TT2TiORM.SelectCount(pTabela: String): Integer;
var
  ConsultaSQL: String;
  Reader: IDbReader;
begin
  ConsultaSQL := 'SELECT COUNT(*) AS TOTAL FROM ' + pTabela;
  try
    Reader := T2TiOpenQuery(FDataModuleConexao.GetDbConnection, ConsultaSQL);
    try
      if Reader.Next then
        Result := Reader.GetValue(0).AsType<Integer>
      else
        Result := -1;
    finally
      Reader.Close;
    end;
  except
    Result := -1;
  end;
end;
{$EndRegion}


end.
