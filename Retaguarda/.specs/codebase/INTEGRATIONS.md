# External Integrations

## Fiscal � Sefaz e documentos eletr�nicos

**Service:** ACBr (NF-e, NFC-e, NFS-e, CT-e, SPED, Sintegra, eSocial, Ponto)  
**Purpose:** Emiss�o, transmiss�o e impress�o de documentos fiscais brasileiros  
**Implementation:**

| Documento | Execut�vel | Tela / DataModule | Controllers / VOs |
|-----------|------------|-------------------|-------------------|
| NF-e | `Cliente/NF-e/NFe.dpr` | `Tela/UNFe.pas`, `Comum/DataModule/UDataModuleNFe.pas` | `Comum/Controller/Nfe*Controller.pas`, `Comum/VO/Nfe*.pas` |
| NFC-e | `Cliente/NFC-e Mobile/T2TiERPNFCe.dpr` | `Tela/UMenu.pas` (FMX + FireDAC) | VOs fork em `NFC-e Mobile/VO/` |
| NFS-e | `Cliente/NFS-e/T2TiERPNFSe.dpr` | `Tela/UNFSe.pas` | `NfseCabecalhoController.pas` |
| CT-e | `Cliente/CT-e/CTe.dpr` | `Tela/UCTe.pas`, `UDataModuleCTe.pas` | `Comum/VO/Cte*.pas` |
| SPED | `Cliente/Sped/T2TiSped.dpr` | `Tela/USpedFiscal.pas`, `USpedContabil.pas` | `SpedFiscalController.pas`, `SpedContabilController.pas` |
| eSocial | `Cliente/eSocial/T2TieSocial.dpr` | `Tela/uExemploEsocial.pas` | Integra��o direta ACBr eSocial |
| PAF/ECF | `Cliente/BalcaoPAF/BalcaoPAF.dpr` | `Tela/UDAV.pas`, `UPreVenda.pas` | `DAVController.pas`, `Comum/VO/Ecf*.pas` |

**Configuration:**

- Certificado digital: persistido em `NfeConfiguracaoVO` / telas ACBr
- `Cliente/NFS-e/Configuracoes.ini` � emitente, certificado, webservice NFSe
- Ambiente Sefaz via propriedades ACBr nas telas

**Authentication:** Certificado A1/A3 no store Windows; credenciais de webservice por munic�pio (NFS-e)

## SPED / Sintegra / Escrita Fiscal

**Service:** ACBr SPED + Sintegra  
**Purpose:** Gera��o de arquivos fiscais e cont�beis  
**Implementation:** `Servidor/UDataModule.pas` (`TACBrSPEDFiscal`, `TACBrSPEDContabil`, `TACBrSintegra`); controllers em `Comum/Controller/Sped*.pas`, `SintegraController.pas`  
**Configuration:** Paths de sa�da `Servidor/Arquivos/Sped/`, `Arquivos/Sintegra/`  
**Authentication:** N/A (arquivos locais)

## Impress�o e relat�rios

**Service:** FastReport + ACBr print engines  
**Purpose:** DANFe, DACTe, DANFSe, boletos, etiquetas, espelho ponto  
**Implementation:**

- FastReport `.fr3`: `Cliente/NF-e/DANFeRetrato.fr3`, `Cliente/CT-e/Report/DACTE*.fr3`, `Comum/Relatorios/EMBALAGEM.fr3`
- ACBr: `TACBrNFeDANFEFR`, `TACBrCTeDACTeRL`, `TACBrNFSeDANFSeRL`, `TACBrBoletoFCFR`
- T�rmica: `TACBrPosPrinter`, `TACBrNFeDANFeESCPOS` em `Cliente/Comum/DataModule/UDataModule.pas`

**Configuration:** Templates `.fr3` no diret�rio do m�dulo; `LoadFromFile` relativo ao CWD em alguns casos

## Banc�rio / OFX

**Service:** Leitor OFX/OFC propriet�rio  
**Purpose:** Importa��o de extratos para concilia��o banc�ria  
**Implementation:** `Comum/YMOFXReader.pas`, `Comum/YMOFCReader.pas`  
**Usage:** `Cliente/Financeiro/Conciliacao Bancaria/UFinExtratoContaBanco.pas`  
**Authentication:** N/A

