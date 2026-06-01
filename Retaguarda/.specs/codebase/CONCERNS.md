# Codebase Concerns

**Analysis Date:** 2026-05-30

## Tech Debt

**Duplica��o massiva de units entre m�dulos:**

- Issue: Mesmas telas/units copiadas em v�rios execut�veis
- Files: `UProduto.pas` (9 c�pias), `USpedFiscal.pas` (4 c�pias), `UMenu.pas` (37 c�pias), `Cliente/BalcaoPAF/Tela/UNFe.pas` ? `Cliente/NF-e/Tela/UNFe.pas`
- Why: Cada m�dulo compilado independentemente, sem pacotes compartilhados de UI
- Impact: Bugfix exige altera��o em N lugares; diverg�ncia silenciosa entre m�dulos
- Fix approach: Extrair units compartilhadas para pacote `.dpk` ou `Cliente/Comum/`; unificar `Cadastros` e `CadastrosM`

**God units (UI + neg�cio + integra��o no mesmo form):**

- Issue: Forms monol�ticos com milhares de linhas
- Files: `Cliente/NF-e/Tela/UNFe.pas` (~3.021 linhas), `Cliente/eSocial/Tela/uExemploEsocial.pas` (~3.197), `Comum/Controller/SpedFiscalController.pas` (~1.249), `Comum/Biblioteca.pas` (~1.180)
- Why: Evolu��o incremental sem refatora��o
- Impact: Alto risco de regress�o; imposs�vel testar unitariamente
- Fix approach: Extrair services (c�lculo NF-e, transmiss�o Sefaz, persist�ncia) em units separadas; manter form s� como orquestrador

**ORM e stack legado DBExpress:**

- Issue: `T2TiORM.pas` acoplado a `TSQLConnection` global
- Files: `Comum/T2TiORM.pas`, `Comum/DataModule/UDataModuleConexao.pas`
- Why: Stack original do treinamento T2Ti (Delphi XE7)
- Impact: Migra��o para FireDAC/Zeos exige refatora��o ampla; DBExpress deprecated
- Fix approach: Adapter layer ou migra��o incremental por m�dulo; come�ar por controllers isolados

**Variantes de stack por m�dulo:**

- Issue: NFC-e Mobile, AFV e Loja Virtual usam FMX/FireDAC/uniGUI diferentes do core
- Files: `Cliente/NFC-e Mobile/`, `Cliente/AFV/`, `Cliente/Loja Virtual/`
- Impact: Manuten��o multiplicada; VOs e ORM forked em NFC-e Mobile
- Fix approach: Documentar m�dulos "exce��o"; evitar expandir forks; plano de converg�ncia opcional

## Security Considerations

**Hash MD5 sem salt para senhas:**

- Risk: Senhas vulner�veis a rainbow tables; algoritmo obsoleto
- Files: `Comum/Controller/UsuarioController.pas` (`MD5String(pLogin+pSenha)`), `Cliente/Comum/SessaoUsuario.pas`
- Current mitigation: Nenhuma efetiva
- Recommendations: bcrypt/Argon2 + salt; nunca rearmazenar senha plaintext (`FUsuario.Senha := pSenha` ap�s login)

**Autentica��o server-side fraca:**

- Risk: Valida��o de sess�o no servidor possivelmente desabilitada
- Files: `Servidor/ServerContainer.pas` � `GetUsuario` comentado; `DSAuth` importado mas n�o configurado
- Current mitigation: HTTP Basic no cliente apenas
- Recommendations: Reativar auth manager DataSnap; validar `idSessao` server-side em todo request

**Credenciais em arquivos e c�digo:**

- Risk: Exposi��o de credenciais de banco em repo e deploy
- Files: `Servidor/MySQL_DBExpress_conn.txt` (`Password=root`), `Servidor/Postgres_DBExpress_conn.txt`, `SM/RESTserver.dpr` (`Pwd=root`), ~96 c�pias `*_DBExpress_conn.txt` nos m�dulos
- Recommendations: Vari�veis de ambiente ou vault; `.gitignore` nos conn files; usu�rio DB least-privilege

**REST mORMot sem autentica��o:**

- Risk: API exposta com CORS `*` e `authentication=false`
- Files: `SM/RESTserver.dpr`
- Recommendations: Descontinuar ou adicionar auth antes de qualquer deploy; n�o expor em produ��o

**SQL din�mico concatenado:**

- Risk: SQL injection em filtros
- Files: `Comum/Controller/NfeCabecalhoController.pas` e outros com `ComandoSQL('DELETE ... ' + IntToStr(pId))` e `pFiltro` concatenado
- Recommendations: Parametrizar queries no ORM; whitelist de filtros

## Fragile Areas

**Dispatcher RTTI gen�rico:**

