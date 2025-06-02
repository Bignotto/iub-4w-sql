with date_series as (
    select generate_series(
        '2025-05-01'::date,
        '2025-05-31'::date,
        '1 day'::interval
    )::date as date
)
select
    d.date as ordemreporte_data_reporte,
    coalesce(sum(R0.ordemreporte_qtde_reportada), 0) as ordemreporte_qtde_reportada
from date_series d
    left join public.pw_ordem_reporte R0 on d.date = R0.ordemreporte_data_reporte
    left join (
        select * from public.pw_ordem R1 on R1.ordem_codigo_pk = R0.ordemreporte_ordem_codigo_fk
        inner join public.produto P on P.produto = R1.ordem_produto_codigo_fk
        where P.grupo = 1
    ) T0 on d.date = T0.ordemreporte_data_reporte

group by d.date
