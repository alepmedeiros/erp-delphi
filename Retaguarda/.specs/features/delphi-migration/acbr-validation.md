# Valida��o ACBr � T2Ti XE7 ? ACBr Trunk2 D13

**Data:** 2026-05-30  
**ACBr:** `C:\repositorio\ACBr\` (Trunk2)  
**Delphi:** 13 Florence (compiler 37.0)

---

## Resultado geral

| Crit�rio | Status |
|----------|--------|
| ACBr compila no D13 Florence | ? Confirmado (log 13/04/2026) |
| Reposit�rio local atualizado | ? `C:\repositorio\ACBr` |
| Pacotes fiscais T2Ti existem no ACBr novo | ? (com renomea��es) |
| C�digo T2Ti compat�vel sem altera��o | ? **Requer adapta��o** (API/pacotes mudaram desde XE7) |

**Decis�o:** **Op��o A confirmada** � manter ACBr como camada fiscal, usando Trunk2 local em D13, com refatora��o do c�digo T2Ti na Fase F7.

---

## Evid�ncia de compatibilidade D13

Arquivo: `C:\repositorio\ACBr\log_Delphi_13_Florence_Win32.txt`

```
Versao Instalador: 3.3.4.10
Vers�o do delphi: Delphi 13 Florence Win32
Dir. Instala��o : C:\repositorio\ACBr\
Dir. Bibliotecas: C:\repositorio\ACBr\Lib\Delphi\LibD37\Win32
Embarcadero Delphi for Win32 compiler version 37.0
Compilation success (todos os pacotes selecionados)
```

Suporte expl�cito no c�digo ACBr: `{$IFDEF VER370}` em pacotes (ex.: `ACBr_FastReportComum.dpk`).

---

## Mapa de pacotes: T2Ti XE7 ? ACBr Trunk2 D13

| T2Ti XE7 (legado) | ACBr Trunk2 D13 | Notas |
|-------------------|-----------------|-------|
| `ACBrComum` / `ACBr_Comum` | `ACBr_Comum` | Nome padronizado com underscore |
| `PCN2` | `ACBr_PCNComum` | PCN integrado ao ACBr |
| `ACBr_NFe2` | `ACBr_NFe` | NFe2 renomeado; unit `ACBrNFe.pas` mantida |
| `synapse` | `ACBr_synapse` | Pacote ACBr wrapper |
| `ACBrCapicom` | ? Removido | Substitu�do por **`ACBr_OpenSSL`** |
| `ACBr_BoletoFC_Fortes` | `ACBr_BoletoRL` / Fortes variants | Ver pacotes em `ACBrBoleto/` |
| `ACBr_NFeDanfeFR` | `ACBr_NFeDanfeFR` / `ACBr_NFeDanfeRL` / `ACBr_NFeDanfeFPDF` | Escolher engine sem FastReport se poss�vel |
| `ACBr_SPED` | `ACBr_SPED` | Mantido |
| `ACBr_Sintegra` | `ACBr_Sintegra` | Mantido |
| `ACBr_Ponto` (embedded) | `ACBr_Ponto` | Remover c�pia em `Cliente/Ponto/ACBrPonto/`; usar pacote trunk |

---

## Units ACBr usadas pelo T2Ti (adaptar na F7)

Fonte: `Cliente/Comum/DataModule/UDataModule.pas`, m�dulos fiscais

| Unit T2Ti | Status no ACBr Trunk2 |
|-----------|----------------------|
| `ACBrNFe` | ? `Fontes/ACBrDFe/ACBrNFe/ACBrNFe.pas` |
| `ACBrCTe` | ? `Fontes/ACBrDFe/ACBrCTe/` |
| `ACBrSpedFiscal` | ? `Fontes/ACBrTXT/ACBrSpedFiscal/` |
| `ACBrSpedContabil` | ? |
| `ACBrSpedContribuicoes` / `ACBrSPEDPisCofins` | ? Verificar nome exato da unit |
| `ACBrSintegra` | ? |
| `ACBrBoleto` | ? |
| `ACBrPosPrinter` | ? `Fontes/ACBrSerial/` |
| `ACBrNFeDANFEFR` | ?? Requer FastReport **ou** migrar para `ACBr_NFeDanfeRL` (Fortes, sem FR) |
| `ACBrNFeDANFeRL` | ? Alternativa nativa-friendly |
| `ACBrBoletoFCFR` | ?? Migrar para `ACBr_BoletoRL` (Fortes) |
| `JvBrowseFolder` em UDataModule | ? JVCL � substituir VCL (`FileOpenDialog`) |

---

## Breaking changes esperados na migra��o fiscal

### 1. Certificado digital

- **XE7:** `ACBrCapicom` (Windows Crypto API legado)
- **D13:** `ACBr_OpenSSL` � reconfigurar certificados A1/A3 nas telas NF-e/NFS-e

### 2. Propriedades e eventos ACBrNFe

ACBr Trunk2 evoluiu significativamente desde 2014. Esperar:
- Renomea��o de propriedades `WebServices.*`
- Novos enums de vers�o NF-e (4.00+)
- Ajustes em `ACBrNFe.NotasFiscais.Add` e fluxo de transmiss�o

**Mitiga��o:** Migrar m�dulo a m�dulo; comparar com exemplos em `C:\repositorio\ACBr\Exemplos\ACBrDFe\ACBrNFe\Delphi\`

### 3. Pacote ACBrPonto embarcado

`Cliente/Ponto/ACBrPonto/` referencia paths antigos (`Componentes\Delphi\ACBr2\`).  
**A��o:** Remover pacote local; usar `ACBr_Ponto.dpk` do trunk.

### 4. DANFe FastReport

T2Ti usa `.fr3` + `ACBr_NFeDanfeFR`. Para reduzir depend�ncia FastReport:
- **Preferir:** `ACBr_NFeDanfeRL` (Report Fortes � inclu�do no ecossistema ACBr, n�o � Embarcadero nativo mas elimina FastReport)
- **Alternativa:** `ACBr_NFeDanfeFPDF` (PDF direto)

---

## Pacotes ACBr necess�rios para T2Ti (m�nimo)

Baseado nos m�dulos Retaguarda:

```
ACBr_synapse, ACBr_Comum, ACBr_OpenSSL, ACBr_Diversos
ACBr_PCNComum, ACBr_DFeComum
ACBr_NFe (+ DANFE engine escolhida)
ACBr_CTe (+ DACTe)
ACBr_NFSe (NFS-e)
ACBr_SPED, ACBr_Sintegra, ACBr_SPEDImportar
ACBr_Boleto (+ engine RL)
ACBr_Serial (PosPrinter)
ACBr_Ponto
ACBre_Social (eSocial)
ACBr_PAF (Balc�o PAF)
```

Lista completa instalada: `C:\repositorio\ACBr\ACBrInstall_Trunk2.ini` se��o `[PACOTES]`.

---

## Plano de valida��o funcional (F7)

| Step | A��o | Gate |
|------|------|------|
| V1 | Compilar pacotes ACBr D13 (j� feito) | Log success |
| V2 | Criar projeto spike `ACBrNFeSpike.dpr` referenciando trunk | Compila |
| V3 | Portar `UDataModule.pas` fiscal para D13 + ACBr trunk | Compila |
| V4 | Portar `UNFe.pas` � ajustar API ACBrNFe | Compila |
| V5 | Emitir NF-e homologa��o | Autoriza��o Sefaz OK |
| V6 | Repetir para SPED, CT-e, NFS-e, eSocial, Ponto | Por m�dulo |

---

## Riscos residuais

| Risco | Severidade | Mitiga��o |
|-------|------------|-----------|
| API ACBrNFe mudou vs c�digo 2014 | Alta | Spike V2�V4 antes de portar UNFe completo |
| FastReport + ACBr FR incompat�vel D13 | M�dia | Migrar para DanfeRL/FPDF |
| Certificado Capicom ? OpenSSL | M�dia | Testar A1 cedo em homologa��o |
| Controllers SPED acoplados a paths ACBr antigos | M�dia | Atualizar paths para `C:\repositorio\ACBr\Fontes\` |

---

## Refer�ncias

- Log instala��o: `C:\repositorio\ACBr\log_Delphi_13_Florence_Win32.txt`
- Exemplos NF-e: `C:\repositorio\ACBr\Exemplos\ACBrDFe\ACBrNFe\Delphi\`
- Instalador config: `C:\repositorio\ACBr\ACBrInstall_Trunk2.ini`
