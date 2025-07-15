select 
    p.pedidovenda_produto_codigo_fk as produto_codigo,
    sum(p.pedidovenda_qtde_saldo_produto) as quantidade_aberto

from public.pw_pedido_venda p
    inner join public.produto pr on pr.produto = p.pedidovenda_produto_codigo_fk
    
where p.pedidovenda_status <> 'Atendido Total'
    AND pr.grupo = 1 -- grupo 1 = urnas
group by p.pedidovenda_produto_codigo_fk
order by sum(p.pedidovenda_qtde_saldo_produto) desc;

select 
    distinct p.pedidovenda_produto_codigo_fk as produto_codigo

from public.pw_pedido_venda p
    inner join public.produto pr on pr.produto = p.pedidovenda_produto_codigo_fk
    
where p.pedidovenda_status <> 'Atendido Total'
    AND pr.grupo = 1 -- grupo 1 = urnas
