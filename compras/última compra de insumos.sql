select
    distinct c.compra_produto_codigo_fk as insumo_codigo,
    max(c.compra_nf_numero) ultima_nota_numero,
    max((c.compra_valor_total - c.compra_valor_ipi - c.compra_valor_icms - c.compra_valor_pis - c.compra_valor_cofins) / c.compra_qtde_produto) as ultimo_custo_unitario,
    max(c.compra_valor_total / c.compra_qtde_produto) as ultimo_valor_unitario
from pw_compra c
    inner join produto p on p.produto = c.compra_produto_codigo_fk

where c.compra_data_emissao --últimos 6 meses
    between (current_date - interval '12 months') and current_date
    and p.grupo not in (1,2,3)
    and c.compra_qtde_produto > 0
    and c.compra_produto_codigo_fk = '2130008'
    --and c.compra_nf_controle_pk = 30077
   --and c.compra_nf_numero = '34948'

group by c.compra_produto_codigo_fk

-- select * from pw_compra where compra_data_emissao --últimos 6 meses
--     between (current_date - interval '6 months') and current_date


-- select *
-- from pw_compra
-- where compra_nf_numero = '34948'; 
select
    distinct c.compra_produto_codigo_fk as insumo_codigo,
    max(c.compra_nf_numero) ultima_nota_numero
from pw_compra c
    inner join produto p on p.produto = c.compra_produto_codigo_fk

where c.compra_data_emissao --últimos 6 meses
    between (current_date - interval '12 months') and current_date
    and p.grupo not in (1,2,3)
    and c.compra_qtde_produto > 0

group by c.compra_produto_codigo_fk