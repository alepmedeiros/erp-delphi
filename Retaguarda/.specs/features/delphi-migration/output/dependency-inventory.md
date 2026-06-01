# Inventário de Dependências — Retaguarda T2Ti ERP

**Gerado:** 2026-05-30  
**Req-ID:** MIG-001 / T1.2  
**Script:** `.specs/features/delphi-migration/scripts/scan_dependencies.py`  
**Baseline:** Delphi XE7 (ProjectVersion 15.3) ? Target RAD Studio 13 Florence

---

## Resumo executivo

| Métrica | Valor |
|---------|-------|
| Projetos `.dproj` | **43** |
| Apps cliente VCL | **39** |
| Apps FMX (híbridos) | **3** (AFV, PCP, NFC-e Mobile) |
| Servidor | **1** (`Servidor/T2Ti_ServidorAplicacao.dproj`) |
| Protótipo descontinuar | **1** (`SM/RESTserver.dproj`) |
| Com `DCC_UsePackage` explícito | **4** (AFV, PCP, Ponto Eletrônico, ACBr_Ponto) |
| Referência Dext no código | **0** (migração ainda não iniciada) |

**Conclusão para migração gradativa:** viável. Cada módulo é um `.dpr` independente; `Comum/` é o caminho crítico compartilhado (ORM + controllers). A API pode migrar para **Dext** no servidor enquanto clientes legados coexistem até trocar `Cliente/Comum/Controller.pas` por `TRestClient`.

---

## Resumo por categoria

| Categoria | Projetos (.dproj) | Arquivos (.pas) | Ação sugerida | Fase |
|-----------|-------------------|-----------------|---------------|------|
| **DataSnap** (namespace) | 43 | 42 (DSHTTP/DBXJSON) | **Dext API** + `TRestClient` no cliente | F5?Dext |
| **DBExpress** | 43 (namespace) | 4 (`Data.SqlExpr` direto) | **FireDAC** via `T2TiORM` | F3 |
| **BDE** (namespace legado) | 43 | — | Remover do namespace | F2 |
| **JVCL** (`JvDBUltimGrid` etc.) | 3 explícitos; ~300 telas no código | ~300 | VCL nativo / Skia (gradual por módulo) | F4 |
| **ACBr** | 14 | 8+ (`ACBrNFe` pesado) | ACBr Trunk2 D13 | F7 |
| **FastReport** (`frx*`) | 2 (AFV, PCP) | 3 (`frxClass`) | QuickReport / PDF | F4/F7 |
| **Zeos** | 1 (AFV) | — | FireDAC | F6 |
| **FireDAC** | 2 (AFV, PCP) | parcial | Expandir (substituir DBExpress) | F3 |
| **Indy** | 4+ (pacotes explícitos) | sessão HTTP | Manter | — |
| **TeeChart** | 4 | — | Verificar licença D13 | F2 |
| **IntraWeb / Rave** | 4 (legado XE) | — | Eliminar | F2/F8 |
| **mORMot/Synopse** | 1 (SM/) | — | Descontinuar | F6 |
| **FMX** | 3 | NFC-e Mobile fork | Migrar .dproj D13 | F6 |
| **REST Components** | 1 (AFV) | — | Alinhar com Dext client | F6 |

---

## Projetos com pacotes third-party explícitos (`DCC_UsePackage`)

Estes 4 projetos carregam listas extensas de pacotes XE7 — prioridade alta na limpeza do `.dproj`:

| Projeto | Pacotes notáveis |
|---------|------------------|
| `Cliente/AFV/T2TiERPAFV.dproj` | FireDAC, Zeos, JVCL, ACBr*, FastReport, DataSnap, REST, FMX, CodeSite |
| `Cliente/PCP/T2TiERP_PCP.dproj` | FireDAC, JVCL, ACBr*, FastReport, DataSnap, FMX, CodeSite |
| `Cliente/Ponto/Ponto Eletronico/T2TiERPPontoEletronico.dproj` | JVCL completo, ACBr*, Rave, IntraWeb, DBExpress |
| `Cliente/Ponto/ACBrPonto/ACBr_Ponto.dproj` | ACBr Ponto, Rave, IntraWeb (legado) |

---

## Projetos sem `DCC_UsePackage` explícito (39)

Dependem de `DCCReference` + namespace VCL/DataSnap. Pacotes third-party entram via **units no uses** (principalmente JVCL em telas).

Incluem todos os módulos operacionais padrão: Cadastros, Vendas, Financeiro (7 apps), NF-e, CT-e, etc.

---

## Referências em código-fonte (.pas)

| Padrão | Arquivos | Impacto |
|--------|----------|---------|
| `JvDBUltimGrid` | **~300** | F4 — base em `Comum/Biblioteca.pas` + telas |
| `DSHTTP` / `DBXJSON` | **42** | F5?Dext — proxy cliente + servidor |
| `ACBrNFe` | **8** (NF-e, Balcão, Estoque, NFC-e Mobile) | F7 — fiscal crítico |
| `Data.SqlExpr` | **4** (Comum conexão + Loja Virtual) | F3 — FireDAC |
| `frxClass` | **3** (NF-e, Etiquetas, Balcão) | F4 — relatórios |
| `Dext.Net` | **0** | F5 — destino da migração REST |

---

## Tier de complexidade (para ordem gradativa F6)

| Tier | Módulos | Critério |
|------|---------|----------|
| **T1 — Piloto** | Cadastros, Agenda, Etiquetas, GED, Inventário | CRUD puro, sem ACBr |
| **T2 — Operacional** | Vendas, Compras, Estoque, Financeiro×7, Contratos, WMS | CRUD + grids JVCL |
| **T3 — Híbrido** | AFV, PCP, NFC-e Mobile | FMX + pacotes mistos |
| **T4 — Fiscal** | NF-e, CT-e, NFS-e, Sped, eSocial, Balcão, Ponto | ACBr pesado |
| **Descartar** | Loja Virtual, SM/ | IntraWeb / mORMot |

---

## Caminho crítico compartilhado

```
Comum/T2TiORM.pas          ? FireDAC (F3)
Comum/Biblioteca.pas       ? JVCL ? VCL/Skia (F4)
Servidor/Controller.pas    ? DataSnap ? Dext (F5)
Cliente/Comum/Controller.pas ? ExecutarMetodo ? TRestClient (F5)
```

Módulos individuais podem migrar **UI e .dproj** em paralelo após F3+F5 estabilizarem o core.

---

## Próxima ação

**T1.3** — criar branch `feature/delphi13-migration` (se autorizado)  
**T2.1** — piloto `Cliente/Cadastros/T2TiERP_Cadastros.dproj` no D13
