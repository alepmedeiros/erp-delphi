# Roadmap

**Current Milestone:** M1 � Prepara��o e Invent�rio  
**Status:** In Progress  
**Objetivo principal:** Migrar T2Ti ERP Retaguarda de Delphi XE7 ? **RAD Studio 13 Florence**, stack nativa Embarcadero

---

## Vis�o da Migra��o (8 fases)

```
F0 Doc ? ? F1 Prep ? F2 Piloto ? F3 Core (ORM/DB) ? F4 UI Nativa
    ? F5 Servidor ? F6 M�dulos Operacionais ? F7 Fiscal ? F8 Finaliza��o
```

**Princ�pio:** Cada fase deixa pelo menos 1 artefato compil�vel e test�vel. Fiscal por �ltimo (maior risco).

---

## F0 � Documenta��o Baseline ? COMPLETE

**Goal:** Entender o codebase antes de migrar  
**Conclu�do:** 2026-05-30

- Brownfield mapping (`.specs/codebase/`)
- Project init + realinhamento para migra��o Delphi 13
- Feature spec `delphi-migration/` criada

---

## F1 � Prepara��o e Invent�rio

**Goal:** Ambiente D13 pronto + invent�rio completo de depend�ncias  
**Target:** Invent�rio aprovado + branch de migra��o criada

### Features

**Ambiente RAD Studio 13** - PLANNED

- Instalar RAD Studio 13.1 Florence
- Configurar paths de biblioteca (sem paths XE7)
- Documentar vers�o exata e updates instalados

**Invent�rio de Depend�ncias** - PLANNED

- Matriz: unit/pacote ? m�dulos afetados ? substituto nativo ? esfor�o
- Classificar: ELIMINAR | SUBSTITUIR NATIVO | DECIS�O PENDENTE (ACBr)
- Output: `.specs/features/delphi-migration/dependency-matrix.md`

**Baseline de Compila��o XE7 (refer�ncia)** - PLANNED

- Documentar quais m�dulos compilavam em XE7 (se ambiente dispon�vel)
- Capturar lista de erases/warnings conhecidos

**Branch e Pol�tica de Merge** - PLANNED

- Branch `feature/delphi13-migration`
- Regra: 1 PR por fase/subfase; nunca merge sem gate de compila��o

---

## F2 � M�dulo Piloto (Cadastros)

**Goal:** Provar pipeline de migra��o em 1 EXE simples, sem ACBr  
**Target:** `T2TiERP_Cadastros.dpr` compila e executa em D13

### Features

**Convers�o de Projeto** - PLANNED

- Migrar `.dproj` XE7 ? D13 (Project Upgrade Wizard)
- Remover pacotes obsoletos do `DCC_UsePackage`
- Win32 Debug/Release compilando

**Corre��es de API Deprecated** - PLANNED

- `{$IFDEF VER210}` / units obsoletas em `Biblioteca.pas`
- Substituir units removidas do Delphi 13

**Smoke Test Cadastros** - PLANNED

- Login ? listar Cliente ? CRUD m�nimo (modo 2 e 3 camadas)

---

## F3 � Core: FireDAC + ORM

**Goal:** Substituir DBExpress por FireDAC em toda a camada de dados  
**Target:** `T2TiORM.pas` e `UDataModuleConexao.pas` funcionando com FireDAC

### Features

**UDataModuleConexao ? FireDAC** - PLANNED

- `TSQLConnection` ? `TFDConnection`
- Drivers nativos: MySQL (`FDPhysMySQLDriverLink`), PostgreSQL (`FDPhysPgDriverLink`)
- Remover Devart `dbexppgsql40.dll`

**T2TiORM adaptado para FireDAC** - PLANNED

- Substituir `TDBXCommand`/`TSQLQuery` por `TFDQuery`/`TFDCommand`
- Manter interface p�blica do ORM (minimizar impacto nos 295 controllers)
- Config via `{SGBD}_FireDAC_conn.ini` (substituir `*_DBExpress_conn.txt`)

**Eliminar DBExpress dos .dproj** - PLANNED

- Remover `dbexpress`, `Dbx*` packages
- Atualizar `Cliente/NFC-e Mobile/Util/T2TiORM.pas` fork

**Gate:** Servidor + Cadastros + Vendas compilam com FireDAC

---

## F4 � UI Nativa (eliminar JVCL)

**Goal:** Zero depend�ncia JVCL; grids e controles 100% VCL  
**Target:** Pacotes `Jv*` removidos de todos os `.dproj`

### Features

**Substituir JvDBUltimGrid** - PLANNED

- `Comum/Biblioteca.pas` � helpers de grid
- `Cliente/Comum/Tela/UBase.pas`, `UTela.pas`, `UFiltro.pas`, `ULookup.pas`
- Avaliar `TDBGrid` + `TStringGrid` nativo ou `TVirtualStringGrid` (se aceito como nativo VCL enhancement)

**Remover demais Jv*** - PLANNED

- JvAppFrm, JvDocking, etc. nos menus (`UMenu.pas`)
- Refatorar telas que usam recursos JVCL espec�ficos

**Substituir FastReport (3 usos diretos)** - PLANNED

