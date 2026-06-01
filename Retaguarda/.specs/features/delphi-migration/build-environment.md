# Ambiente de Build � Migra��o Delphi 13

**Atualizado:** 2026-05-30  
**Validado por:** inspe��o de logs e configura��o local

---

## RAD Studio / Delphi

| Item | Valor |
|------|-------|
| Produto | RAD Studio 13 Florence |
| Compiler | `dcc32` version **37.0** |
| IDE path | `C:\Program Files (x86)\Embarcadero\Studio\37.0\` |
| Define VER | `VER370` (Florence) |
| Lib suffix ACBr | `LibD37` |
| Plataforma inicial | **Win32** (Win64 ap�s estabiliza��o) |
| Confirmado pelo usu�rio | ? Instalado (�ltima vers�o) |

---

## ACBr (Trunk2 local)

| Item | Valor |
|------|-------|
| Reposit�rio | `C:\repositorio\ACBr\` |
| Instalador | `ACBrInstall_Trunk2.exe` v **3.3.4.10** |
| �ltima instala��o D13 Win32 | **13/04/2026 13:56** � sucesso |
| Log | `C:\repositorio\ACBr\log_Delphi_13_Florence_Win32.txt` |
| Bibliotecas compiladas | `C:\repositorio\ACBr\Lib\Delphi\LibD37\Win32\` |
| Fontes | `C:\repositorio\ACBr\Fontes\` |
| Pacotes Delphi | `C:\repositorio\ACBr\Pacotes\Delphi\` |
| Plataformas instaladas | D12 + D13 (Win32, Win64, Linux64) |

### Status da instala��o ACBr D13

Log confirma compila��o bem-sucedida de pacotes base:
- `ACBr_synapse`, `ACBr_Comum`, `ACBr_OpenSSL`, `ACBr_Diversos`
- `ACBr_PCNComum`, `ACBr_NFe`, `ACBr_SPED`, `ACBr_Sintegra`, etc.
- Instala��o finalizada: *"C�pia dos arquivos necess�rio feita com sucesso"*

**Conclus�o:** ACBr Trunk2 em `C:\repositorio\ACBr` � **compat�vel com Delphi 13 Florence** � pacotes compilam na IDE local.

---

## Paths para projetos T2Ti (configurar nos .dproj D13)

```
DCC_UnitSearchPath:
  C:\repositorio\ACBr\Fontes\ACBrComum
  C:\repositorio\ACBr\Fontes\ACBrDFe\ACBrNFe
  C:\repositorio\ACBr\Fontes\ACBrDFe\ACBrCTe
  ... (por m�dulo fiscal � ver acbr-validation.md)

DCC_BplOutput / runtime:
  C:\repositorio\ACBr\Lib\Delphi\LibD37\Win32
```

**Substituir** paths legados T2Ti:
- ~~`..\..\..\..\Componentes\Delphi\ACBr2\`~~
- ~~`RAD Studio\7.0\Bpl\`~~

---

## T2Ti ERP Retaguarda

| Item | Valor |
|------|-------|
| Workspace | `C:\repositorio\Exemplos_ERP-PDV\T2TiERP-2-Delphi\Retaguarda\` |
| Baseline IDE | Delphi XE7 (`ProjectVersion=15.3`) |
| Target IDE | Delphi 13 Florence (`ProjectVersion` ? 19.x / VER370) |
| Servidor | `Servidor\T2Ti_ServidorAplicacao.dpr` |
| Piloto | `Cliente\Cadastros\T2TiERP_Cadastros.dpr` |

---

## Fora de escopo (confirmado)

| M�dulo | Decis�o |
|--------|---------|
| `Cliente/Loja Virtual/` | **Descontinuado** � n�o migrar |
| `SM/RESTserver.dpr` | **Descontinuar** (mORMot) |

---

## Depend�ncias ainda necess�rias (n�o-ACBr)

| Depend�ncia | Status | A��o na migra��o |
|-------------|--------|------------------|
| JVCL | Third-party | Eliminar ? VCL nativo |
| DBExpress | Deprecated | Eliminar ? FireDAC |
| Devart Postgres | Third-party | Eliminar ? FireDAC Pg |
| FastReport | Third-party | Eliminar ? Fortes/FPDF ACBr ou QuickReport |
| Zeos (AFV) | Third-party | Eliminar ? FireDAC |

---

## Build via linha de comando

Script na raiz do repositório (`T2TiERP-2-Delphi/build.bat`):

```bat
REM Piloto Cadastros (Win32 Debug)
build.bat Retaguarda\Cliente\Cadastros T2TiERP_Cadastros.dproj Debug Win32

REM Servidor
build.bat Retaguarda\Servidor T2Ti_ServidorAplicacao.dproj Debug Win32
```

O script carrega `rsvars.bat` (D13), entra no diretório do projeto e executa `msbuild` com `Config` e `Platform`.

### Baseline build (2026-06-01)

| Tentativa | Resultado |
|-----------|-----------|
| Antes T2.1 | `F1026: File not found: 'true.dpr'` — corrigido no `.dproj` |
| Após T2.1 | Compilador D13 inicia; cadeia de erros de código legado (esperado) |

**Correções T2.1 aplicadas em `T2TiERP_Cadastros.dproj`:**
- `ProjectVersion` 15.3 → 19.4
- `DCC_DebugInformation` removido do Base; `1` apenas em Debug
- `Excluded_Packages` atualizado para sufixo D13 (`370`)

**Cadeia de erros após fix do .dproj (T2.3+):**

| Ordem | Erro | Fase |
|-------|------|------|
| 1 | `Dbtables` not found | Removido de `Biblioteca.pas` (uses morto) |
| 2 | `TJSONValue` / `DBXJSON` em `VO.pas` | F5 — System.JSON |
| 3 | `JvDBUltimGrid` (JVCL ausente) | F4 — telas base |

---

## Comandos úteis

```powershell
# Verificar compiler D13
& "C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\dcc32.exe" 2>&1 | Select-Object -First 3

# Reinstalar ACBr (se necess�rio)
& "C:\repositorio\ACBr\ACBrInstall_Trunk2.exe"

# Log p�s-instala��o
Get-Content "C:\repositorio\ACBr\log_Delphi_13_Florence_Win32.txt" -Tail 20
```
