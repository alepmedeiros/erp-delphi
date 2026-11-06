# scan-dependencies.ps1 � Invent�rio automatizado de depend�ncias Delphi (MIG-001 / T1.2)
# Uso: .\scan-dependencies.ps1 [-Root "C:\path\to\Retaguarda"]

param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path
)

$ErrorActionPreference = "Stop"
$Root = (Resolve-Path $Root).Path
$OutDir = Join-Path (Split-Path $PSScriptRoot -Parent) "output"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$KnownPatterns = [ordered]@{
    "DBExpress"       = @("dbexpress", "DbxCommonDriver", "DbxClientDriver", "DBXMySQLDriver", "DBXFirebirdDriver", "Data.SqlExpr", "TSQLConnection")
    "DataSnap"        = @("datasnap", "dsnap", "DataSnap", "DSHTTP", "DBXJSON")
    "JVCL"            = @("JvCore", "JvDB", "JvAppFrm", "JvUltimGrid", "Jcl", "Jv")
    "ACBr"            = @("ACBr", "PCN2", "synapse")
    "Zeos"            = @("ZComponent", "ZDbc", "ZCore", "ZPlain")
    "Devart"          = @("Devart", "DevartPostgreSQL", "PgDAC")
    "FastReport"      = @("frx", "fsADO", "fsIBX", "FastReport")
    "FireDAC"         = @("FireDAC", "FDPhys")
    "Indy"            = @("IndyCore", "IndySystem", "IndyProtocols", "IndyIP")
    "mORMot/Synopse"  = @("mORMot", "SynCommons", "SynDB")
    "IntraWeb"        = @("Intraweb", "intraweb")
    "Rave"            = @("Rave", "Rave77")
    "TeeChart"        = @("Tee", "TeeDB", "TeeUI", "FmxTee")
    "REST/VCL"        = @("RESTComponents", "VCLRESTComponents")
    "CodeSite"        = @("CodeSite")
    "BDE"             = @("Bde", "bdertl", "JvBDE")
    "CAPICOM"         = @("CAPICOM", "Capicom")
    "uniGUI"          = @("uniGUI", "uni")
}

function Get-ProjectPackages {
    param([string]$DprojPath)
    [xml]$xml = Get-Content -LiteralPath $DprojPath -Encoding UTF8
    $packages = @()
    $searchPaths = @()
    $namespaces = @()
    foreach ($pg in $xml.Project.PropertyGroup) {
        if ($pg.DCC_UsePackage) {
            $packages += ($pg.DCC_UsePackage -split ';' | Where-Object { $_ -and $_ -notmatch '^\$\(' })
        }
        if ($pg.DCC_UnitSearchPath) {
            $searchPaths += ($pg.DCC_UnitSearchPath -split ';' | Where-Object { $_ })
        }
        if ($pg.DCC_Namespace) {
            $namespaces += ($pg.DCC_Namespace -split ';' | Where-Object { $_ -and $_ -notmatch '^\$\(' })
        }
    }
    return @{
        Packages = ($packages | Select-Object -Unique)
        SearchPaths = ($searchPaths | Select-Object -Unique)
        Namespaces = ($namespaces | Select-Object -Unique)
    }
}

function Match-Categories {
    param([string[]]$Tokens)
    $found = @{}
    foreach ($cat in $KnownPatterns.Keys) {
        $patterns = $KnownPatterns[$cat]
        foreach ($tok in $Tokens) {
            foreach ($pat in $patterns) {
                if ($tok -match [regex]::Escape($pat) -or $tok -like "*$pat*") {
                    if (-not $found.ContainsKey($cat)) { $found[$cat] = @() }
                    if ($found[$cat] -notcontains $tok) { $found[$cat] += $tok }
                }
            }
        }
    }
    return $found
}

$dprojs = Get-ChildItem -Path $Root -Filter "*.dproj" -Recurse -File
$projectRows = @()
$packageMatrix = @{}
$categoryByProject = @{}

