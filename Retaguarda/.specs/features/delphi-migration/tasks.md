# Tasks � Migra��o Delphi 13

**Spec:** `.specs/features/delphi-migration/spec.md`  
**Design:** `.specs/features/delphi-migration/design.md`  
**Status:** F1 em progresso

---

## Execution Plan

```
F1: T1.1 ? T1.2 ? T1.3
F2: T2.1 ? T2.2 ? T2.3 ? T2.4 ? T2.5
F3: T3.1 ? T3.2 ? T3.3 ? T3.4 ? T3.5 ? T3.6  (critical path)
F4: T4.1 ? T4.2 ? T4.3 ? T4.4  (paralelo parcial com F5 ap�s T3.2)
F5: T5.1 ? T5.2 ? T5.3 ? T5.4  (ap�s T3.4)
F6: T6.1 ? T6.2..T6.N  (por m�dulo, template)
F7: BLOCKED at� decis�o ACBr
F8: T8.1 ? T8.2
```

---

## F1 � Prepara��o

### T1.1 � Instalar e documentar RAD Studio 13

**What:** Instalar RAD Studio 13.1 Florence; documentar vers�o, updates, plataformas (Win32/Win64).  
**Where:** `.specs/features/delphi-migration/build-environment.md` (criar)  
**Depends on:** �  
**Done when:** IDE abre; compilador D13 responde; doc criado  
**Gate:** `dcc32 --version` ou equivalente documentado

### T1.2 — Inventário automatizado de pacotes .dproj [P]

**What:** Script extrai `DCC_UsePackage`, categorias e referências em `.pas` de todos `.dproj`  
**Where:** `.specs/features/delphi-migration/scripts/scan_dependencies.py`  
**Depends on:** —  
**Reuses:** `dependency-matrix.md`  
**Done when:** Output CSV/MD com pacote → projeto  
**Gate:** Script executa sem erro; cobre 100% `.dproj`  
**Status:** COMPLETE (2026-05-30) — ver `output/dependency-inventory.md`, `output/project-dependencies.csv`

### T1.3 — Criar branch de migração

**What:** Branch `feature/delphi13-migration`; tag `baseline-xe7-docs`  
**Depends on:** T1.1  
**Done when:** Branch criada; STATE.md atualizado  
**Gate:** `git branch` confirma branch  
**Status:** COMPLETE (2026-06-01) — tag no master; branch ativa; `build.bat` validado (baseline falha até T2.1)

---

## F2 � Piloto Cadastros

### T2.1 � Upgrade .dproj Cadastros para D13

**What:** Abrir `Cliente/Cadastros/T2TiERP_Cadastros.dproj` no D13 Project Upgrade Wizard  
**Where:** `Cliente/Cadastros/T2TiERP_Cadastros.dproj`  
**Depends on:** T1.1, T1.3  
**Done when:** Projeto abre sem erro fatal no IDE  
**Gate:** �

### T2.2 � Remover pacotes obsoletos do .dproj piloto

**What:** Limpar `DCC_UsePackage`: Rave, IntraWeb, paths `RAD Studio\7.0`, pacotes inexistentes D13  
**Where:** `Cliente/Cadastros/T2TiERP_Cadastros.dproj`  
**Depends on:** T2.1  
**Done when:** Lista de pacotes ? apenas VCL + necess�rios D13  
**Gate:** Diff revisado

### T2.3 � Corrigir erros de compila��o Cadastros (uses/API)

**What:** Corrigir units deprecated, `{$IFDEF}` obsoletos em units linkadas  
**Where:** `Cliente/Cadastros/`, `Cliente/Comum/`, `Comum/` (m�nimo necess�rio)  
**Depends on:** T2.2  
**Done when:** Win32 Debug compila (pode ainda usar DBExpress nesta subfase)  
**Gate:** Build OK no IDE

### T2.4 � Smoke test Cadastros Camadas=2

**What:** Executar EXE; login; abrir Cliente; listar/inserir registro teste  
**Where:** `Cliente/Cadastros/Conexao.ini`  
**Depends on:** T2.3  
**Done when:** CRUD m�nimo funciona  
**Gate:** Checklist smoke assinado em task notes

### T2.5 � Documentar li��es do piloto

