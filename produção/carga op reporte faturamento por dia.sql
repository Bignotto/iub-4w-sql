select * from (

select 
    T0.pedidovenda_produto_codigo_fk as produto_codigo,
    T0.pedidovenda_qtde_produto,
    T0.pedidovenda_qtde_saldo_produto,
    T0.pedidovenda_status,
    LC.lcacod as lote_carga_codigo,
    LC.lcades as lote_carga_descricao,
    LC.lcaprev as lote_carga_data_prevista
from public.pw_pedido_venda T0
    left join public.lotecar LC on LC.lcacod = T0.pedidovenda_lotecarga_codigo_fk
--inner join public.

where LC.lcaprev = '2025-08-06'

) carga

full outer join (
    select 
    op.ordem_status as status,
    op.ordem_produto_codigo_fk as produto_codigo,
    op.ordem_data_emissao as data_emissao,
    op.ordem_data_previsao as data_previsao,
    op.ordem_qtde_digitada as quantidade_produzir

from pw_ordem op
    inner join produto p on p.produto = op.ordem_produto_codigo_fk
    inner join grupo g on g.grupo = p.grupo
    inner join grupo1 s on s.subgrupo = p.subgrupo
        and s.grupo = p.grupo

where op.ordem_data_previsao = '2025-08-07'
) ordem
on ordem.produto_codigo = carga.produto_codigo