- Files: `Servidor/Controller.pas`, `Cliente/Comum/Controller.pas`
- Why fragile: Um endpoint exp�e todos os controllers; contrato n�o tipado; dif�cil versionar API
- Common failures: Breaking change em assinatura de m�todo; serializa��o JSON incompat�vel
- Safe modification: Adicionar testes de contrato antes de alterar `MontarParametros` ou `ExecutarMetodo`
- Test coverage: Nenhuma

**M�dulo NF-e (`UNFe.pas`):**

- Files: `Cliente/NF-e/Tela/UNFe.pas` + controllers `Nfe*`
- Why fragile: ACBr + c�lculos + UI + persist�ncia acoplados; c�pia em BalcaoPAF
- Common failures: Rejei��o Sefaz, certificado expirado, diverg�ncia de totais
- Safe modification: Alterar apenas via extra��o de service; testar em homologa��o Sefaz
- Test coverage: Nenhuma

**Gera��o SPED:**

- Files: `Comum/Controller/SpedFiscalController.pas`, `Servidor/UDataModule.pas`
- Why fragile: Regras fiscais complexas; sa�da em path relativo ao exe
- Safe modification: Comparar arquivo gerado com SPED validator externo; n�o alterar layout sem spec fiscal

**Paths relativos ao execut�vel:**

- Files: Controllers SPED, Sintegra, GED � `\Arquivos\Sped\`, `\Arquivos\GED\`
- Why fragile: Deploy em path diferente quebra gera��o de arquivos
- Safe modification: Centralizar path config em INI ou vari�vel de ambiente

## Dependencies at Risk

**Delphi XE7 (ProjectVersion 15.3):**

- Risk: IDE e DBExpress sem suporte ativo; incompatibilidade com Windows moderno
- Impact: Imposs�vel compilar sem ambiente legado; seguran�a do runtime
- Migration plan: Upgrade gradual para Delphi 11/12 + FireDAC; m�dulo piloto (Cadastros)

**DBExpress:**

- Risk: Deprecated pela Embarcadero
- Impact: Drivers podem falhar em OS novos
- Migration plan: FireDAC com adapter sobre `T2TiORM` ou reescrita do ORM

**ACBr (externo ao repo):**

- Risk: Vers�o n�o pinada; breaking changes entre releases ACBr
- Impact: Falha de transmiss�o fiscal ap�s upgrade ACBr
- Migration plan: Documentar vers�o ACBr testada; submodule ou package manager interno

## Performance Bottlenecks

**Dispatcher �nico + JSON + RTTI:**

- Problem: Overhead de serializa��o/deserializa��o em toda opera��o CRUD
- Files: `Servidor/Controller.pas`, `Cliente/Comum/Controller.pas`
- Cause: Arquitetura gen�rica 3 camadas
- Improvement path: Cache de sess�o; endpoints especializados para opera��es bulk; modo 2 camadas em LAN

**Globais de conex�o ORM:**

- Problem: `Conexao`/`Query` globais � conten��o em carga
- Files: `Comum/T2TiORM.pas`
- Improvement path: Pool de conex�es; contexto por thread/request

*Nota: Sem medi��es de performance no repo � n�meros acima s�o infer�ncia arquitetural.*

## Test Coverage Gaps

**Camadas cr�ticas sem testes:**

- Problem: Zero testes automatizados em ERP fiscal/financeiro
- Files: Todos os `Comum/Controller/*`, `T2TiORM.pas`, fluxos ACBr
- Blocks: Refatora��o segura, CI, regress�o fiscal
- Priority for testing:
  1. `UsuarioController` + auth
  2. `NfeCabecalhoController` + c�lculos
  3. `SpedFiscalController`
  4. `T2TiORM` CRUD b�sico

## Missing Critical Features

**Build unificado:**

- Problem: Sem `.groupproj` ou script de build CI
- Current workaround: Compilar m�dulo a m�dulo na IDE
- Blocks: Deploy reproduc�vel, automa��o

**Documenta��o de ambiente:**

- Problem: Depend�ncias ACBr, Devart, JVCL n�o versionadas no repo
- Current workaround: Instala��o manual conforme treinamento T2Ti
- Blocks: Onboarding de novos desenvolvedores

## Scaling Limits

**Servidor DataSnap monol�tico:**

- Current capacity: N�o medido; arquitetura single-process
- Limit: Um `T2Ti_ServidorAplicacao` atende todos os controllers
- Symptoms at limit: Lat�ncia HTTP, conten��o DB, mem�ria (FastMM4 ajuda mas n�o escala horizontal)
- Scaling path: Separar servi�os por dom�nio; load balancer; read replicas DB � requer redesign

## Known Bugs

Nenhum bug espec�fico reproduzido nesta an�lise est�tica. Investiga��o runtime necess�ria para issues funcionais.

---

**Prioridade sugerida para pr�ximas features:**

1. Seguran�a (MD5, credenciais, auth servidor)
2. Consolidar duplica��o (`UNFe`, `UProduto`, Cadastros)
3. Introduzir DUnitX nos controllers fiscais
4. Documentar vers�es ACBr/Devart para build reproduc�vel