**What:** Atualizar `STATE.md` com L-NNN; ajustar template F6  
**Depends on:** T2.4  
**Done when:** Li��es documentadas  
**Gate:** �

---

## F3 � FireDAC Core (critical path)

### T3.1 � Criar UDataModuleConexao FireDAC

**What:** Adicionar `TFDConnection`, drivers MySQL+Pg; manter interface `Conectar()`  
**Where:** `Comum/DataModule/UDataModuleConexao.pas/.dfm`  
**Depends on:** T2.5  
**Done when:** Conecta MySQL em app teste isolado  
**Gate:** Connection test OK

### T3.2 � Criar formato MySQL_FireDAC.ini

**What:** Novo formato config; script migra��o de `MySQL_DBExpress_conn.txt`  
**Where:** `Servidor/`, template em `Comum/`  
**Depends on:** T3.1  
**Done when:** Arquivo ini documentado; exemplo no servidor  
**Gate:** �

### T3.3 � Adaptar T2TiORM para TFDQuery

**What:** Substituir TSQLQuery/TDBXCommand por TFDQuery; manter API p�blica  
**Where:** `Comum/T2TiORM.pas`  
**Depends on:** T3.1  
**Done when:** Insert/Select/Update/Delete funcionam em teste  
**Gate:** CRUD 1 entidade (Usuario) OK

### T3.4 � Remover DBExpress de Comum/

**What:** Eliminar `Data.SqlExpr`, `TSQLConnection` de Comum  
**Where:** `Comum/`  
**Depends on:** T3.3  
**Done when:** grep SqlExpr em Comum/ = 0  
**Gate:** Comum compila

### T3.5 � Atualizar NFC-e Mobile ORM fork [P]

**What:** Aplicar mesmas mudan�as em `Cliente/NFC-e Mobile/Util/T2TiORM.pas`  
**Depends on:** T3.3  
**Done when:** Fork sincronizado ou marcado para consolidar F6  
**Gate:** �

### T3.6 � Gate FireDAC: Servidor + Cadastros compilam

**What:** Recompilar piloto + servidor com FireDAC  
**Depends on:** T3.4, T5.1 (parcial)  
**Done when:** Ambos compilam; Cadastros CRUD OK  
**Gate:** Build + smoke

---

## F4 � UI Nativa

### T4.1 � Invent�rio features JVCL usadas

**What:** Grep `Jv` em `.pas`; listar features (sort, filter, etc.) por unit  
**Where:** Output em `delphi-migration/jvcl-feature-map.md`  
**Depends on:** T3.6  
**Done when:** Mapa completo  
**Gate:** �

### T4.2 � Migrar Cliente/Comum/Tela (base)

**What:** UBase, UTela, UFiltro, ULookup, ULogin � JVCL ? VCL  
**Where:** `Cliente/Comum/Tela/`  
**Depends on:** T4.1  
**Done when:** Telas base compilam sem Jv units  
**Gate:** Build OK

### T4.3 � Migrar Comum/Biblioteca.pas grid helpers

**What:** Substituir JvDBUltimGrid helpers  
**Where:** `Comum/Biblioteca.pas`  
**Depends on:** T4.2  
**Done when:** Biblioteca compila sem Jv references  
**Gate:** Build OK

### T4.4 � Remover Jv* de .dproj (todos)

**What:** Iterar 42 `.dproj`; remover pacotes JvCL  
**Depends on:** T4.3  
**Done when:** grep `Jv` em `.dproj` = 0  
**Gate:** Cadastros + Vendas compilam

---

## F5 � Servidor DataSnap

### T5.1 � Upgrade T2Ti_ServidorAplicacao.dproj

**What:** Migrar .dproj servidor para D13  
**Where:** `Servidor/`  
**Depends on:** T3.1  
**Done when:** Projeto abre D13  
**Gate:** �

### T5.2 � Migrar JSON DBXJSON ? System.JSON

**What:** Refatorar `Servidor/Controller.pas`, `Cliente/Comum/Controller.pas`, `JSonVO.pas`  
**Depends on:** T5.1, T3.4  
**Done when:** HTTP round-trip JSON funciona  
**Gate:** Integration smoke Camadas=3

