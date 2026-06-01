import re
import csv
from pathlib import Path
from collections import defaultdict

root = Path(__file__).resolve().parents[4]
out = root / ".specs/features/delphi-migration/output"
out.mkdir(parents=True, exist_ok=True)

patterns = {
    "DBExpress": ["dbexpress", "DbxCommonDriver", "DbxClientDriver", "DBXMySQLDriver", "Data.SqlExpr"],
    "DataSnap": ["datasnap", "dsnap", "DataSnap", "DSHTTP", "DBXJSON"],
    "JVCL": ["JvCore", "JvDB", "JvAppFrm", "Jcl", ";Jv"],
    "ACBr": ["ACBr", "PCN2", "synapse"],
    "Zeos": ["ZComponent", "ZDbc", "ZCore"],
    "Devart": ["Devart", "PgDAC"],
    "FastReport": ["frx", "fsADO", "FastReport"],
    "FireDAC": ["FireDAC", "FDPhys"],
    "Indy": ["IndyCore", "IndySystem", "IndyProtocols"],
    "mORMot/Synopse": ["mORMot", "SynCommons"],
    "IntraWeb": ["Intraweb", "intraweb"],
    "Rave": ["Rave"],
    "TeeChart": ["TeeDB", "TeeUI", "FmxTee"],
    "BDE": ["Bde", "bdertl", "JvBDE"],
}


def match_cats(text: str) -> dict:
    found = {}
    low = text.lower()
    for cat, pats in patterns.items():
        for p in pats:
            if p.lower() in low:
                found[cat] = True
                break
    return found


rows = []
cat_projects = defaultdict(set)
pkg_projects = defaultdict(set)

for dproj in root.rglob("*.dproj"):
    if "graphify-out" in str(dproj):
        continue
    rel = dproj.relative_to(root).as_posix()
    text = dproj.read_text(encoding="utf-8", errors="ignore")
    pkgs = []
    for m in re.finditer(r"<DCC_UsePackage>([^<]+)</DCC_UsePackage>", text):
        pkgs.extend(p for p in m.group(1).split(";") if p and not p.startswith("$("))
    pkgs = list(dict.fromkeys(pkgs))
    cats = match_cats(text)
    rows.append(
        {
            "Project": rel,
            "PackageCount": len(pkgs),
            "Categories": ", ".join(sorted(cats)),
            "HasPackages": bool(pkgs),
        }
    )
    for c in cats:
        cat_projects[c].add(rel)
    for p in pkgs:
        pkg_projects[p].add(rel)

with open(out / "project-dependencies.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=["Project", "PackageCount", "Categories", "HasPackages"])
    w.writeheader()
    w.writerows(sorted(rows, key=lambda r: r["Project"]))

src_patterns = [
    "Data.SqlExpr", "DSHTTP", "DBXJSON", "JvDBUltimGrid", "ACBrNFe",
    "frxClass", "ZConnection", "CAPICOM_TLB", "TDSHTTP", "Dext.Net",
]
src_hits = {p: 0 for p in src_patterns}
for pas in root.rglob("*.pas"):
    if "graphify-out" in str(pas) or "__history" in str(pas):
        continue
    try:
        t = pas.read_text(encoding="latin-1", errors="ignore")
    except OSError:
        continue
    for p in src_patterns:
        if p in t:
            src_hits[p] += 1

no_pkg = [r for r in rows if not r["HasPackages"]]
lines = [
    "# Inventrio de Dependncias  Retaguarda",
    "",
    f"**Projetos (.dproj):** {len(rows)}",
    "**Req-ID:** MIG-001 / T1.2",
    "",
    "## Resumo por categoria",
    "",
    "| Categoria | Projetos | Ao sugerida |",
    "|-----------|----------|---------------|",
]
action = {
    "DBExpress": "FireDAC (F3)",
    "DataSnap": "Dext API + TRestClient",
    "JVCL": "VCL nativo / Skia (F4)",
    "ACBr": "ACBr Trunk2 D13 (F7)",
    "Zeos": "FireDAC (F6)",
    "Devart": "FDPhysPg (F3)",
    "FastReport": "QuickReport/PDF",
    "FireDAC": "Expandir",
    "Indy": "Manter",
    "mORMot/Synopse": "Descontinuar SM/",
    "IntraWeb": "Descontinuar Loja Virtual",
    "Rave": "Remover",
    "TeeChart": "Verificar licena",
    "BDE": "Remover",
}
for c in sorted(cat_projects):
    lines.append(f"| {c} | {len(cat_projects[c])} | {action.get(c, 'Revisar')} |")

lines += ["", f"## Projetos sem DCC_UsePackage explcito ({len(no_pkg)})", ""]
for r in sorted(no_pkg, key=lambda x: x["Project"]):
    lines.append(f"- `{r['Project']}`")

lines += ["", "## Referncias em cdigo (.pas)", "", "| Padro | Arquivos |", "|--------|----------|"]
for p, c in sorted(src_hits.items(), key=lambda x: -x[1]):
    lines.append(f"| `{p}` | {c} |")

lines += ["", "## Top 25 pacotes", ""]
for pkg, projs in sorted(pkg_projects.items(), key=lambda x: -len(x[1]))[:25]:
    lines.append(f"- `{pkg}`  {len(projs)} projetos")

(out / "dependency-inventory.md").write_text("\n".join(lines), encoding="utf-8")
print(f"Scanned {len(rows)} projects -> {out / 'dependency-inventory.md'}")
