# Invent�rio de Depend�ncias � Retaguarda T2Ti ERP

**Gerado:** 2026-05-30  
**Req-ID:** MIG-001 / T1.2  
**Script:** `.specs/features/delphi-migration/scripts/scan_dependencies.py`  
**Baseline:** Delphi XE7 (ProjectVersion 15.3) ? Target RAD Studio 13 Florence

---

## Resumo executivo

| M�trica | Valor |
|---------|-------|
| Projetos `.dproj` | **43** |
| Apps cliente VCL | **39** |
| Apps FMX (h�bridos) | **3** (AFV, PCP, NFC-e Mobile) |
| Servidor | **1** (`Servidor/T2Ti_ServidorAplicacao.dproj`) |
| Prot�tipo descontinuar | **1** (`SM/RESTserver.dproj`) |
| Com `DCC_UsePackage` expl�cito | **4** (AFV, PCP, Ponto Eletr�nico, ACBr_Ponto) |
| Refer�ncia Dext no c�digo | **0** (migra��o ainda n�o iniciada) |

**Conclus�o para migra��o gradativa:** vi�vel. Cada m�dulo � um `.dpr` independente; `Comum/` � o caminho cr�tico compartilhado (ORM + controllers). A API pode migrar para **Dext** no servidor enquanto clientes legados coexistem at� trocar `Cliente/Comum/Controller.pas` por `TRestClient`.

---

## Resumo por categoria

| Categoria | Projetos (.dproj) | Arquivos (.pas) | A��o sugerida | Fase |
|-----------|-------------------|-----------------|---------------|------|
| **DataSnap** (namespace) | 43 | 42 (DSHTTP/DBXJSON) | **Dext API** + `TRestClient` no cliente | F5?Dext |
| **DBExpress** | 43 (namespace) | 4 (`Data.SqlExpr` direto) | **FireDAC** via `T2TiORM` | F3 |
| **BDE** (namespace legado) | 43 | � | Remover do namespace | F2 |
| **JVCL** (`JvDBUltimGrid` etc.) | 3 expl�citos; ~300 telas no c�digo | ~300 | VCL nativo / Skia (gradual por m�dulo) | F4 |
| **ACBr** | 14 | 8+ (`ACBrNFe` pesado) | ACBr Trunk2 D13 | F7 |
| **FastReport** (`frx*`) | 2 (AFV, PCP) | 3 (`frxClass`) | QuickReport / PDF | F4/F7 |
| **Zeos** | 1 (AFV) | � | FireDAC | F6 |
| **FireDAC** | 2 (AFV, PCP) | parcial | Expandir (substituir DBExpress) | F3 |
| **Indy** | 4+ (pacotes expl�citos) | sess�o HTTP | Manter | � |
| **TeeChart** | 4 | � | Verificar licen�a D13 | F2 |
| **IntraWeb / Rave** | 4 (legado XE) | � | Eliminar | F2/F8 |
| **mORMot/Synopse** | 1 (SM/) | � | Descontinuar | F6 |
| **FMX** | 3 | NFC-e Mobile fork | Migrar .dproj D13 | F6 |
| **REST Components** | 1 (AFV) | � | Alinhar com Dext client | F6 |

---

## Projetos com pacotes third-party expl�citos (`DCC_UsePackage`)

Estes 4 projetos carregam listas extensas de pacotes XE7 � prioridade alta na limpeza do `.dproj`:

| Projeto | Pacotes not�veis |
|---------|------------------|
| `Cliente/AFV/T2TiERPAFV.dproj` | FireDAC, Zeos, JVCL, ACBr*, FastReport, DataSnap, REST, FMX, CodeSite |
| `Cliente/PCP/T2TiERP_PCP.dproj` | FireDAC, JVCL, ACBr*, FastReport, DataSnap, FMX, CodeSite |
| `Cliente/Ponto/Ponto Eletronico/T2TiERPPontoEletronico.dproj` | JVCL completo, ACBr*, Rave, IntraWeb, DBExpress |
| `Cliente/Ponto/ACBrPonto/ACBr_Ponto.dproj` | ACBr Ponto, Rave, IntraWeb (legado) |

---

## Projetos sem `DCC_UsePackage` expl�cito (39)

Dependem de `DCCReference` + namespace VCL/DataSnap. Pacotes third-party entram via **units no uses** (principalmente JVCL em telas).

Incluem todos os m�dulos operacionais padr�o: Cadastros, Vendas, Financeiro (7 apps), NF-e, CT-e, etc.

---

## Refer�ncias em c�digo-fonte (.pas)

| Padr�o | Arquivos | Impacto |
|--------|----------|---------|
| `JvDBUltimGrid` | **~300** | F4 � base em `Comum/Biblioteca.pas` + telas |
| `DSHTTP` / `DBXJSON` | **42** | F5?Dext � proxy cliente + servidor |
| `ACBrNFe` | **8** (NF-e, Balc�o, Estoque, NFC-e Mobile) | F7 � fiscal cr�tico |
| `Data.SqlExpr` | **4** (Comum conex�o + Loja Virtual) | F3 � FireDAC |
| `frxClass` | **3** (NF-e, Etiquetas, Balc�o) | F4 � relat�rios |
| `Dext.Net` | **0** | F5 � destino da migra��o REST |

---

## Tier de complexidade (para ordem gradativa F6)

| Tier | M�dulos | Crit�rio |
|------|---------|----------|
| **T1 � Piloto** | Cadastros, Agenda, Etiquetas, GED, Invent�rio | CRUD puro, sem ACBr |
| **T2 � Operacional** | Vendas, Compras, Estoque, Financeiro�7, Contratos, WMS | CRUD + grids JVCL |
| **T3 � H�brido** | AFV, PCP, NFC-e Mobile | FMX + pacotes mistos |
| **T4 � Fiscal** | NF-e, CT-e, NFS-e, Sped, eSocial, Balc�o, Ponto | ACBr pesado |
| **Descartar** | Loja Virtual, SM/ | IntraWeb / mORMot |

---

## Caminho cr�tico compartilhado

```
Comum/T2TiORM.pas          ? FireDAC (F3)
Comum/Biblioteca.pas       ? JVCL ? VCL/Skia (F4)
Servidor/Controller.pas    ? DataSnap ? Dext (F5)
Cliente/Comum/Controller.pas ? ExecutarMetodo ? TRestClient (F5)
```

M�dulos individuais podem migrar **UI e .dproj** em paralelo ap�s F3+F5 estabilizarem o core.

---

## Pr�xima a��o

**T1.3** � criar branch `feature/delphi13-migration` (se autorizado)  
**T2.1** � piloto `Cliente/Cadastros/T2TiERP_Cadastros.dproj` no D13
