# Estrat�gia ORM � Dext (substitui FireDAC + T2TiORM legado)

**Decis�o:** AD-010 (2026-06-01)  
**Substitui:** F3 FireDAC em `design.md`

---

## Vis�o em duas camadas

| Camada | Antes | Agora | Evolu��o |
|--------|-------|-------|----------|
| **Acesso a dados (Camadas=2)** | DBExpress + `TT2TiORM` | **Dext** `TDbContext` + `IDbConnection` via `T2TiDbAccess` | RTTI/`TTable` mantidos nos VOs; SQL via driver Dext (FireDAC interno) |
| **API (Camadas=3)** | DataSnap REST | **Dext** `TRestClient` + controllers Dext no servidor | Faixa B do `datasnap-para-dext.md` |

N�o haver� FireDAC exposto no c�digo T2Ti � apenas o stack Dext.

---

## Estado atual (piloto Cadastros)

### Implementado

- `Comum/Dext/T2TiDbContext.pas` � contexto compartilhado
- `Comum/Dext/T2TiDbAccess.pas` � execu��o SQL via `IDbConnection`
- `Comum/DataModule/UDataModuleConexao.pas` � conex�o MySQL via `TDbContextOptions` + ini legado
- `Comum/T2TiORM.pas` � reimplementado sobre Dext (mesma API p�blica `TT2TiORM`)
- `Comum/VO/VO.pas`, `JSonVO.pas`, `Conversor.pas` � `System.JSON` / `REST.Json`

### Pr�ximo (DbSet nativo)

Por m�dulo, migrar entidades cr�ticas para padr�o Dext completo:

```
Entity [Table] ? DbSet no TT2TiDbContext ? Service ? Controller REST
```

**Piloto sugerido:** `Usuario` ? `TUsuarioEntity` + `IUsuarioService` + rota `/api/v1/usuarios`

VOs (`TUsuarioVO`) permanecem na UI; servi�o mapeia Entity ? VO.

---

## Coexist�ncia durante migra��o

1. **Fase bridge (atual):** `TT2TiORM` usa Dext connection + SQL RTTI (424 VOs funcionam sem reescrever)
2. **Fase DbSet:** entidades Dext por dom�nio (Cadastros ? Financeiro ? Fiscal)
3. **Fase API:** servidor DataSnap ? host Dext; clientes `TRestClient`
4. **Retirada:** remover `TT2TiORM` quando �ltimo controller usar DbSet/Service

---

## Mapeamento atributos T2Ti ? Dext

| T2Ti (`Atributos.pas`) | Dext |
|------------------------|------|
| `[TTable('X')]` | `[Table('X')]` |
| `[TId('ID')]` | `[PK, AutoInc]` + `[Column('ID')]` |
| `[TColumn('N')]` | `[Column('N')]` |
| `[TGeneratedValue(sIdentity)]` | `[AutoInc]` |

Gerador futuro: script que l� VOs e produz entities Dext.

---

## Verifica��o

```bat
build.bat Retaguarda\Cliente\Cadastros T2TiERP_Cadastros.dproj Debug Win32
```

Gate F3-Dext: Cadastros compila + login/listagem com MySQL `t2tierp`.