- `UNFe.pas`, `UEtiquetaTemplate.pas` � QuickReport nativo ou export PDF
- Migrar `.fr3` ? `.qrp` ou template equivalente

**Gate:** M�dulo piloto + 3 m�dulos operacionais sem JVCL no `.dproj`

---

## F5 � Servidor DataSnap

**Goal:** Servidor compila e responde em D13 com FireDAC  
**Target:** `T2Ti_ServidorAplicacao.dpr` operacional na porta 8080

### Features

**Upgrade ServerContainer + Controller** - PLANNED

- DataSnap D13: verificar `RESTContext`, transporte HTTP
- `DBXJSON` ? `System.JSON` no dispatcher
- Remover FastMM4 (memory manager nativo)

**Sess�o e Auth** - PLANNED

- Revisar `SessaoUsuario.pas` (servidor e cliente)
- Aproveitar migra��o para corrigir MD5 (side benefit)

**Gate:** Cliente Cadastros em Camadas=3 conecta e executa CRUD via HTTP

---

## F6 � M�dulos Operacionais (sem fiscal)

**Goal:** Migrar todos os m�dulos n�o-fiscais  
**Target:** 25+ EXEs compilando em D13

### Ordem sugerida (menor ? maior risco)

1. Agenda, Etiquetas, GED, Comiss�es, Contratos
2. CadastrosM (unificar com Cadastros durante migra��o)
3. Compras, Estoque, Invent�rio, WMS, PCP
4. Vendas, Ordem de Servi�o, Or�amentos
5. Financeiro (7 apps)
6. Folha, Patrim�nio, Ponto (sem ACBr Ponto inicialmente)
7. Contabilidade, Concilia��o Cont�bil, Tributa��o
8. AFV (FMX + FireDAC � j� parcialmente moderno)
9. NFC-e Mobile (FMX � fork de VOs a consolidar)

### Features

**Template de Migra��o por M�dulo** - PLANNED

- Checklist replic�vel (`.dproj`, uses, JVCL, DBExpress, smoke)
- Consolidar units duplicadas durante migra��o (`UProduto.pas`, `UMenu.pas`)

**Descontinuar SM/** - PLANNED

- Remover ou arquivar `SM/RESTserver.dpr` (mORMot n�o migrar)

**Gate:** Todos os m�dulos operacionais compilam; smoke por �rea

---

## F7 � M�dulos Fiscais (�ltimo)

**Goal:** NF-e, SPED, Escrita Fiscal, Balc�o PAF funcionais em D13  
**Target:** Emiss�o homologada Sefaz p�s-migra��o

### Pr�-requisito: Decis�o ACBr (context.md)

| Op��o | Descri��o |
|-------|-----------|
| A | Atualizar ACBr para vers�o compat�vel D13 (open source, comunidade ativa) |
| B | Reescrever fiscal com `System.Net.HttpClient` + XML nativo (multi-ano) |
| C | Isolar fiscal em servi�o separado at� decis�o |

### Features

**Upgrade ACBr (se Op��o A)** - PLANNED

- ACBr trunk compat�vel D13; recompilar pacotes
- Atualizar `UDataModuleNFe.pas`, `UDataModuleCTe.pas`, controllers SPED

**Migrar m�dulos fiscais (ordem)** - PLANNED

1. Sped (gera��o arquivo � menor integra��o Sefaz online)
2. Escrita Fiscal, Tributa��o
3. NF-e ? CT-e ? NFS-e
4. BalcaoPAF (unificar `UNFe.pas` antes)
5. eSocial, Ponto/ACBrPonto

**Gate:** NF-e emitida em homologa��o; SPED gerado e validado

---

## F8 � Finaliza��o

**Goal:** Release candidate Retaguarda D13  
**Target:** Deploy documentado

### Features

**Loja Virtual (uniGUI)** - PLANNED / DECIS�O

- Op��o 1: Fora de escopo � descontinuar
- Op��o 2: Reescrever frontend (TMS WEB / outro � avaliar nativo)
- Op��o 3: Manter em XE7 isolado temporariamente

**Win64 (opcional)** - PLANNED

- Habilitar Win64 nos projetos ap�s Win32 est�vel

**Documenta��o final** - PLANNED

- Atualizar `.specs/codebase/STACK.md` para D13
- Guia de build e deploy
- CHANGELOG de breaking changes

---

## Future Considerations

- Win64/ARM nativo (D13 suporta Windows on Arm)
- Substituir DataSnap por RAD Server ou REST puro
- API tipada substituindo dispatcher RTTI
- CI/CD com MSBuild + smoke automatizado
- Consolidar 40 EXEs em menos execut�veis com menu modular

---

## Status Summary

| Fase | Nome | Status |
|------|------|--------|
| F0 | Documenta��o | ? COMPLETE |
| F1 | Prepara��o | ?? IN PROGRESS |
| F2 | Piloto Cadastros | PLANNED |
| F3 | Core FireDAC | PLANNED |
| F4 | UI Nativa | PLANNED |
| F5 | Servidor | PLANNED |
| F6 | Operacionais | PLANNED |
| F7 | Fiscal | PLANNED |
| F8 | Finaliza��o | PLANNED |
