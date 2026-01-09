-- select
--     distinct c.compra_produto_codigo_fk as insumo_codigo,
--     max(c.compra_nf_numero) ultima_nota_numero,
--     max((c.compra_valor_total - c.compra_valor_ipi - c.compra_valor_icms - c.compra_valor_pis - c.compra_valor_cofins) / c.compra_qtde_produto) as ultimo_custo_unitario,
--     max(c.compra_valor_total / c.compra_qtde_produto) as ultimo_valor_unitario
-- from pw_compra c
--     inner join produto p on p.produto = c.compra_produto_codigo_fk

-- where c.compra_data_emissao --últimos 6 meses
--     between (current_date - interval '12 months') and current_date
--     and p.grupo not in (1,2,3)
--     and c.compra_qtde_produto > 0
-- group by c.compra_produto_codigo_fk
    
    
    
    --and c.compra_produto_codigo_fk = '2130008'
    --and c.compra_nf_controle_pk = 30077
   --and c.compra_nf_numero = '34948'


select
    distinct c.compra_produto_codigo_fk as insumo_codigo,
    c.compra_nf_numero ultima_nota_numero,
    round((c.compra_valor_total - c.compra_valor_ipi - c.compra_valor_icms - c.compra_valor_pis - c.compra_valor_cofins) / c.compra_qtde_produto,2) as ultimo_custo_unitario,
    round((c.compra_valor_total / c.compra_qtde_produto),2) as ultimo_valor_unitario
from pw_compra C
    inner join (

        select
            distinct c.compra_produto_codigo_fk as insumo_codigo,
            max(c.compra_nf_numero) ultima_nota_numero
        from pw_compra c
            inner join produto p on p.produto = c.compra_produto_codigo_fk

        where c.compra_data_emissao --últimos 6 meses
            between (current_date - interval '12 months') and current_date
            and p.grupo not in (1,2,3,999)
            and c.compra_qtde_produto > 0

        group by c.compra_produto_codigo_fk

    ) as ultimas_compras on ultimas_compras.ultima_nota_numero = C.compra_nf_numero
    and ultimas_compras.insumo_codigo = C.compra_produto_codigo_fk