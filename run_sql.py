"""Roda um arquivo .sql (ou uma query solta) e imprime o resultado como tabela.

Serve para conferir uma consulta rapidamente sem abrir o cliente SQL. Para exportar
faturamento em CSV continue usando vendas/export_faturamentos.py.

A conexão vem das variáveis de ambiente PGHOST, PGPORT, PGUSER, PGDATABASE e da senha
em %APPDATA%\\postgresql\\pgpass.conf (formato host:porta:banco:usuario:senha). Como a
libpq lê esse arquivo sozinha, a senha nunca precisa aparecer em linha de comando.

A sessão é aberta como somente-leitura de propósito: nenhuma query rodada por aqui
consegue escrever, mesmo com um usuário que teria permissão.

    python run_sql.py --sql "estoque/movimento.sql" --tail 5
    python run_sql.py --query "select count(*) from public.toqmovi"
    python run_sql.py --sql "estoque/movimento diário.sql" --csv saldo.csv
"""

import argparse
import csv
import sys

import psycopg2

LARGURA_PADRAO = 40


def formata(valor, largura):
    texto = "" if valor is None else str(valor)
    return texto[: largura - 1] + "…" if len(texto) > largura else texto


def imprime_tabela(colunas, linhas, largura, total, truncado):
    tabela = [list(colunas)] + [[formata(v, largura) for v in l] for l in linhas]
    larguras = [max(len(l[i]) for l in tabela) for i in range(len(colunas))]

    print(" | ".join(c.ljust(larguras[i]) for i, c in enumerate(colunas)))
    print("-+-".join("-" * w for w in larguras))
    for linha in tabela[1:]:
        print(" | ".join(v.ljust(larguras[i]) for i, v in enumerate(linha)))
    print(f"\n({total} linhas{' — truncado' if truncado else ''})")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--sql", help="caminho de um arquivo .sql")
    ap.add_argument("--query", help="SQL direto na linha de comando")
    ap.add_argument("--max-rows", type=int, default=60, help="teto de linhas impressas")
    ap.add_argument("--tail", type=int, default=0, help="imprime só as N primeiras e N últimas")
    ap.add_argument("--max-width", type=int, default=LARGURA_PADRAO, help="largura máxima por coluna")
    ap.add_argument("--csv", help="grava o resultado completo em CSV (;, utf-8-sig) em vez de imprimir")
    args = ap.parse_args()

    if args.sql:
        with open(args.sql, encoding="utf-8") as arquivo:
            sql = arquivo.read()
    elif args.query:
        sql = args.query
    else:
        sql = sys.stdin.read()

    conn = psycopg2.connect()
    conn.set_session(readonly=True, autocommit=True)
    cur = conn.cursor()
    cur.execute(sql)

    if cur.description is None:
        print("(sem resultado)")
        return

    colunas = [d[0] for d in cur.description]

    if args.csv:
        with open(args.csv, "w", newline="", encoding="utf-8-sig") as saida:
            writer = csv.writer(saida, delimiter=";")
            writer.writerow(colunas)
            total = 0
            while True:
                lote = cur.fetchmany(5000)
                if not lote:
                    break
                writer.writerows(lote)
                total += len(lote)
        print(f"{total} linhas gravadas em {args.csv}")
        return

    if args.tail:
        todas = cur.fetchall()
        n = args.tail
        if len(todas) > 2 * n:
            linhas = todas[:n] + [tuple("..." for _ in colunas)] + todas[-n:]
        else:
            linhas = todas
        imprime_tabela(colunas, linhas, args.max_width, len(todas), False)
    else:
        linhas = cur.fetchmany(args.max_rows + 1)
        truncado = len(linhas) > args.max_rows
        linhas = linhas[: args.max_rows]
        imprime_tabela(colunas, linhas, args.max_width, len(linhas), truncado)


if __name__ == "__main__":
    main()
