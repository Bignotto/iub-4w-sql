with RankedPurchases as (
    select 
        NE.compra_produto_codigo_fk,
        (NE.compra_valor_total - NE.compra_valor_ipi - NE.compra_valor_icms - NE.compra_valor_pis - NE.compra_valor_cofins) / NE.compra_qtde_produto as ultimo_custo_unitario,
        NE.compra_valor_total / NE.compra_qtde_produto as ultimo_valor_unitario,
        NE.compra_data_entrada,
        ROW_NUMBER() OVER(PARTITION BY NE.compra_produto_codigo_fk ORDER BY NE.compra_data_entrada DESC) as rn
    from pw_compra NE
        inner join produto p on p.produto = NE.compra_produto_codigo_fk
    where NE.compra_qtde_produto > 0
    and p.grupo not in (1,2,3)
    and NE.compra_data_entrada between (current_date - interval '6 months') and current_date
)
select *
from RankedPurchases
where rn = 1
