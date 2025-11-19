/*

select
    SE.saldoestoque_produto_codigo_fk,
    SE.saldoestoque_qtde_saldo_estoque
from pw_saldo_estoque as SE
    inner join pw_produto as P on P.produto_codigo_pk = SE.saldoestoque_produto_codigo_fk

where SE.saldoestoque_deposito_codigo_fk = 1
    and P.produto_grupo_produto_codigo_fk = 1
    and SE.saldoestoque_qtde_saldo_estoque > 0


select 
    T0.pedidovenda_produto_codigo_fk,
    sum(T0.pedidovenda_qtde_saldo_produto) as qtde_saldo_pedidos
from public.pw_pedido_venda T0
    left join public.lotecar LC on LC.lcacod = T0.pedidovenda_lotecarga_codigo_fk
--inner join public.

where LC.lcaprev >= CURRENT_DATE
    and T0.pedidovenda_status = 'Pedido em Aberto'

group by T0.pedidovenda_produto_codigo_fk
*/

select
    p.pedidovenda_produto_codigo_fk as produto_codigo,
    sum(p.pedidovenda_qtde_saldo_produto)::integer as quantidade_pedido_venda,
    coalesce(rota.qtde_saldo_pedidos, 0)::integer as quantidade_rotas,
    coalesce(estoque.saldoestoque_qtde_saldo_estoque, 0)::integer as quantidade_estoque1,
    coalesce(estoque4.saldoestoque_qtde_saldo_estoque, 0)::integer as quantidade_estoque4
from public.pw_pedido_venda p
    inner join public.produto pr on pr.produto = p.pedidovenda_produto_codigo_fk

    left join (
        select
            SE.saldoestoque_produto_codigo_fk,
            SE.saldoestoque_qtde_saldo_estoque::integer
        from pw_saldo_estoque as SE
            inner join pw_produto as P on P.produto_codigo_pk = SE.saldoestoque_produto_codigo_fk

        where SE.saldoestoque_deposito_codigo_fk = 1
            and P.produto_grupo_produto_codigo_fk = 1
            and SE.saldoestoque_qtde_saldo_estoque > 0
    ) estoque on estoque.saldoestoque_produto_codigo_fk = p.pedidovenda_produto_codigo_fk

    left join (
        select
            SE.saldoestoque_produto_codigo_fk,
            SE.saldoestoque_qtde_saldo_estoque::integer
        from pw_saldo_estoque as SE
            inner join pw_produto as P on P.produto_codigo_pk = SE.saldoestoque_produto_codigo_fk

        where SE.saldoestoque_deposito_codigo_fk = 4
            and P.produto_grupo_produto_codigo_fk = 1
            and SE.saldoestoque_qtde_saldo_estoque > 0
    ) estoque4 on estoque4.saldoestoque_produto_codigo_fk = p.pedidovenda_produto_codigo_fk

    left join (
        select 
            T0.pedidovenda_produto_codigo_fk,
            sum(T0.pedidovenda_qtde_saldo_produto)::integer as qtde_saldo_pedidos
        from public.pw_pedido_venda T0
            left join public.lotecar LC on LC.lcacod = T0.pedidovenda_lotecarga_codigo_fk
        --inner join public.

        where LC.lcaprev >= CURRENT_DATE
            and T0.pedidovenda_status <> 'Atendido Total'

        group by T0.pedidovenda_produto_codigo_fk
    ) rota on rota.pedidovenda_produto_codigo_fk = p.pedidovenda_produto_codigo_fk
    
where p.pedidovenda_status <> 'Atendido Total'
    AND pr.grupo = 1 -- grupo 1 = urnas

group by p.pedidovenda_produto_codigo_fk,
    estoque.saldoestoque_qtde_saldo_estoque,
    estoque4.saldoestoque_qtde_saldo_estoque,
    rota.qtde_saldo_pedidos