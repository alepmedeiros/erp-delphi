# Testing Infrastructure

## Test Frameworks

**Unit/Integration:** Nenhum detectado  
**E2E:** Nenhum detectado  
**Coverage:** Nenhuma ferramenta configurada

## Test Organization

**Location:** N�o h� pasta `Tests/`, `Test/` ou projetos `*Test*.dpr`  
**Naming:** Arquivos com "Teste" no nome s�o **dados manuais**, n�o testes automatizados:
- `Cliente/Ponto/Ponto Eletronico/AFDTeste*.txt`
- `Cliente/GED/Arquivos para Teste/CartoesParaTeste.txt`
- `Cliente/BalcaoPAF/XML/teste-nfe-para-importacao-janela-entrada-nf-NFe.xml`

**Structure:** Inexistente

## Testing Patterns

### Unit Tests

**Approach:** Ausente  
**Location:** �  
Nenhum uso de DUnit, DUnitX ou TestCase encontrado em `.pas`/`.dpr`.

### Integration Tests

**Approach:** Ausente  
**Location:** �  
Sem testes de integra��o com banco ou DataSnap.

### E2E Tests

**Approach:** Ausente  
**Location:** �  
Valida��o manual via execu��o dos EXEs e arquivos de amostra fiscal.

## Test Execution

**Commands:** Nenhum comando documentado ou script de teste no reposit�rio  
**Configuration:** Nenhuma

## Coverage Targets

**Current:** 0% automatizado (estimativa por aus�ncia de infraestrutura)  
**Goals:** N�o documentadas no c�digo  
**Enforcement:** Nenhuma

## Test Coverage Matrix

| Code Layer | Required Test Type | Location Pattern | Run Command |
|------------|-------------------|------------------|-------------|
| ORM (`T2TiORM.pas`) | unit (recomendado) | `Comum/T2TiORM.pas` | � (n�o existe) |
| Controllers | unit + integration | `Comum/Controller/*Controller.pas` | � |
| Dispatcher DataSnap | integration | `Servidor/Controller.pas` | � |
| Proxy cliente HTTP | integration | `Cliente/Comum/Controller.pas` | � |
| VOs / serializa��o JSON | unit | `Comum/VO/*.pas` | � |
| Telas VCL | manual / e2e | `Cliente/*/Tela/*.pas` | � |
| Fiscal ACBr | integration + manual | `Cliente/NF-e/`, `Comum/Controller/Nfe*` | � |
| SPED generation | integration | `Comum/Controller/SpedFiscalController.pas` | � |
| Servidor app | smoke manual | `Servidor/T2Ti_ServidorAplicacao.dpr` | compilar + subir :8080 |
| REST mORMot | smoke manual | `SM/RESTserver.dpr` | compilar + subir :888 |

## Parallelism Assessment

| Test Type | Parallel-Safe? | Isolation Model | Evidence |
|-----------|----------------|-----------------|----------|
| Unit (futuro) | Sim (potencial) | Mock de `TSQLConnection` / controllers | Sem testes hoje |
| Integration DB | N�o (futuro) | Conex�o global `Conexao` em `T2TiORM.pas` | Singleton compartilhado |
| DataSnap | N�o (futuro) | Servidor �nico :8080, sess�es globais | `TListaSessaoUsuario.Instance` |
| E2E | N�o | EXE + servidor + DB real | Arquitetura acoplada |

## Gate Check Commands

| Gate Level | When to Use | Command |
|------------|-------------|---------|
| Quick | Ap�s altera��o em unit isolada | Compilar m�dulo afetado na IDE (sem testes) |
| Full | Ap�s altera��o em `Comum/` ou `Servidor/` | Compilar `T2Ti_ServidorAplicacao.dpr` + 1 cliente representativo |
| Build | Ap�s release de m�dulo | Compilar `.dpr` do m�dulo + smoke manual do fluxo principal |
| Lint | � | Nenhum linter/formatter configurado no repo |

## Recomenda��es para introdu��o de testes

Prioridade sugerida (fora do escopo deste mapeamento):

1. **DUnitX** em `Comum/Controller/UsuarioController.pas` e `NfeCabecalhoController.pas`
2. **Testes de ORM** com banco em mem�ria ou fixture MySQL dedicado
3. **Smoke script** PowerShell: compila servidor + ping HTTP `restT2Ti/TController/`
4. **CI** (GitHub Actions self-hosted Windows) apenas ap�s extrair build reproduc�vel

Ver gaps detalhados em `CONCERNS.md` ? Test Coverage Gaps.
