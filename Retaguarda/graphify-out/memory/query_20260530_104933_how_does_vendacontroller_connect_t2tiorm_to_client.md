---
type: "query"
date: "2026-05-30T10:49:33.173286+00:00"
question: "How does VendaController connect T2TiORM to Cliente sales modules?"
contributor: "graphify"
source_nodes: ["VendaController", "T2TiORM", "VendaCabecalhoController", "VendaCabecalhoVO"]
---

# Q: How does VendaController connect T2TiORM to Cliente sales modules?

## Answer

VendaController (NFC-e Mobile) and VendaCabecalhoController (Comum) both delegate CRUD to TT2TiORM generic methods on VOs. Comum/T2TiORM.pas maps entities via Atributos.pas to VendaCabecalhoVO. Cliente/Vendas/UVenda.pas calls VendaCabecalhoController via TController.ExecutarMetodo. T2TiERPVendas.dpr imports Comum T2TiORM, VendaCabecalhoVO and VendaCabecalhoController.

## Source Nodes

- VendaController
- T2TiORM
- VendaCabecalhoController
- VendaCabecalhoVO