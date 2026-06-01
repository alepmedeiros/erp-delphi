# T2Ti ERP 2.0 ? Retaguarda

**Vision:** Migrar o ERP Retaguarda de Delphi XE7 para **RAD Studio 13 Florence**, mantendo funcionalidade, substituindo third-party por **componentes nativos Embarcadero** quando possivel, com plano incremental.

**For:** Equipe que mantem e evolui o T2Ti ERP 2.0.

**Solves:** Obsolescencia XE7/DBExpress/JVCL, risco de incompatibilidade, impossibilidade de usar FireDAC/System.JSON/D13.

## Goals

- Compilar 100% dos modulos Retaguarda em RAD Studio 13 Florence (~42 `.dpr` + servidor)
- Stack nativa: DBExpress?FireDAC, JVCL?VCL, DBXJSON?System.JSON, Zeos/Devart?FireDAC
- ACBr Trunk2 em `C:\repositorio\ACBr\` como unica excecao fiscal (validado D13)
- Smoke test por modulo a cada fase
- Descontinuar Loja Virtual, SM/mORMot

## Tech Stack

### Origem
Delphi XE7, DBExpress, DataSnap, JVCL, ACBr antigo, FastReport, uniGUI (Loja Virtual)

### Destino
RAD Studio 13 Florence (Studio 37.0), FireDAC, DataSnap, VCL nativo, ACBr Trunk2 local

## Politica de Componentes

| Categoria | Politica |
|-----------|----------|
| Embarcadero nativo | FireDAC, VCL, Indy, System.JSON, DataSnap |
| Eliminar | JVCL, Zeos, Devart, FastMM4, mORMot, IntraWeb, FastReport |
| ACBr fiscal | **Manter** ? `C:\repositorio\ACBr\` Trunk2 validado D13 |
| Loja Virtual | **Descontinuada** ? fora de escopo |

## Scope

**Inclui:** Comum/, Servidor/, Cliente/ (exceto Loja Virtual)

**Fora de escopo:**
- `Cliente/Loja Virtual/` ? descontinuado
- `SM/RESTserver.dpr` ? descontinuar
- Frente de Caixa (repo pai)
- Redesign de telas

## Constraints

- Migracao incremental (nunca big bang)
- Modulos fiscais por ultimo (F7) ? adaptar API ACBr T2Ti
- RAD Studio 13 instalado (confirmado)
- Homologacao Sefaz apos migracao fiscal

## References

| Documento | Path |
|-----------|------|
| Spec migracao | `.specs/features/delphi-migration/spec.md` |
| Design | `.specs/features/delphi-migration/design.md` |
| Contexto/decisoes | `.specs/features/delphi-migration/context.md` |
| Ambiente build | `.specs/features/delphi-migration/build-environment.md` |
| Validacao ACBr | `.specs/features/delphi-migration/acbr-validation.md` |
| Tasks | `.specs/features/delphi-migration/tasks.md` |