foreach ($dproj in $dprojs) {
    $rel = $dproj.FullName.Substring($Root.Length).TrimStart('\', '/')
    $info = Get-ProjectPackages -DprojPath $dproj.FullName
    $tokens = @($info.Packages + $info.Namespaces + $info.SearchPaths)
    $cats = Match-Categories -Tokens $tokens

    $projectRows += [PSCustomObject]@{
        Project = $rel
        PackageCount = $info.Packages.Count
        Categories = ($cats.Keys -join ", ")
        HasDCC_UsePackage = ($info.Packages.Count -gt 0)
    }

    foreach ($cat in $cats.Keys) {
        if (-not $categoryByProject.ContainsKey($cat)) { $categoryByProject[$cat] = @() }
        $categoryByProject[$cat] += $rel
    }

    foreach ($pkg in $info.Packages) {
        if (-not $packageMatrix.ContainsKey($pkg)) { $packageMatrix[$pkg] = @() }
        $packageMatrix[$pkg] += $rel
    }
}

# Scan .pas/.dpr for uses (sample: third-party unit names in uses clause)
$sourcePatterns = @(
    "Data\.SqlExpr", "DSHTTP", "DBXJSON", "JvDBUltimGrid", "JvPageList",
    "ACBrNFe", "ACBrDFe", "frxClass", "ZConnection", "DevartPostgreSQL",
    "CAPICOM_TLB", "mORMot", "SynCommons", "TDSHTTP", "Dext\.Net"
)
$sourceHits = @{}
$pasFiles = Get-ChildItem -Path $Root -Include "*.pas","*.dpr" -Recurse -File |
    Where-Object { $_.FullName -notmatch '\\(__history|graphify-out|\.git)\\' }

foreach ($pat in $sourcePatterns) {
    $sourceHits[$pat] = @()
}
foreach ($file in $pasFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    $rel = $file.FullName.Substring($Root.Length).TrimStart('\', '/')
    foreach ($pat in $sourcePatterns) {
        if ($content -match $pat) {
            $sourceHits[$pat] += $rel
        }
    }
}

# Output CSV
$csvPath = Join-Path $OutDir "project-dependencies.csv"
$projectRows | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

# Output MD report
$mdPath = Join-Path $OutDir "dependency-inventory.md"
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("# Invent�rio de Depend�ncias � Retaguarda")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("**Gerado:** $(Get-Date -Format 'yyyy-MM-dd HH:mm')")
[void]$sb.AppendLine("**Root:** ``$Root``")
[void]$sb.AppendLine("**Projetos (.dproj):** $($dprojs.Count)")
[void]$sb.AppendLine("**Req-ID:** MIG-001 / T1.2")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## Resumo por categoria")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("| Categoria | Projetos afetados | A��o migra��o |")
[void]$sb.AppendLine("|-----------|-------------------|---------------|")

$actionMap = @{
    "DBExpress" = "FireDAC (F3)"
    "DataSnap" = "Dext API + TRestClient (F5?Dext)"
    "JVCL" = "VCL nativo / Skia (F4)"
    "ACBr" = "ACBr Trunk2 D13 (F7)"
    "Zeos" = "FireDAC (F6)"
    "Devart" = "FDPhysPgDriverLink (F3)"
    "FastReport" = "QuickReport/PDF (F4/F7)"
    "FireDAC" = "Expandir (j� parcial AFV/NFC-e)"
    "Indy" = "Manter"
    "mORMot/Synopse" = "Descontinuar SM/"
    "IntraWeb" = "Remover (Loja Virtual)"
    "Rave" = "Remover"
    "TeeChart" = "Verificar licen�a D13"
    "REST/VCL" = "Manter / Dext client"
    "CodeSite" = "Remover"
    "BDE" = "Remover"
    "CAPICOM" = "WinCrypt/OpenSSL (F7 fiscal)"
    "uniGUI" = "Descontinuar Loja Virtual"
}

foreach ($cat in ($categoryByProject.Keys | Sort-Object)) {
    $count = ($categoryByProject[$cat] | Select-Object -Unique).Count
    $action = if ($actionMap.ContainsKey($cat)) { $actionMap[$cat] } else { "Revisar" }
    [void]$sb.AppendLine("| $cat | $count | $action |")
}

[void]$sb.AppendLine("")
[void]$sb.AppendLine("## Projetos sem DCC_UsePackage expl�cito")
[void]$sb.AppendLine("")
$noPkg = $projectRows | Where-Object { -not $_.HasDCC_UsePackage }
[void]$sb.AppendLine("Total: $($noPkg.Count) � depend�ncias inferidas via DCCReference/uses nas units linkadas.")
[void]$sb.AppendLine("")
foreach ($p in ($noPkg | Select-Object -ExpandProperty Project | Sort-Object)) {
    [void]$sb.AppendLine("- ``$p``")
}

[void]$sb.AppendLine("")
[void]$sb.AppendLine("## Projetos por tier de complexidade")
[void]$sb.AppendLine("")
$tier1 = @("Cadastros", "Agenda", "Etiquetas", "GED", "Comissoes")
$tier4 = @("NF-e", "NFe", "Sped", "eSocial", "BalcaoPAF", "Ponto", "CT-e", "NFS-e", "Escrita Fiscal")
foreach ($tier in @(
    @{ Name = "T1 Simples"; Match = $tier1 },
    @{ Name = "T4 Fiscal"; Match = $tier4 }
)) {
    [void]$sb.AppendLine("### $($tier.Name)")
    $matched = $projectRows | Where-Object {
        $proj = $_.Project
        ($tier.Match | Where-Object { $proj -like "*$_*" }).Count -gt 0
    }
    foreach ($m in ($matched | Sort-Object Project)) {
        [void]$sb.AppendLine("- ``$($m.Project)`` � $($m.Categories)")
    }
    [void]$sb.AppendLine("")
}

[void]$sb.AppendLine("## Refer�ncias em c�digo-fonte (.pas/.dpr)")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("| Padr�o | Arquivos |")
[void]$sb.AppendLine("|--------|----------|")
foreach ($pat in ($sourceHits.Keys | Sort-Object)) {
    $files = ($sourceHits[$pat] | Select-Object -Unique)
    [void]$sb.AppendLine("| ``$pat`` | $($files.Count) |")
}

[void]$sb.AppendLine("")
[void]$sb.AppendLine("## Top 30 pacotes mais usados")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("| Pacote | Projetos |")
[void]$sb.AppendLine("|--------|----------|")
$top = $packageMatrix.GetEnumerator() | Sort-Object { $_.Value.Count } -Descending | Select-Object -First 30
foreach ($entry in $top) {
    [void]$sb.AppendLine("| ``$($entry.Key)`` | $($entry.Value.Count) |")
}

[void]$sb.AppendLine("")
[void]$sb.AppendLine("## Detalhe: categoria ? projetos")
[void]$sb.AppendLine("")
foreach ($cat in ($categoryByProject.Keys | Sort-Object)) {
    [void]$sb.AppendLine("### $cat")
    foreach ($p in ($categoryByProject[$cat] | Select-Object -Unique | Sort-Object)) {
        [void]$sb.AppendLine("- ``$p``")
    }
    [void]$sb.AppendLine("")
}

$sb.ToString() | Out-File -FilePath $mdPath -Encoding UTF8

Write-Host "Scanned $($dprojs.Count) .dproj files"
Write-Host "Output: $mdPath"
Write-Host "CSV:    $csvPath"