### T5.3 � Remover FastMM4; validar DataSnap HTTP

**What:** `T2Ti_ServidorAplicacao.dpr`; testar porta 8080  
**Depends on:** T5.2  
**Done when:** Servidor responde restT2Ti  
**Gate:** HTTP 200 em endpoint teste

### T5.4 � Revisar auth sess�o (MD5 ? hash seguro)

**What:** Aproveitar migra��o para corrigir auth (spec separada ou inline)  
**Where:** `UsuarioController.pas`, `SessaoUsuario.pas`, `ServerContainer.pas`  
**Depends on:** T5.3  
**Done when:** Login Camadas=3 funciona com novo hash  
**Gate:** Login smoke OK

---

## F6 � M�dulos Operacionais (template por m�dulo)

### T6.1 � Criar checklist template migra��o m�dulo

**What:** Documento replic�vel: .dproj, uses, JVCL, DBExpress, smoke  
**Where:** `.specs/features/delphi-migration/module-checklist.md`  
**Depends on:** T4.4, T5.3  
**Done when:** Template aprovado  
**Gate:** �

### T6.2 � Migrar m�dulo Vendas (refer�ncia operacional)

**What:** Aplicar template; smoke vendas  
**Where:** `Cliente/Vendas/`  
**Depends on:** T6.1  
**Done when:** Vendas compila + smoke  
**Gate:** Build + smoke

### T6.3..T6.N � Migrar demais m�dulos T1/T2

**What:** Um task por m�dulo na ordem do design.md  
**Depends on:** T6.2  
**Done when:** Todos T1/T2 compilam  
**Gate:** Build matrix

### T6.X � Descontinuar SM/

**What:** Arquivar ou remover `SM/RESTserver.dpr`; doc em STATE  
**Depends on:** T6.1  
**Done when:** SM marcado deprecated  
**Gate:** �

---

## F7 � Fiscal (ACBr Trunk2 validado � adaptar codigo T2Ti)

**Pre-requisito:** `acbr-validation.md` � ACBr compila D13; codigo T2Ti precisa adaptacao

### T7.0 � Spike ACBrNFe no D13

**What:** Projeto minimo referenciando `C:\repositorio\ACBr\Fontes\ACBrDFe\ACBrNFe\`  
**Depends on:** F3 parcial  
**Done when:** Spike compila  
**Gate:** Build OK

### T7.1 � Validacao ACBr documentada

**What:** Mapa pacotes XE7?Trunk2  
**Status:** COMPLETE � ver `acbr-validation.md`

### T7.2..T7.8 � Migrar m�dulos fiscais (ordem design.md)

**What:** Sped ? Escrita Fiscal ? NF-e ? CT-e ? NFS-e ? BalcaoPAF ? eSocial ? Ponto  
**Depends on:** T7.1, T6 completo  
**Done when:** Homologa��o Sefaz OK  
**Gate:** NF-e homologa��o

---

## F8 � Finaliza��o

### T8.1 � Marcar Loja Virtual como descontinuada

**What:** Documentar exclusao de `Cliente/Loja Virtual/` do escopo  
**Status:** COMPLETE (2026-05-30)

### T8.2 � Atualizar docs codebase + release notes

**What:** STACK.md, ARCHITECTURE.md, CHANGELOG migra��o  
**Depends on:** F7 completo  
**Done when:** Docs refletem D13  
**Gate:** Review final

---

## Task Status Tracker

| Task | Status | Req-ID |
|------|--------|--------|
| T1.1 | COMPLETE | MIG-001 |
| T1.2 | COMPLETE | MIG-001 |
| T1.3 | COMPLETE | — |
| T2.1�T2.5 | PLANNED | MIG-002 |
| T3.1�T3.6 | PLANNED | MIG-003 |
| T4.1�T4.4 | PLANNED | MIG-005 |
| T5.1�T5.4 | PLANNED | MIG-004 |
| T6.* | PLANNED | MIG-002 |
| T7.* | PLANNED (ACBr validado; codigo T2Ti pendente) | MIG-006 |
| T8.* | PLANNED | � |

---

## Pr�xima a��o imediata

**T2.1** — Upgrade .dproj Cadastros no D13 (fix `true.dpr`); revalidar com `build.bat`
