# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal library of ad-hoc SQL queries against the company's ERP database (PostgreSQL at `10.0.0.101:5432`, schema `public`). The queries exist because the ERP's built-in reports can't be exported to Excel/Power BI; each `.sql` file is a standalone report meant to be run in a SQL client and copied into a spreadsheet or consumed by Power BI. There is no build, lint, or test step.

Language: file names, column aliases, and comments are in Portuguese (pt-BR). Keep that convention for new files and output column names. The company manufactures coffins (*urnas*).

## Layout

Folders map to business areas, not to code modules: `vendas/` (sales/invoicing), `compras/` (purchasing), `estoque/` (stock), `estruturas/` (BOM), `ordens produção/` and `produção/` (production orders and reporting), `expedição/` (shipping / load batches), `almoxarifado/` (warehouse material needs), `produto/`, `clientes/`, `tabelas preços/`, `cruzamentos/` (cross-area joins), `powerbi/` (queries consumed directly by Power BI — keep their output columns stable).

Root-level `hello world.sql`, `list collumns.sql`, `rascunho1.sql`, `produto.sql` are scratch/utility files. `list collumns.sql` is the go-to for inspecting a table's columns via `information_schema`.

CSV/JSON files (`faturamentos_export.csv`, `clientes/*.json`, `estoque/100 rows.csv`, `vendas/Exemplo Vendas 12 meses.csv`) are exported query results, not source data — don't parse them to learn the schema.

## Database schema — two naming families

The ERP exposes two generations of tables, and most queries join across both:

- **Legacy tables** with short cryptic column names prefixed by a 3-letter table abbreviation: `produto` (`produto`, `pronome`, `grupo`, `subgrupo`, `proorigem`, `prosldmin`, `proloteco`…), `grupo` (`grupo`, `grunome`), `grupo1` (subgroups: `subgrupo`, `subnome`, `grupo`), `estrutur` (BOM: `estproduto`, `estfilho`, `estqtduso`), `toqmovi` (stock movements: `pri*`, PK `itecontrol` + `prisequen`), `transa` (`transacao`, `trsnome`), `lotecar` (load batches: `lcacod`, `lcades`, `lcaprev`), `tabprven` (price list items: `ttpvcod`, `produto`, `prvenda`), `acabconf` (finish/config codes: `amctipacab`, `amccodigo`, `amccompos`), `tipacab`, `cidade` (`cidade`, `cidnome`, `estado`, `cidibge`), `empresa` (`empresa`, `empnome`, `empcgc` = CNPJ, `empcidade`), `condpag` (payment terms: `condicao`, `connome`).
- **`pw_*` views/tables** with long self-describing columns following `<entity>_<field>[_pk|_fk]`: `pw_faturamento`, `pw_pedido_venda`, `pw_pedido_compra`, `pw_compra`, `pw_empresa`, `pw_tabela_venda`, `pw_ordem`, `pw_ordem_reporte`, `pw_saldo_estoque`, `pw_custo_reposicao_historico`, `pw_produto`.

Canonical join pattern (used almost everywhere):

```sql
from public.produto P
    inner join public.grupo  G on G.grupo = P.grupo
    inner join public.grupo1 S on S.subgrupo = P.subgrupo and S.grupo = P.grupo
```

Note `grupo1` must be joined on both `subgrupo` **and** `grupo`.

## Domain rules encoded in the queries

