# Dependency Matrix � Migra��o Delphi 13

**Gerado:** 2026-05-30  
**Baseline:** Delphi XE7  
**Target:** RAD Studio 13.1 Florence

Legenda: ?? Nativo manter | ?? Eliminar ? substituto | ?? Decis�o pendente

---

## Camada de Dados

| Depend�ncia | Units/Files | M�dulos | Substituto D13 | A��o | Fase |
|-------------|-------------|---------|----------------|------|------|
| DBExpress | `Comum/T2TiORM.pas`, `UDataModuleConexao.pas`, 96� `*_DBExpress_conn.txt` | Todos | **FireDAC** | ?? Substituir | F3 |
| Devart PostgreSQL | `UDataModuleConexao.pas` (`DevartPostgreSQL`) | Servidor, Comum | **FDPhysPgDriverLink** | ?? Substituir | F3 |
| Zeos `ZComponent` | `Cliente/AFV/T2TiERPAFV.dproj` | AFV | **FireDAC** | ?? Substituir | F6 |
| `TClientDataSet` | Controllers, telas | Todos | Manter (VCL nativo) | ?? Manter | � |

---

## UI / Visual

| Depend�ncia | Units/Files | M�dulos | Substituto D13 | A��o | Fase |
|-------------|-------------|---------|----------------|------|------|
| JVCL `JvDBUltimGrid` | `Comum/Biblioteca.pas`, `Cliente/Comum/Tela/UBase.pas` | ~200 telas | **TDBGrid** VCL | ?? Substituir | F4 |
| JVCL `JvAppFrm`, docking, etc. | `UMenu.pas` (37�) | Todos clientes | VCL nativo | ?? Substituir | F4 |
| FastReport `frx*` | `UNFe.pas`, `UEtiquetaTemplate.pas`, 15 `.fr3` | NF-e, Etiquetas, BalcaoPAF | **QuickReport** / PDF | ?? Substituir | F4/F7 |
| TeeChart `Tee*` | Alguns `.dproj` | V�rios | TeeChart (bundled D13?) | ?? Verificar licen�a | F2 |
| Rave Reports | `.dproj` legacy paths | Legado | Remover | ?? Eliminar | F2 |
| IntraWeb | `.dproj` packages | Legado | Remover | ?? Eliminar | F2 |

---

## Servidor / Comunica��o

| Depend�ncia | Units/Files | M�dulos | Substituto D13 | A��o | Fase |
|-------------|-------------|---------|----------------|------|------|
| DataSnap | `ServerContainer.pas`, `Controller.pas` | Servidor + Clientes | DataSnap D13 | ?? Migrar API | F5 |
| Indy | `SessaoUsuario.pas`, HTTP | Todos | Indy (incluso) | ?? Manter | F5 |
| DBXJSON | `Controller.pas`, `JSonVO.pas` | Servidor + Cliente | **System.JSON** | ?? Substituir | F5 |
| REST Components | AFV `.dproj` | AFV | REST nativo D13 | ?? Manter | F6 |
| mORMot/Synopse | `SM/RESTserver.dpr` | SM | N/A | ?? Descontinuar | F6 |

---

## Fiscal (decis�o pendente)

| Depend�ncia | Units/Files | M�dulos | Substituto nativo? | A��o | Fase |
|-------------|-------------|---------|---------------------|------|------|
| ACBr NFe | `UDataModuleNFe.pas`, `UNFe.pas` | NF-e, BalcaoPAF, Estoque | ? N�o existe | ?? Decis�o | F7 |
| ACBr NFSe | `UNFSe.pas` | NFS-e | ? N�o existe | ?? Decis�o | F7 |
| ACBr CTe | `UDataModuleCTe.pas`, `UCTe.pas` | CT-e | ? N�o existe | ?? Decis�o | F7 |
| ACBr SPED | `SpedFiscalController.pas`, `UDataModule.pas` | Sped, Servidor | ? N�o existe | ?? Decis�o | F7 |
| ACBr eSocial | `uExemploEsocial.pas` | eSocial | ? N�o existe | ?? Decis�o | F7 |
| ACBr Ponto | `ACBrPonto/` | Ponto | ? N�o existe | ?? Decis�o | F7 |
| ACBr PosPrinter | `UDataModule.pas` | BalcaoPAF | ? N�o existe | ?? Decis�o | F7 |
| ACBr Boleto | `UDataModule.pas` | Financeiro | ? N�o existe | ?? Decis�o | F7 |
| synapse/PCN2 | `.dproj` packages | Fiscal | Parte ACBr | ?? Com ACBr | F7 |

---

## Web / Mobile (exce��es)

| Depend�ncia | Units/Files | M�dulos | Substituto | A��o | Fase |
|-------------|-------------|---------|------------|------|------|
| uniGUI | `Cliente/Loja Virtual/` | Loja Virtual | Nenhum nativo | ?? Decis�o | F8 |
| FireDAC (j� parcial) | NFC-e Mobile, AFV | Mobile/AFV | FireDAC nativo | ?? Expandir | F3/F6 |
| FMX | NFC-e Mobile, AFV | 2 m�dulos | FMX nativo | ?? Migrar .dproj | F6 |

---

## Utilit�rios

| Depend�ncia | Files | Substituto | A��o | Fase |
|-------------|-------|------------|------|------|
| FastMM4 | `T2Ti_ServidorAplicacao.dpr` | Default MM | ?? Remover | F5 |
| CodeSite | PCP, AFV `.dproj` | Remover ou D13 equiv | ?? Remover | F6 |
| Word Automation | `UPontoEspelho.pas` | Manter COM (Windows) | ?? Manter | F6 |

---

## Contagem por a��o

| A��o | Qtd depend�ncias |
|------|------------------|
| ?? Eliminar/Substituir nativo | 12 |
| ?? Manter/Migrar API | 5 |
| ?? Decis�o pendente | 11 (ACBr + uniGUI) |

---

## M�dulos por complexidade de migra��o

| Tier | Crit�rio | M�dulos |
|------|----------|---------|
| **T1 � Simples** | Sem ACBr, CRUD puro | Cadastros, Agenda, Etiquetas, GED |
| **T2 � M�dio** | CRUD + relat�rios | Vendas, Compras, Estoque, Financeiro (7), Contratos |
| **T3 � Complexo** | FMX ou fork | AFV, NFC-e Mobile |
| **T4 � Fiscal** | ACBr pesado | NF-e, CT-e, NFS-e, Sped, eSocial, BalcaoPAF, Ponto |
| **T5 � Excluir** | Stack diferente | SM, Loja Virtual |
