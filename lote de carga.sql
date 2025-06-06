select 
    T0.pedidovenda_codigo_pk,
    T0.pedidovenda_produto_codigo_fk,
    T0.pedidovenda_qtde_produto,
    T0.pedidovenda_qtde_saldo_produto,
    T0.pedidovenda_status,
    LC.lcacod as lote_carga_codigo,
    LC.lcades as lote_carga_descricao,
    LC.lcaprev as lote_carga_data_prevista
from public.pw_pedido_venda T0
    left join public.lotecar LC on LC.lcacod = T0.pedidovenda_lotecarga_codigo_fk
--inner join public.

where LC.lcaprev = CURRENT_DATE


order by 1