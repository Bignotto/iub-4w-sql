
select
    c.pedidocompra_produto_codigo_fk as insumo_codigo,
    sum(c.pedidocompra_saldo_item) as quantidade_em_pedido,
    sum(c.pedidocompra_valor_produto_total) as valor_total
from public.pw_pedido_compra c
    inner join public.produto pr on pr.produto = c.pedidocompra_produto_codigo_fk
    left join public.grupo g on g.grupo = pr.grupo

where c.pedidocompra_status <> 'Atendido Total'

group by c.pedidocompra_produto_codigo_fk
--select * from public.grupo1