# Decisoes de Contexto � Migracao Delphi 13

**Feature:** delphi-migration  
**Capturado:** 2026-05-30  
**Atualizado:** 2026-05-30 (confirmacoes do usuario)

---

## Diretriz principal (confirmada)

Migrar o T2Ti ERP Retaguarda de Delphi XE7 para **RAD Studio 13 Florence**, com plano minucioso, funcionalidade preservada, componentes **nativos Embarcadero** onde houver substituto. ACBr e a unica excecao fiscal aceita.

| Item | Valor |
|------|-------|
| Versao alvo | RAD Studio 13 Florence (Studio 37.0, compiler 37.0) |
| Versao origem | Delphi XE7 (`ProjectVersion=15.3`) |
| IDE | Instalada (confirmado pelo usuario) |

---

## Area #1: ACBr � CONFIRMADO

**Decisao:** Opcao A � manter ACBr Trunk2 atualizado, validado localmente.

| Item | Valor |
|------|-------|
| Repositorio | `C:\repositorio\ACBr\` |
| Instalador | ACBrInstall_Trunk2 v3.3.4.10 |
| Compilado D13 | Sim � log 13/04/2026, Win32 success |
| Libs | `C:\repositorio\ACBr\Lib\Delphi\LibD37\Win32\` |
| Validacao | `.specs/features/delphi-migration/acbr-validation.md` |

**Importante:** ACBr compila no D13, mas o **codigo T2Ti precisa adaptacao** (pacotes renomeados, Capicom?OpenSSL, API ACBrNFe evoluiu).

---

## Area #2: Loja Virtual � CONFIRMADO DESCONTINUAR

**Decisao:** Nao trabalhar com Loja Virtual. Modulo `Cliente/Loja Virtual/` **fora de escopo**.

- Nao migrar
- Nao manter em XE7
- Ignorar em scans e roadmap

---

## Area #3: Politica "100% nativo" � CONFIRMADO

| Componente | Acao |
|------------|------|
| DBExpress | Eliminar ? FireDAC |
| Devart / Zeos | Eliminar ? FireDAC |
| JVCL | Eliminar ? VCL nativo |
| FastReport | Eliminar ? DanfeRL/FPDF ACBr ou QuickReport |
| mORMot/SM | Descontinuar |
| DBXJSON | Eliminar ? System.JSON |
| Indy / DataSnap | Manter (Embarcadero) |
| **ACBr** | **Manter** (excecao fiscal � Trunk2 local) |
| **uniGUI / Loja Virtual** | **Descontinuar** |

---

## Respostas confirmadas (2026-05-30)

| # | Pergunta | Resposta |
|---|----------|----------|
| 1 | ACBr | Opcao A � validar Trunk2 em `C:\repositorio\ACBr` |
| 2 | Loja Virtual | Descontinuar |
| 3 | Delphi 13 | Instalado |
| 4 | 100% nativo | ACBr como unica excecao fiscal |

## Pendente

1. Qual modulo e mais critico para o negocio apos Cadastros piloto? (Vendas, NF-e, Financeiro?)

---

## Decisoes registradas

| ID | Decisao | Data |
|----|---------|------|
| DC-001 | Versao alvo = RAD Studio 13 Florence | 2026-05-30 |
| DC-002 | Migracao incremental | 2026-05-30 |
| DC-003 | Modulos fiscais por ultimo (F7) | 2026-05-30 |
| DC-004 | Eliminar JVCL, DBExpress, Zeos, Devart, mORMot | 2026-05-30 |
| DC-005 | Modulo piloto = Cadastros | 2026-05-30 |
| DC-006 | ACBr Trunk2 `C:\repositorio\ACBr` validado D13 | 2026-05-30 |
| DC-007 | Loja Virtual descontinuada | 2026-05-30 |
| DC-008 | RAD Studio 13 Florence instalado | 2026-05-30 |
