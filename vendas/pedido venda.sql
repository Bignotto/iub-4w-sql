select
    T0.pedidovenda_produto_codigo_fk produto_codigo,
    T0.pedidovenda_qtde_saldo_produto as pedido_saldo_produto, *
from public.pw_pedido_venda T0
    inner join public.produto P on P.produto = T0.pedidovenda_produto_codigo_fk
where T0.pedidovenda_status <> 'Atendido Total'
    AND P.grupo = 1 -- grupo 1 = urnas
    AND T0.pedidovenda_qtde_saldo_produto > 0
    AND T0.pedidovenda_situacao = 'Aprovado'
    and T0.pedidovenda_codigo_pk = 3686

order by 2 desc
