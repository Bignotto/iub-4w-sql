with date_series as (
    select generate_series(
        '2025-06-27'::date,
        '2025-06-30'::date,
        '1 day'::interval
    )::date as date
)
select
    d.date as serie_date,
    coalesce(sum(R0.qtde_reportada), 0) as qtde_reportada
    --R0.produto,
    --R0.qtde_reportada
from date_series d
    left join (
        select
            R0.ordemreporte_data_reporte as data_reporte,
            P.produto as produto,
            R0.ordemreporte_qtde_reportada as qtde_reportada
        from public.pw_ordem_reporte R0
            inner join public.pw_ordem R1 on R1.ordem_codigo_pk = R0.ordemreporte_ordem_codigo_fk
            inner join public.produto P on P.produto = R1.ordem_produto_codigo_fk
                and P.grupo = 1
    ) R0 on R0.data_reporte = d.date
group by d.date
order by d.date;