- **Product groups:** `grupo = 1` = urnas (finished goods, the main subject of sales/production reports); `grupo = 2` = intermediate manufactured components; `grupo = 3`, `999` and sometimes `429` are excluded as non-inventory. Raw materials (*insumos*) are `grupo not in (1,2,3,999)`. `produto.proorigem = 'F'` = fabricated, `'C'` = purchased.
- **Urna product code** is positional (16+ chars, filter `length(P.produto) >= 16`): chars 1-3 family, 5-6 size, 7-8 top finish, 9-10 color, 11-12 inner finish, 13-14 silk/fixtures, 15-16 handles. Each 2-char segment is decoded by joining `acabconf` on `amccodigo` with `amctipacab` = `'01'`…`'06'` respectively (see `produto/produtos por característica.sql`).
- **Stock movements (`toqmovi`):** `pritransac < 10` = inbound, `> 10` = outbound, 10 does not exist. Primary key is `(itecontrol, prisequen)`: `itecontrol` identifies the document and grows with `pridata` (it is the insertion sequence), `prisequen` is the line within it. `pridata` is a `date` with no time, so that pair is the only reliable way to order movements inside a day — a running balance must use it in both the window's `ORDER BY` and the query's, or the accumulated column is unreadable. A transfer between deposits puts both legs under one `itecontrol`, the outbound at `prisequen` 1 and the inbound at 500, so the pair also orders the legs correctly. A product's opening balance is in the table as transaction 6 (`ENTRADA ACERTO INVENTARIO`), which is why a running total from the first row reconciles against `pw_saldo_estoque` — see `estoque/movimento.sql`.
- **Deposits:** 1 and 4 are the finished-goods stock locations; raw materials (*insumos*) only move through 1 (*almoxarifado*) and 2 (*linha de produção*), and an insumo anywhere else is a data-entry error worth surfacing rather than filtering out. Deposit `99` is Mercado Livre and is normally excluded. Deposit `999` is the ERP's non-stock deposit, used to issue an invoice without moving stock — exclude it from any balance.
- **Order status strings** are literal Portuguese: sales `pedidovenda_status` in `'Pedido em Aberto'`, `'Atendido Parcial'`, `'Atendido Total'`, and `pedidovenda_situacao <> 'Cancelado'` to drop cancelled lines; production `ordem_status <> 'Encerr'` means open.
- **Promotional sales tables** (`pw_tabela_venda.tabelavenda_codigo_pk in ('004','035','042','031','045','075','056')`) count double toward sales targets (`valor_correto` column). The rule is duplicated in `vendas/relatório dinâmico.sql`, `vendas/vendas por período.sql` and `vendas/pedidos de vendas em aberto.sql` — change all three together. Data dictionary: `vendas/dicionário de dados - relatório dinâmico.md`.
- **BOM explosion** uses `WITH RECURSIVE` over `estrutur` capped at 10 levels; `estruturas/estrutura recursiva power bi.sql` is the cleanest version, `almoxarifado/insumos para produção.sql` wraps it in a `DO $$` block with a temp table to compute material needs for a day's production orders.
- Money formatting for Excel pt-BR is done in SQL via the `to_char(..., 'FM999,999,999,990.00')` + triple `replace` trick (swap `.` and `,`).

## Python helpers

`vendas/export_faturamentos.py` runs a `.sql` file (default `listagem faturamentos.sql`, which uses `%s` placeholders for start/end dates) and writes a `;`-separated, `utf-8-sig` CSV with pt-BR month/weekday columns. Connection comes from `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, `PGDATABASE` env vars; needs `pandas` and `psycopg2-binary`.

```
python "vendas/export_faturamentos.py" --sql "vendas/listagem faturamentos.sql" --out out.csv --start 2025-04-01 --end 2026-03-31
```

`run_sql.py` runs any `.sql` file (or a query passed inline) and prints the result as a table, for checking a query without opening a SQL client. Same env vars, except the password, which it expects in `%APPDATA%\postgresql\pgpass.conf` so it never reaches a command line. The session is opened read-only, so nothing run through it can write.

```
python run_sql.py --sql "estoque/movimento.sql" --tail 5
python run_sql.py --query "select count(*) from public.toqmovi"
```

`clientes/*.py` are one-off JSON→CSV cleanup scripts with hardcoded paths.

## Conventions when writing new queries

- Hard-coded dates, product codes and filters are normal — these are ad-hoc reports, and commented-out `where` clauses at the bottom of a file are kept as reusable variants. Don't "clean them up" unless asked.
- Alias every output column to a readable pt-BR name since the output goes straight to a spreadsheet. Default is `snake_case` (`produto_codigo`, `empresa_nome`); a few queries that feed an app use quoted `"camelCase"` aliases (`"pedidoId"`, `"qtdeSaldo"`) — match whichever style the file already uses.
- Prefer `pw_*` tables for transactional data and legacy tables for master data (`produto`, `grupo`, `grupo1`, `estrutur`).
