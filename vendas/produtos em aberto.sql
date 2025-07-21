
select
    T0.pedidovenda_produto_codigo_fk,
    sum(T0.pedidovenda_qtde_saldo_produto) as total_saldo_produto
from public.pw_pedido_venda T0
    inner join public.produto P on P.produto = T0.pedidovenda_produto_codigo_fk
where T0.pedidovenda_status <> 'Atendido Total'
    AND P.grupo = 1 -- grupo 1 = urnas
    AND T0.pedidovenda_qtde_saldo_produto > 0
group by T0.pedidovenda_produto_codigo_fk
order by 2 desc;


select
    distinct T0.pedidovenda_produto_codigo_fk
from public.pw_pedido_venda T0
    inner join public.produto P on P.produto = T0.pedidovenda_produto_codigo_fk
where T0.pedidovenda_status <> 'Atendido Total'
    AND P.grupo = 1 -- grupo 1 = urnas
    AND T0.pedidovenda_qtde_saldo_produto > 0

