# Tech Stack

**Analisado:** 2026-05-30

## Core

- **Framework:** Delphi / RAD Studio **XE7** (`ProjectVersion=15.3` nos `.dproj`)
- **Linguagem:** Object Pascal (Delphi)
- **Runtime:** Windows nativo (Win32 predominante; Win64 pontual)
- **Gerenciador de pacotes:** Nenhum no reposit�rio � depend�ncias instaladas localmente na IDE + paths externos

## Frontend

- **UI Framework:** VCL (maioria dos m�dulos); exce��es FMX (`Cliente/AFV`, `Cliente/NFC-e Mobile`) e uniGUI (`Cliente/Loja Virtual`)
- **Estiliza��o:** VCL padr�o + **JVCL** (`JvDBUltimGrid`, componentes `Jv*`)
- **Estado:** Singleton `TSessaoUsuario.Instance` + `TClientDataSet` como camada de transporte UI?controller
- **Formul�rios:** Forms Delphi em `Cliente/*/Tela/`; base compartilhada em `Cliente/Comum/Tela/` (`UBase`, `UTela`, `ULogin`)

## Backend

- **API Style:** DataSnap HTTP REST-like (JSON) � endpoint gen�rico `TController.ObjetoJson`
- **Alternativa experimental:** mORMot/Synopse REST em `SM/RESTserver.dpr` (porta 888, PostgreSQL ODBC)
- **Database:** DBExpress (`TSQLConnection`) + ORM pr�prio `T2TiORM.pas`
- **SGBDs suportados:** MySQL (default), PostgreSQL (Devart), Firebird, Interbase, Oracle, MSSQL, DB2
- **Autentica��o:** HTTP Basic Auth no cliente DataSnap; hash MD5(login+senha); permiss�es por `PapelVO`/`FuncaoVO`

## Testing

- **Unit:** Nenhum framework detectado (sem DUnit/DUnitX)
- **Integration:** Ausente
- **E2E:** Ausente
- **CI:** Ausente (sem GitHub Actions, Jenkins, etc.)

## External Services

- **Fiscal (Sefaz):** ACBr � NF-e, NFC-e, NFS-e, CT-e, SPED, Sintegra, eSocial, Ponto/AFD
- **Impress�o fiscal:** ACBr PosPrinter, DANFe ESC/POS
- **Boletos:** ACBr Boleto + FastReport
- **Banc�rio:** Importa��o OFX/OFC (`Comum/YMOFXReader.pas`, `YMOFCReader.pas`)
- **Relat�rios:** FastReport (`.fr3`) + templates ACBr (DANFe, DACTe, DANFSe)

## Development Tools

- **IDE:** RAD Studio XE7 (evid�ncia: `ProjectVersion=15.3`)
- **Memory manager:** FastMM4 (`Servidor/T2Ti_ServidorAplicacao.dpr`)
- **HTTP:** Indy (`IdHTTP`, `TDSHTTP`)
- **Serializa��o:** DBXJSON + RTTI customizado (`Comum/JSonVO.pas`)
- **Componentes fiscais:** ACBr (path externo esperado: `Componentes/Delphi/ACBr2/` � **n�o versionado**)
- **PostgreSQL driver:** Devart DBExpress (`dbexppgsql40.dll`)
- **Debug/logging:** CodeSite (referenciado em alguns `.dproj` mais recentes)

## Depend�ncias externas (fora do repo)

| Biblioteca | Uso |
|------------|-----|
| ACBr | Documentos fiscais, SPED, boletos, impressora |
| JVCL | Grids e componentes visuais |
| Indy | HTTP cliente/servidor |
| FastReport | Relat�rios `.fr3` |
| uniGUI | Loja Virtual web |
| FireDAC | AFV, NFC-e Mobile, PCP (pontual) |
| mORMot/Synopse | `SM/RESTserver.dpr` |
| Zeos | Apenas em `.dproj` do AFV (n�o no ORM central) |
| PCN2/synapse | Pacotes fiscais referenciados em `.dproj` |
