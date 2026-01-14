select
    p.pedidovenda_codigo_pk as pedido_codigo,
    p.pedidovenda_data_emissao as data_emissao,
    p.pedidovenda_produto_codigo_fk as produto_codigo,
    p.pedidovenda_qtde_saldo_produto as quantidade_saldo,
    p.pedidovenda_qtde_produto as quantidade,
    p.pedidovenda_valor_produto_unitario as valor_unitario,
    p.pedidovenda_valor_produto_total as valor_total,
    p.pedidovenda_valor_produto_desconto as valor_desconto,
    p.pedidovenda_situacao as situacao,
    p.pedidovenda_status as pedido_status,
    e.empresa_descricao as empresa,
    e.empresa_nome_fantasia as empresa_nome_fantasia,
    e.empresa_codigo_pk as empresa_codigo,
    tab.tabelavenda_descricao as tabela_venda,
    p.pedidovenda_lotecarga_codigo_fk as lote_carga_codigo
from public.pw_pedido_venda p
    inner join public.produto pr on pr.produto = p.pedidovenda_produto_codigo_fk
    inner join public.pw_empresa e on e.empresa_codigo_pk = p.pedidovenda_empresa_codigo_fk
    inner join public.pw_tabela_venda tab on tab.tabelavenda_codigo_pk = p.pedidovenda_tabelavenda_codigo_fk
    
where pr.grupo = 1 -- grupo 1 = urnas
    and p.pedidovenda_data_emissao >= '2025-01-01'

order by p.pedidovenda_data_emissao desc


--select * from public.pw_empresa