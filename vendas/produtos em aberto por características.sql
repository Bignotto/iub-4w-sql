
select
    T0.pedidovenda_codigo_pk,
    T0.pedidovenda_produto_codigo_fk,
    T0.pedidovenda_qtde_saldo_produto,
    SUBSTRING(T0.pedidovenda_produto_codigo_fk,1,3) AS pedidovenda_prod_familia,
    SUBSTRING(T0.pedidovenda_produto_codigo_fk, 5, 2) AS pedidovenda_prod_tamanho,
    TAM.amccompos "desc_tamanho",
    SUBSTRING(T0.pedidovenda_produto_codigo_fk, 7, 2) AS pedidovenda_prod_superior,
    SUP.amccompos "desc_acabamento_superior",
    SUBSTRING(T0.pedidovenda_produto_codigo_fk, 9, 2) AS pedidovenda_prod_cor,
    COR.amccompos "desc_cor",
    SUBSTRING(T0.pedidovenda_produto_codigo_fk, 11, 2) AS pedidovenda_prod_acab_interno,
    AIN.amccompos "desc_acab_interno",
    SUBSTRING(T0.pedidovenda_produto_codigo_fk, 13, 2) AS pedidovenda_prod_silk_fix,
    SFX.amccompos "desc_silk_fixadores",
    SUBSTRING(T0.pedidovenda_produto_codigo_fk, 15, 2) AS pedidovenda_prod_alcas,
    ALC.amccompos "desc_alcas"
from public.pw_pedido_venda T0
    inner join public.produto P on P.produto = T0.pedidovenda_produto_codigo_fk

    left join public.acabconf TAM on TAM.amccodigo = SUBSTRING(T0.pedidovenda_produto_codigo_fk, 5, 2)
        and TAM.amctipacab = '01'
    left join public.acabconf COR on COR.amccodigo = SUBSTRING(T0.pedidovenda_produto_codigo_fk, 9, 2)
        and COR.amctipacab = '02'
    left join public.acabconf SUP on SUP.amccodigo =SUBSTRING(T0.pedidovenda_produto_codigo_fk, 7, 2)
        and SUP.amctipacab = '03'
    left join public.acabconf AIN on AIN.amccodigo =SUBSTRING(T0.pedidovenda_produto_codigo_fk, 11, 2)
        and AIN.amctipacab = '04'
    left join public.acabconf SFX on SFX.amccodigo =SUBSTRING(T0.pedidovenda_produto_codigo_fk, 13, 2)
        and SFX.amctipacab = '05'
    left join public.acabconf ALC on ALC.amccodigo =SUBSTRING(T0.pedidovenda_produto_codigo_fk, 15, 2)
        and ALC.amctipacab = '06'

where EXTRACT(YEAR from T0.pedidovenda_data_emissao) = 2025
    -- and T0.pedidovenda_data_previsao >= CURRENT_DATE - INTERVAL '59 days'
    -- and T0.pedidovenda_data_previsao <= CURRENT_DATE
    and (T0.pedidovenda_status = 'Pedido em Aberto' OR T0.pedidovenda_status = 'Atendido Parcial')
    and T0.pedidovenda_qtde_saldo_produto > 0
    and P.grupo = 1