## DataSnap HTTP (integra��o cliente?servidor)

**Service:** Embarcadero DataSnap REST  
**Purpose:** RPC JSON entre ~40 clientes VCL e servidor central  
**Implementation:**

- Servidor: `Servidor/ServerContainer.pas` � `HttpPort=8080`, `RESTContext='restT2Ti/'`
- Dispatcher: `Servidor/Controller.pas`
- Cliente: `Cliente/Comum/Controller.pas`, `SessaoUsuario.pas`

**Configuration:** `Conexao.ini` � `[ServidorApp] Servidor`, `Porta`, `Camadas`

**Authentication:** HTTP Basic Auth � user `login|idSessao`, password MD5(login+senha)

**Key endpoints (gen�ricos):**

- `GET .../TController/ObjetoJson/{Controller}/{Metodo}/{params}`
- `POST .../TController/AcceptObjetoJson/...`
- `PUT .../TController/UpdateObjetoJson/...`
- `DELETE .../TController/CancelObjetoJson/...`

## REST mORMot (experimental)

**Service:** Synopse mORMot  
**Purpose:** API REST alternativa sobre PostgreSQL  
**Implementation:** `SM/RESTserver.dpr`, `SM/RESTModel.pas`  
**Configuration:** PostgreSQL hardcoded `localhost:5432`, database `t2tierp`, porta HTTP **888**  
**Authentication:** `authentication=false`, CORS `*` � **sem auth**

**Nota:** N�o referenciado por `T2Ti_ServidorAplicacao.dpr`; tratar como POC isolado.

## Loja Virtual (uniGUI)

**Service:** uniGUI + DBExpress direto  
**Purpose:** E-commerce B2C web  
**Implementation:** `Cliente/Loja Virtual/T2TiERPLojaVirtual.dpr`, `Main.pas` com `TSQLConnection`  
**Configuration:** Conex�o DB local na aplica��o web, separada do DataSnap  
**Demo adicional:** `Cliente/Loja Virtual/ChatRoomDemo/` � DataSnap chat Embarcadero

## Ponto eletr�nico / AFD

**Service:** ACBr Ponto  
**Purpose:** Tratamento de arquivos AFD, espelho de ponto  
**Implementation:** `Cliente/Ponto/ACBrPonto/`, `UPontoTratamentoArquivoAFD.pas`, `UPontoEspelho.pas` (Word automation)  
**Configuration:** Layout Word `LayoutPonto.doc` no diret�rio do exe

## GED

**Service:** Armazenamento local de arquivos  
**Purpose:** Gest�o eletr�nica de documentos  
**Implementation:** `Comum/Controller/GedDocumentoDetalheController.pas`  
**Configuration:** Path `\Arquivos\GED\` relativo ao execut�vel; hash MD5 nos metadados

## API Integrations � resumo

| API | Protocolo | Auth | Location |
|-----|-----------|------|----------|
| Sefaz NF-e/NFC-e | HTTPS (ACBr) | Certificado digital | `UNFe.pas`, `UMenu.pas` |
| Prefeituras NFS-e | HTTPS (ACBr) | Certificado + config munic�pio | `UNFSe.pas` |
| Sefaz CT-e | HTTPS (ACBr) | Certificado digital | `UCTe.pas` |
| eSocial | HTTPS (ACBr) | Certificado digital | `uExemploEsocial.pas` |
| DataSnap ERP | HTTP JSON | HTTP Basic (MD5) | `Servidor/`, `Cliente/Comum/` |
| mORMot REST | HTTP JSON | Nenhuma | `SM/RESTserver.dpr` |

## Webhooks

N�o identificados no codebase.

## Background Jobs

N�o h� fila de jobs (Redis, RabbitMQ, etc.). Processamento � **s�ncrono** nas telas/controllers (SPED, NF-e, importa��o OFX).

## SOAP / WSDL

N�o encontrado � integra��es externas usam ACBr (HTTPS) ou DataSnap (HTTP JSON).

## Depend�ncias externas n�o versionadas

**ACBr:** esperado em path local `Componentes/Delphi/ACBr2/` � ausente no reposit�rio  
**Devart PostgreSQL:** DLL `dbexppgsql40.dll`  
**mORMot/Synopse:** checkout separado necess�rio para compilar `SM/`
