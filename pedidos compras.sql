/*
Compra: data, num pedido;
De onde: empresa;
O que: produto, grupo, subgrupo, quantidade, valor unitario, valor total, desconto;
Como: tabela de venda, cond. pagamento;
*/

select
    c.pedidocompra_codigo_pk as pedido_codigo,
    c.pedidocompra_data_emissao as data_emissao,
    c.pedidocompra_empresa_codigo_fk as empresa_codigo,
    e.empresa_descricao as empresa,
    e.empresa_nome_fantasia as empresa_nome_fantasia,
    c.pedidocompra_produto_codigo_fk as produto_codigo,
    pr.pronome as produto_nome,
    pr.grupo as produto_grupo,
    g.grunome as produto_grupo_nome,
    pr.subgrupo as produto_subgrupo,
    s.subnome as produto_subgrupo_nome,
    c.pedidocompra_qtde_produto as qtde_pedido,
    c.pedidocompra_saldo_item as qtde_saldo,
    c.pedidocompra_valor_produto_unitario as valor_unitario,
    c.pedidocompra_valor_produto_total as valor_total,
    c.pedidocompra_situacao as situacao,
    c.pedidocompra_status as status_compra
from public.pw_pedido_compra c
    inner join public.produto pr on pr.produto = c.pedidocompra_produto_codigo_fk
    left join public.grupo g on g.grupo = pr.grupo
    left join public.grupo1 s on s.subgrupo = pr.subgrupo
        and s.grupo = pr.grupo
    inner join public.pw_empresa e on e.empresa_codigo_pk = c.pedidocompra_empresa_codigo_fk

where c.pedidocompra_status <> 'Atendido Total'


--select * from public.grupo1