select
    R0.ordemreporte_data_reporte,
    sum(R0.ordemreporte_qtde_reportada)
from public.pw_ordem_reporte R0
    inner join public.pw_ordem R1 on R1.ordem_codigo_pk = R0.ordemreporte_ordem_codigo_fk
    inner join public.produto P on P.produto = R1.ordem_produto_codigo_fk
where EXTRACT(MONTH from R0.ordemreporte_data_reporte) = 4
    and P.grupo = 1

group by R0.ordemreporte_data_reporte

LIMIT 1000