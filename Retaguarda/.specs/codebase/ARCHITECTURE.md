# Architecture

**Padr�o:** Mon�lito modular � m�ltiplos execut�veis VCL + um servidor DataSnap central + biblioteca de dom�nio compartilhada

## High-Level Structure

```
???????????????????????????????????????????????????????????????
?  Cliente/  (~40 EXEs: Vendas, NF-e, Financeiro, Folha...)   ?
?  Cliente/Comum/  (proxy HTTP, sess�o, telas base)           ?
???????????????????????????????????????????????????????????????
                           ? HTTP JSON (Camadas=3)
                           ? ou RTTI local + DB (Camadas=2)
???????????????????????????????????????????????????????????????
?  Servidor/T2Ti_ServidorAplicacao  (DataSnap :8080)          ?
?  Servidor/Controller.pas  ?  Comum/Controller/* (295 units) ?
???????????????????????????????????????????????????????????????
                           ? T2TiORM + DBExpress
???????????????????????????????????????????????????????????????
?  Banco de dados (MySQL default, Postgres, Firebird, etc.)   ?
???????????????????????????????????????????????????????????????

Paralelo (n�o integrado): SM/RESTserver.dpr (mORMot REST :888)
```

## Identified Patterns

### Dispatcher gen�rico via RTTI

**Location:** `Servidor/Controller.pas`, `Cliente/Comum/Controller.pas`  
**Purpose:** Um �nico endpoint DataSnap atende centenas de controllers sem expor m�todo por m�todo  
**Implementation:** `$METHODINFO ON` + m�todos `ObjetoJson`, `AcceptObjetoJson`, `UpdateObjetoJson`, `CancelObjetoJson`; cliente chama `ExecutarMetodo`, `BuscarLista`, `BuscarObjeto` via HTTP  
**Example:** URL montada em `Cliente/Comum/SessaoUsuario.pas` linha 78:
`http://{host}:{porta}/datasnap/restT2Ti/TController/ObjetoJson/`

### ORM customizado com annotations

**Location:** `Comum/T2TiORM.pas`, `Comum/Atributos.pas`, `Comum/VO/*.pas`  
**Purpose:** Mapear entidades Pascal para tabelas SQL via RTTI  
**Implementation:** Atributos `[TEntity]`, `[TTable('USUARIO')]`, `[TColumn]` em VOs; CRUD via `TSQLConnection`/`TDBXCommand`  
**Example:** `Comum/VO/UsuarioVO.pas` � `TUsuarioVO = class(TVO)` com `[TTable('USUARIO')]`

### Controller por entidade de dom�nio

**Location:** `Comum/Controller/*Controller.pas` (295 units)  
**Purpose:** Regras de neg�cio + acesso a dados por tabela/agregado  
**Implementation:** Herda `TController`; m�todos de classe `Consulta`, `Inserir`, `Alterar`, `Excluir`; retorno via `TClientDataSet` ou JSON  
**Example:** `Comum/Controller/UsuarioController.pas` � `class procedure Usuario(pLogin, pSenha: String)`

### Modo 2 vs 3 camadas

**Location:** `Cliente/Comum/SessaoUsuario.pas`, `Conexao.ini`  
**Purpose:** Permitir opera��o local (dev/demos) ou cliente-servidor (produ��o)  
**Implementation:** `Camadas=2` cria `TFDataModuleConexao` local; `Camadas=3` usa proxy HTTP DataSnap  
**Example:** `Cliente/Vendas/Conexao.ini` � `[ServidorApp] Camadas=2`

### Singleton de sess�o

**Location:** `Cliente/Comum/SessaoUsuario.pas`, `Servidor/SessaoUsuario.pas`  
**Purpose:** Manter usu�rio autenticado, permiss�es e cliente HTTP  
**Implementation:** `class function Instance: TSessaoUsuario`; lista de permiss�es `TFuncaoVO`  
**Example:** `AutenticaUsuario` ? MD5 hash ? HTTP Basic ? `UsuarioController.Usuario`

## Data Flow

### Autentica��o e permiss�es

```
ULogin.pas
  ? TSessaoUsuario.AutenticaUsuario(login, senha)
    ? MD5(login+senha) via UsuarioController.CriptografarLoginSenha
    ? HTTP Basic (user=login|idSessao, pass=hash)
    ? UsuarioController.Usuario (DataSnap ou local)
  ? AtualizaPermissoes ? FuncaoController
  ? TemAcesso(formulario, nome) antes de abrir telas
```

### CRUD gen�rico (3 camadas)

```
Form/Tela (*.pas)
  ? *Controller.Consulta/Inserir/Alterar (Cliente/Comum/Controller.pas)
    ? HTTP GET/POST/PUT/DELETE ? DataSnap
      ? Servidor/Controller.pas (RTTI dispatch)
        ? Comum/Controller/*Controller.pas
          ? T2TiORM ? TSQLConnection ? DB
    ? TratarRetorno ? TClientDataSet / JSON ? UI
```

### Emiss�o fiscal (NF-e)

```
UNFe.pas (Cliente/NF-e/Tela/)
  ? NfeCabecalhoController / NFeCalculoController (Comum/Controller/)
  ? ACBr NFe (UDataModuleNFe.pas)
  ? Webservices Sefaz (ACBrNFe.WebServices.*)
  ? DANFe FastReport ou ACBr DANFe
```

## Code Organization

**Approach:** Modular por dom�nio de neg�cio � cada �rea funcional � um execut�vel independente

**Structure:**

| Camada | Path | Responsabilidade |
|--------|------|------------------|
| Dom�nio | `Comum/VO/`, `Comum/Controller/` | Entidades + regras de neg�cio |
| Infra DB | `Comum/DataModule/`, `Comum/T2TiORM.pas` | Conex�o e persist�ncia |
| Servidor | `Servidor/` | DataSnap, dispatch, sess�es |
| Cliente UI | `Cliente/*/Tela/` | Forms por m�dulo |
| Cliente infra | `Cliente/Comum/` | Proxy, login, telas base |
| Fiscal | `Cliente/Comum/DataModule/UDataModule*.pas` | ACBr por documento |

**Module boundaries:**

- Cada pasta em `Cliente/` compila um `.dpr` independente
- `Comum/` � linkada estaticamente no servidor e parcialmente nos clientes
- M�dulos fiscais duplicam telas/units localmente (NF-e copiada em BalcaoPAF, NFC-e Mobile fork de VOs)
- `SM/` � boundary separado � REST mORMot sem integra��o com DataSnap principal
