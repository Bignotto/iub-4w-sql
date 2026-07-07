"""
Export faturamentos to CSV with column fixes.

Usage:
  - Set environment variables: PGHOST, PGPORT, PGUSER, PGPASSWORD, PGDATABASE
  - Optionally pass SQL file path, output file and date range:
      python export_faturamentos.py --sql "vendas/listagem faturamentos.sql" \
        --out out.csv --start 2025-04-01 --end 2026-03-31

Dependencies: pandas, psycopg2-binary
Install with: pip install pandas psycopg2-binary
"""

import os
import argparse
import pandas as pd
import psycopg2
from psycopg2 import sql

DEFAULT_START = '2025-04-01'
DEFAULT_END = '2026-03-31'

DEFAULT_SQL_PATH = os.path.join(os.path.dirname(__file__), 'listagem faturamentos.sql')


def load_query_from_file(path: str) -> str:
    if not os.path.isfile(path):
        raise SystemExit(f'SQL file not found: {path}')
    with open(path, 'r', encoding='utf-8') as f:
        query = f.read()
    return query


def get_connection_from_env():
    params = {
        'host': os.environ.get('PGHOST', 'localhost'),
        'port': int(os.environ.get('PGPORT', 5432)),
        'user': os.environ.get('PGUSER', None),
        'password': os.environ.get('PGPASSWORD', None),
        'dbname': os.environ.get('PGDATABASE', None),
    }
    missing = [k for k, v in params.items() if v in (None, '')]
    if missing:
        raise SystemExit(f"Missing required environment variables for DB connection: {missing}")
    return psycopg2.connect(**params)


def main():
    parser = argparse.ArgumentParser(description='Export faturamentos to CSV with type fixes')
    parser.add_argument('--out', '-o', default='faturamentos_export.csv', help='Output CSV file path')
    parser.add_argument('--start', default=DEFAULT_START, help='Start date (inclusive)')
    parser.add_argument('--end', default=DEFAULT_END, help='End date (inclusive)')
    parser.add_argument('--sql', default=DEFAULT_SQL_PATH, help='Path to SQL file to execute')
    args = parser.parse_args()

    conn = get_connection_from_env()
    try:
        query = load_query_from_file(args.sql)
        df = pd.read_sql_query(query, conn, params=(args.start, args.end))

        # Ensure dtypes in pandas
        df['faturamento_produto_codigo_fk'] = df['faturamento_produto_codigo_fk'].astype(str)
        numeric_cols = ['faturamento_qtde_produto', 'faturamento_valor_total', 'faturamento_valor_desconto']
        for c in numeric_cols:
            # Normalize commas to dots and coerce to numeric
            series = df[c].astype(str).str.replace(',', '.', regex=False).str.strip()
            series = series.mask(series == '')
            df[c] = pd.to_numeric(series, errors='coerce')

        # Derived date columns (PT-BR)
        date_series = pd.to_datetime(df['faturamento_data_faturamento'], errors='coerce')
        meses_ptbr = {
            1: 'Janeiro', 2: 'Fevereiro', 3: 'Março', 4: 'Abril', 5: 'Maio', 6: 'Junho',
            7: 'Julho', 8: 'Agosto', 9: 'Setembro', 10: 'Outubro', 11: 'Novembro', 12: 'Dezembro'
        }
        dias_semana_ptbr = ['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado', 'Domingo']

        # AnoMês as YYYY-MM
        df['AnoMês'] = date_series.dt.strftime('%Y-%m')

        # Day of week in PT-BR
        df['DiaSemana'] = date_series.dt.weekday.map(dict(enumerate(dias_semana_ptbr)))

        # AnoMêsExtenso as "YYYY-MM <Nome do mês>"
        def _fmt_anomes_extenso(d):
            if pd.isna(d):
                return None
            return f"{d.year:04d}-{d.month:02d} {meses_ptbr.get(d.month, '')}"

        df['AnoMêsExtenso'] = date_series.apply(_fmt_anomes_extenso)

        # Write CSV
        df.to_csv(args.out, index=False, float_format='%.6f', sep=';', encoding='utf-8-sig')
        print(f'Wrote {len(df)} rows to {args.out}')
    finally:
        conn.close()


if __name__ == '__main__':
    main()
