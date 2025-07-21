select
    op.ordem_produto_codigo_fk as codigo_produto,
    sum(op.ordem_qtde_digitada) as quantidade_total
from pw_ordem op
    inner join produto p on p.produto = op.ordem_produto_codigo_fk
    inner join grupo g on g.grupo = p.grupo
    inner join grupo1 s on s.subgrupo = p.subgrupo
        and s.grupo = p.grupo
where op.ordem_data_previsao = '2025-07-21'
group by op.ordem_produto_codigo_fk


select
    distinct op.ordem_produto_codigo_fk as codigo_produto
from pw_ordem op
    inner join produto p on p.produto = op.ordem_produto_codigo_fk
    inner join grupo g on g.grupo = p.grupo
    inner join grupo1 s on s.subgrupo = p.subgrupo
        and s.grupo = p.grupo
where op.ordem_data_previsao = '2025-07-21'
    and p.grupo = 1
group by op.ordem_produto_codigo_fk