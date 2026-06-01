# Code Conventions

Conven��es **observadas** no c�digo existente (n�o idealizadas).

## Naming Conventions

**Units (arquivos):**

- VOs: `{Entidade}VO.pas` � ex.: `UsuarioVO.pas`, `NfeCabecalhoVO.pas`
- Controllers: `{Entidade}Controller.pas` � ex.: `UsuarioController.pas`
- Telas: `U{Nome}.pas` � ex.: `ULogin.pas`, `UNFe.pas`, `UMenu.pas`
- DataModules: `UDataModule*.pas`
- Prefixo `T2Ti` em projetos: `T2TiERPVendas.dpr`, `T2TiORM.pas`

**Classes:**

- VOs: `T{Entidade}VO` herda `TVO` � ex.: `TUsuarioVO`
- Controllers: `T{Entidade}Controller` herda `TController` � ex.: `TUsuarioController`
- Forms: `TF{Nome}` � ex.: `TFLogin`, `TFNFe`
- DataModules: `TFDataModuleConexao`, `TFDataModuleNFe`

**M�todos:**

- Controllers: verbos em portugu�s � `Consulta`, `Inserir`, `Alterar`, `Excluir`, `Usuario`
- Par�metros prefixados com `p` � `pLogin`, `pSenha`, `pFiltro`, `pPagina`
- M�todos de classe predominantes nos controllers (`class procedure`, `class function`)

**Vari�veis:**

- Campos privados: prefixo `F` � `FUsuario`, `FHttp`, `FID`
- Campos de VO mapeados para colunas: `F` + nome da coluna � `FID_COLABORADOR`
- Globais de unit: sem prefixo consistente � ex.: `InString` em `Biblioteca.pas`
- Conex�o global: `Conexao: TSQLConnection`, `Query: TSQLQuery` em `T2TiORM.pas`

**Constantes:**

- Centralizadas em `Comum/Constantes.pas`
- Atributos ORM em `Comum/Atributos.pas` � `TEntity`, `TTable`, `TColumn`, `TGeneratedValue`

## Code Organization

**Uses clause:**

- `interface` uses: units Delphi/VCL primeiro, depois units do projeto
- `implementation` uses: controllers referenciados sob demanda (evita refer�ncia circular)
- Exemplo `SessaoUsuario.pas`: interface usa `UsuarioVO`, `DSHTTP`; implementation usa `UsuarioController`, `Controller`

**Estrutura de unit:**

1. Bloco de coment�rio MIT License + `@author Albert Eije` + `@version`
2. `unit Nome;`
3. `interface` ? `uses` ? `type` ? m�todos
4. `implementation` ? `uses` ? corpo
5. Sem se��es expl�citas de regi�o na maioria dos arquivos

**Estrutura de VO:**

```pascal
[TEntity]
[TTable('USUARIO')]
TUsuarioVO = class(TVO)
private
  FID: Integer;
  // campos mapeados
public
  property ID: Integer read FID write FID;
end;
```

**Estrutura de Controller:**

```pascal
TUsuarioController = class(TController)
public
  class procedure Consulta(pFiltro: String; pPagina: String; ...);
  class procedure Inserir;
  class procedure Alterar;
  class procedure Excluir;
end;
```

## Type Safety / Documentation

**Approach:** Pascal tipado + RTTI para dispatch gen�rico; generics em `TObjectList<T>` e m�todos `TratarRetorno<O: class>`

**Documenta��o:** Coment�rio de cabe�alho por unit (Title, Description, MIT License); poucos coment�rios inline no corpo

**JSON:** Serializa��o via `JSonVO.pas` + DBXJSON, n�o REST.Json moderno

## Error Handling

**Pattern:** `try/finally` para recursos; `ShowMessage`/`Dialogs` em controllers cliente; exce��es propagadas do ORM

**Exemplo:** `SessaoUsuario.Create` � `TIniFile` com `try/finally Ini.Free`

**Controllers:** retorno booleano ou dataset; erros de neg�cio frequentemente via mensagem na UI, n�o exce��es tipadas

## Comments / Documentation

**Style:** Cabe�alho MIT em quase toda unit; coment�rios inline espor�dicos (ex.: `//Permiss�es` em `SessaoUsuario.pas`)

**Hist�rico:** Pastas `__history/` commitadas com vers�es antigas de units � n�o usar como fonte de verdade

## Configura��o

**Padr�o INI:** `Conexao.ini` por m�dulo com se��o `[ServidorApp]`

**Padr�o TXT:** `{SGBD}_DBExpress_conn.txt` no diret�rio do execut�vel (`HostName`, `Database`, `User_Name`, `Password`)

**Paths:** `ExtractFilePath(Application.ExeName)` ou helper `CaminhoApp` / `gsAppPath`

## Exce��es observadas

- NFC-e Mobile: fork de VOs e ORM em `Cliente/NFC-e Mobile/`
- Loja Virtual: padr�o uniGUI + DB direto, n�o DataSnap
- AFV: FMX + FireDAC, diferente do stack VCL/DBExpress
- `Cadastros` vs `CadastrosM`: dois execut�veis quase id�nticos
