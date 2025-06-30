with date_series as (
    select generate_series(
        '2025-06-26'::date,
        '2025-06-26'::date,
        '1 day'::interval
    )::date as date
)
select 
    d.date as faturamento_data_faturamento,
    coalesce(sum(T0.faturamento_qtde_produto), 0) as faturamento_qtde_produto,
    coalesce(sum(T0.faturamento_valor_total), 0) as faturamento_valor_total
from date_series d
left join (
        select * from public.pw_faturamento inner join public.produto p on p.produto = faturamento_produto_codigo_fk
        where p.grupo = 1
    ) T0 on d.date = T0.faturamento_data_faturamento
group by d.date
order by d.date;

-- select * from public.pw_faturamento inner join public.produto p on p.produto = i.faturamento_produto_codigo_fk
-- where p.grupo = 1