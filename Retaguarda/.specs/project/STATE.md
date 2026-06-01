# State

**Last Updated:** 2026-06-01  
**Current Work:** delphi-migration — F1 concluída; F2 piloto Cadastros (T2.1)  
**Branch:** `feature/delphi13-migration`

---

## Recent Decisions (Last 60 days)

### AD-009: build.bat como gate de CI local (2026-06-01)

**Decision:** Usar `build.bat` na raiz do repo para validar compilação via MSBuild + D13.

**Reason:** Produtividade — agente e dev podem rodar build sem abrir IDE.

**Impact:** T2+ usa `build.bat <dir> <dproj>` como gate; baseline Cadastros falha até T2.1 (upgrade .dproj).

### AD-007: ACBr Trunk2 local validado para D13 (2026-05-30)

**Decision:** Usar ACBr em `C:\repositorio\ACBr\` (Trunk2, instalador 3.3.4.10) como camada fiscal na migração.

**Reason:** Usuário confirmou repositório local; log comprova compilação D13 Florence Win32 em 13/04/2026.

**Trade-off:** ACBr continua third-party, mas é a única exceção aceita vs reescrita multi-ano.

**Impact:** F7 desbloqueada condicionalmente; código T2Ti ainda precisa adaptar pacotes/API (ver acbr-validation.md).

### AD-008: Loja Virtual descontinuada (2026-05-30)

**Decision:** `Cliente/Loja Virtual/` fora de escopo total — não migrar.

**Reason:** Diretriz explícita do usuário.

**Impact:** F8 simplificado; uniGUI removido do plano.

### AD-004 a AD-006

Ver histórico anterior — AD-004 (migração D13) e AD-005 (piloto Cadastros) permanecem válidos.

---

## Active Blockers

### B-007: .dproj XE7 incompatível com MSBuild D13 (true.dpr)

**Discovered:** 2026-06-01  
**Impact:** Alto — build.bat falha em projetos não migrados  
**Resolution:** T2.1 — Project Upgrade Wizard ou correção DCC flags  
**Workaround:** Compilar via IDE até upgrade

### B-001: Código T2Ti usa pacotes ACBr legados — RESOLVIDO PARCIALMENTE

**Status:** ACBr D13 OK; adaptação código T2Ti pendente (F7)  
**Resolution:** Mapa em acbr-validation.md (`ACBr_NFe2`→`ACBr_NFe`, etc.)

### B-003: Zero testes automatizados

**Impact:** Alto — regressão na migração  
**Resolution:** Smoke manual por fase; DUnitX a partir de F3

### B-006: Gap API ACBr XE7→Trunk2

**Discovered:** 2026-05-30  
**Impact:** Médio-Alto — UNFe.pas e UDataModule.pas precisam refatoração fiscal  
**Workaround:** Spike ACBr antes de portar módulos fiscais  
**Resolution:** Tasks V1–V6 em acbr-validation.md

---

## Resolved Blockers

| ID | Blocker | Resolução |
|----|---------|-----------|
| B-004 | Decisão ACBr | AD-007 — Trunk2 local |
| B-005 | Loja Virtual | AD-008 — descontinuar |
| B-002 | D13 não instalado | Usuário confirmou instalado |

---

## Lessons Learned

### L-004: build.bat expõe incompatibilidade .dproj antes do IDE

**Context:** Primeiro build Cadastros via MSBuild D13  
**Problem:** `DCC_DebugInformation>true` gera `true.dpr` no dcc32  
**Solution:** Upgrade .dproj no D13 (T2.1)  
**Prevents:** Perder tempo debugando units quando o problema é metadata MSBuild

### L-003: ACBr Trunk2 já compilou no D13 local — gap é no código T2Ti, não no ACBr

**Context:** Validação em `C:\repositorio\ACBr\log_Delphi_13_Florence_Win32.txt`  
**Problem:** Assumir incompatibilidade ACBr+D13  
**Solution:** Separar "ACBr compila" de "T2Ti adapta API"  
**Prevents:** Bloquear F1-F6 desnecessariamente

---

## Quick Tasks Completed

| #   | Description                              | Date       | Status  |
| --- | ---------------------------------------- | ---------- | ------- |
| 001 | Brownfield mapping                       | 2026-05-30 | Done |
| 002 | Project initialization                   | 2026-05-30 | Done |
| 003 | Realinhamento migração Delphi 13         | 2026-05-30 | Done |
| 004 | Feature spec/design/tasks                | 2026-05-30 | Done |
| 005 | Validação ACBr D13 + build-environment   | 2026-05-30 | Done |
| 006 | Confirmações usuário (ACBr/LV/D13)         | 2026-05-30 | Done |
| 007 | T1.2 inventário dependências (43 dproj)  | 2026-05-30 | Done |
| 008 | T1.3 branch + build.bat baseline         | 2026-06-01 | Done |

---

## Todos

- [ ] Executar T2.1 — upgrade .dproj Cadastros no D13 (fix true.dpr)
- [ ] Revalidar build.bat após T2.1
- [ ] Usuário: informar módulo mais crítico pós-Cadastros
- [ ] Spike ACBr V2 — projeto teste NF-e (antes de F7)

---

## Preferences

**Model Guidance Shown:** never
