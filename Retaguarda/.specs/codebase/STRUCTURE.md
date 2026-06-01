# Project Structure

**Root:** `c:\repositorio\Exemplos_ERP-PDV\T2TiERP-2-Delphi\Retaguarda`

## Directory Tree

```
Retaguarda/
??? Comum/                    # Dom�nio compartilhado (servidor + ORM)
?   ??? Controller/           # 295 *Controller.pas
?   ??? VO/                   # ~400 *VO.pas
?   ??? DataModule/           # UDataModuleConexao
?   ??? DTO/                  # DTOs para SM/mORMot
?   ??? Relatorios/           # Templates .fr3
?   ??? T2TiORM.pas
?   ??? Biblioteca.pas
?   ??? Atributos.pas
??? Servidor/                 # DataSnap application server
?   ??? T2Ti_ServidorAplicacao.dpr
?   ??? Controller.pas
?   ??? ServerContainer.pas
?   ??? UDataModule.pas       # ACBr SPED/Sintegra
?   ??? Arquivos/             # Sa�das SPED, Sintegra, GED
?   ??? *_DBExpress_conn.txt
??? Cliente/                  # M�dulos desktop (1 EXE por pasta)
?   ??? Comum/                # Proxy, sess�o, telas base, DataModules ACBr
?   ??? Vendas/
?   ??? Financeiro/           # 7 execut�veis
?   ??? NF-e/, NFC-e Mobile/, NFS-e/, CT-e/
?   ??? Sped/, eSocial/, Folha/, Ponto/
?   ??? Cadastros/, CadastrosM/
?   ??? ... (~35 m�dulos)
??? SM/                       # REST server experimental (mORMot)
    ??? RESTserver.dpr
```

## Module Organization

### Comum

**Purpose:** Biblioteca de dom�nio � entidades, regras de neg�cio, ORM, utilit�rios  
**Location:** `Comum/`  
**Key files:** `T2TiORM.pas`, `Biblioteca.pas`, `Controller/*.pas`, `VO/*.pas`

### Servidor

**Purpose:** Servidor de aplica��o DataSnap; exp�e todos os controllers via HTTP  
**Location:** `Servidor/`  
**Key files:** `T2Ti_ServidorAplicacao.dpr`, `ServerContainer.pas`, `Controller.pas`, `SA.pas`

### Cliente (por dom�nio)

**Purpose:** Interface de usu�rio por �rea funcional do ERP  
**Location:** `Cliente/{Modulo}/`  
**Key files:** `{Modulo}.dpr`, `Tela/*.pas`, `Conexao.ini`, `*_DBExpress_conn.txt`

### Cliente/Comum

**Purpose:** Infraestrutura compartilhada dos clientes VCL (n�o confundir com `Comum/` raiz)  
**Location:** `Cliente/Comum/`  
**Key files:** `Controller.pas`, `SessaoUsuario.pas`, `Tela/ULogin.pas`, `Tela/UBase.pas`, `DataModule/UDataModuleNFe.pas`

### SM

**Purpose:** Prova de conceito REST com mORMot � n�o integrada ao fluxo principal  
**Location:** `SM/`  
**Key files:** `RESTserver.dpr`, `RESTModel.pas`

## Where Things Live

**Cadastros e consultas CRUD:**

- UI: `Cliente/{Modulo}/Tela/U{Entidade}.pas`
- Business Logic: `Comum/Controller/{Entidade}Controller.pas`
- Data Access: `Comum/T2TiORM.pas` + `Comum/VO/{Entidade}VO.pas`
- Configuration: `Cliente/{Modulo}/Conexao.ini`

**Autentica��o:**

- UI: `Cliente/Comum/Tela/ULogin.pas`
- Sess�o: `Cliente/Comum/SessaoUsuario.pas`
- Usu�rio: `Comum/Controller/UsuarioController.pas`

**Documentos fiscais (NF-e, CT-e, etc.):**

- UI + ACBr: `Cliente/{Modulo}/Tela/` + `Cliente/Comum/DataModule/`
- Persist�ncia: `Comum/Controller/Nfe*Controller.pas`, `Comum/VO/Nfe*.pas`
- Relat�rios: `Cliente/{Modulo}/*.fr3`, `Cliente/CT-e/Report/`

**SPED / Escrita fiscal:**

- Controllers: `Comum/Controller/SpedFiscalController.pas`, `SintegraController.pas`
- Servidor ACBr: `Servidor/UDataModule.pas`
- Sa�da: `Servidor/Arquivos/Sped/`, `Arquivos/Sintegra/`

**Financeiro / OFX:**

- Readers: `Comum/YMOFXReader.pas`, `YMOFCReader.pas`
- UI: `Cliente/Financeiro/Conciliacao Bancaria/`

## Special Directories

**`Servidor/Arquivos/`**  
Sa�das geradas (SPED, Sintegra, GED) � paths relativos ao execut�vel do servidor

**`Cliente/Comum/Tela/`**  
Framework de telas base: login, filtro, lookup, cadastro gen�rico

**`Cliente/Ponto/ACBrPonto/`**  
Pacote ACBr Ponto integrado ao m�dulo de ponto eletr�nico

**`Cliente/Loja Virtual/`**  
Aplica��o uniGUI separada + demo ChatRoom DataSnap

**`__history/` (em v�rias pastas)**  
Backup autom�tico da IDE � artefato de desenvolvimento, n�o c�digo ativo

## Execut�veis principais

| �rea | Programa |
|------|----------|
| Servidor | `Servidor/T2Ti_ServidorAplicacao.dpr` |
| Cadastros | `Cliente/Cadastros/T2TiERP_Cadastros.dpr` |
| Vendas | `Cliente/Vendas/T2TiERPVendas.dpr` |
| NF-e | `Cliente/NF-e/NFe.dpr` |
| Financeiro | `Cliente/Financeiro/T2TiERPFinanceiro.dpr` (+ 6 apps) |
| SPED | `Cliente/Sped/T2TiSped.dpr` |
| REST alt. | `SM/RESTserver.dpr` |

**Nota:** N�o existe `.groupproj` � cada m�dulo � aberto e compilado individualmente na IDE.
