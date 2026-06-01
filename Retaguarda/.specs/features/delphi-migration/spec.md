# Migra��o Delphi XE7 ? RAD Studio 13 Florence

## Problem Statement

O T2Ti ERP Retaguarda foi desenvolvido em **Delphi XE7** (~2014) com **DBExpress** (deprecated), **JVCL**, **ACBr** e dezenas de depend�ncias third-party. A vers�o atual do Delphi (**13 Florence**) n�o suporta compilar projetos XE7 sem migra��o sistem�tica. Componentes third-party antigos (JVCL, Zeos, Devart) podem n�o ter compatibilidade com Delphi 13, enquanto a diretriz do projeto exige **componentes nativos Embarcadero** para garantir longevidade.

## Goals

- [ ] Compilar 100% dos m�dulos Retaguarda em RAD Studio 13 Florence
- [ ] Substituir DBExpress, JVCL, Zeos, Devart, FastReport, mORMot por equivalentes nativos
- [ ] Manter funcionalidade equivalente validada por smoke test por m�dulo
- [ ] Documentar matriz de depend�ncias e plano revers�vel fase a fase

## Out of Scope

| Feature | Reason |
|---------|--------|
| Redesign de UI/UX | Migra��o t�cnica, n�o produto |
| Frente de Caixa (repo pai) | Fora de `Retaguarda/` |
| Regras fiscais novas | Apenas compatibilidade t�cnica |
| Loja Virtual uniGUI v1 | Decis�o pendente � ver `context.md` |
| SM/mORMot | Descontinuar |

---

## User Stories

### P1: Invent�rio completo de depend�ncias ? MVP

**User Story**: Como desenvolvedor, quero um invent�rio de todas as depend�ncias third-party por m�dulo, para priorizar substitui��es nativas.

**Why P1**: Sem invent�rio, a migra��o � adivinha��o.

**Acceptance Criteria**:

1. WHEN o invent�rio for gerado THEN SHALL listar cada pacote third-party com m�dulos afetados e substituto nativo proposto
2. WHEN uma depend�ncia n�o tiver substituto nativo THEN SHALL estar marcada como DECIS�O PENDENTE com op��es documentadas
3. WHEN o invent�rio for revisado THEN SHALL cobrir 100% dos `.dproj` em `Retaguarda/`

**Req-ID:** MIG-001

---

### P1: M�dulo piloto Cadastros compila em D13 ? MVP

**User Story**: Como desenvolvedor, quero migrar o m�dulo Cadastros como piloto, para validar o pipeline antes de tocar no core.

**Why P1**: Prova o processo com menor risco (sem ACBr, CRUD simples).

**Acceptance Criteria**:

1. WHEN `T2TiERP_Cadastros.dpr` for aberto no D13 THEN SHALL compilar Win32 Debug sem erros
2. WHEN executado em Camadas=2 THEN SHALL conectar ao banco e listar cadastro (ex.: Cliente)
3. WHEN o `.dproj` piloto for migrado THEN SHALL n�o conter pacotes JVCL, Zeos, Devart no `DCC_UsePackage`

**Req-ID:** MIG-002

---

### P1: ORM migrado para FireDAC ? MVP

**User Story**: Como desenvolvedor, quero que `T2TiORM` use FireDAC, para eliminar DBExpress de toda a aplica��o.

**Why P1**: DBExpress � o blocker central � todos os 295 controllers dependem do ORM.

**Acceptance Criteria**:

1. WHEN `UDataModuleConexao` usar FireDAC THEN SHALL conectar MySQL e PostgreSQL com drivers nativos Embarcadero
2. WHEN `T2TiORM` executar CRUD THEN SHALL manter compatibilidade com assinaturas existentes dos controllers
3. WHEN a migra��o FireDAC estiver completa THEN SHALL zero refer�ncias a `Data.SqlExpr`, `TSQLConnection`, `TSQLQuery` em `Comum/`

**Req-ID:** MIG-003

---

### P2: Servidor DataSnap operacional em D13

**User Story**: Como operador, quero o servidor de aplica��o rodando em D13 na porta 8080, para clientes em Camadas=3.

**Acceptance Criteria**:

1. WHEN `T2Ti_ServidorAplicacao.dpr` compilar THEN SHALL responder HTTP em `/datasnap/restT2Ti/TController/ObjetoJson/`
2. WHEN cliente Cadastros autenticar THEN SHALL executar CRUD via HTTP
3. WHEN JSON for serializado THEN SHALL usar `System.JSON` (n�o DBXJSON)

**Req-ID:** MIG-004

---

### P2: Eliminar JVCL de todos os m�dulos

**User Story**: Como desenvolvedor, quero grids e controles 100% VCL nativo, eliminando risco de incompatibilidade JVCL.

**Acceptance Criteria**:

1. WHEN buscar `Jv` nos `.dproj` THEN SHALL retornar zero pacotes `Jv*` em `DCC_UsePackage`
2. WHEN telas base (`UBase`, `UTela`) forem migradas THEN SHALL grids funcionar com VCL nativo
3. WHEN `Biblioteca.pas` for atualizado THEN SHALL helpers de grid n�o depender de JVCL

**Req-ID:** MIG-005

---

### P3: M�dulos fiscais migrados (p�s-decis�o ACBr)

**User Story**: Como emitente fiscal, quero emitir NF-e em homologa��o ap�s migra��o, com mesma funcionalidade.

**Acceptance Criteria**:

1. WHEN decis�o ACBr for confirmada (context.md) THEN SHALL seguir plano da op��o escolhida
2. WHEN NF-e for emitida em homologa��o THEN SHALL autoriza��o Sefaz retornar sucesso
3. WHEN SPED for gerado THEN SHALL passar validador SPED

**Req-ID:** MIG-006  
**Blocked by:** Decis�o ACBr em `context.md`

---

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-001 | Cada fase SHALL ter gate: compila��o Win32 Debug + smoke manual documentado |
| NFR-002 | Nenhuma fase SHALL mergear sem rollback plan (tag git por fase) |
| NFR-003 | Paths hardcoded XE7 (`RAD Studio\7.0\Bpl\`) SHALL ser removidos dos `.dproj` |
| NFR-004 | Config de conex�o SHALL usar arquivos locais n�o versionados |

## Traceability

| Req-ID | Fase Roadmap | Tasks |
|--------|--------------|-------|
| MIG-001 | F1 | T1.1�T1.3 |
| MIG-002 | F2 | T2.1�T2.5 |
| MIG-003 | F3 | T3.1�T3.6 |
| MIG-004 | F5 | T5.1�T5.4 |
| MIG-005 | F4 | T4.1�T4.4 |
| MIG-006 | F7 | T7.1�T7.8 (blocked) |
