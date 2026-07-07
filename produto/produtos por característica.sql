
select
    P.produto AS produto_codigo,
    SUBSTRING(P.pronome,1,6) AS curto_codigo,
    P.pronome AS produto_nome,
    G.grupo AS produto_grupo,
    G.grunome AS produto_grupo_nome,
    S.subgrupo AS produto_subgrupo,
    S.subnome AS produto_subgrupo_nome,
    SUBSTRING(P.produto,1,3) AS pedidovenda_prod_familia,
    SUBSTRING(P.produto, 5, 2) AS pedidovenda_prod_tamanho,
    TAM.amccompos "desc_tamanho",
    SUBSTRING(P.produto, 7, 2) AS pedidovenda_prod_superior,
    SUP.amccompos "desc_acabamento_superior",
    SUBSTRING(P.produto, 9, 2) AS pedidovenda_prod_cor,
    COR.amccompos "desc_cor",
    SUBSTRING(P.produto, 11, 2) AS pedidovenda_prod_acab_interno,
    AIN.amccompos "desc_acab_interno",
    SUBSTRING(P.produto, 13, 2) AS pedidovenda_prod_silk_fix,
    SFX.amccompos "desc_silk_fixadores",
    SUBSTRING(P.produto, 15, 2) AS pedidovenda_prod_alcas,
    ALC.amccompos "desc_alcas",
    CR.custo_reposicao,
    CR.data_custo_reposicao
from public.produto P 
    inner join public.grupo G on G.grupo = P.grupo
    inner join public.grupo1 S on S.subgrupo = P.subgrupo
        and S.grupo = P.grupo
    
    inner join (
select
    P.produto AS produto_codigo,
    P.pronome AS produto_nome,
    P.proean128 AS produto_sku,
    COALESCE(
        replace(
            replace(
                replace(
                    to_char(MAX(CR.custoreposicaohistorico_custo_reposicao)::numeric, 'FM999,999,999,990.00'),
                '.', '_DOT_'),
            ',', '.'),
        '_DOT_', ','),
        '0,00'
    ) AS custo_reposicao,
    max(CR.custoreposicaohistorico_data) AS data_custo_reposicao

from pw_custo_reposicao_historico CR
    inner join produto P on P.produto = CR.custoreposicaohistorico_produto_codigo_fk

    inner join (
        select
            CR.custoreposicaohistorico_produto_codigo_fk produto,
            max(CR.custoreposicaohistorico_data) as data_atualizacao
        from pw_custo_reposicao_historico CR
            inner join produto P on P.produto = CR.custoreposicaohistorico_produto_codigo_fk
        where P.grupo = 1 and length(P.produto)>=16

        group by CR.custoreposicaohistorico_produto_codigo_fk
    ) MX on MX.produto = CR.custoreposicaohistorico_produto_codigo_fk
        and MX.data_atualizacao = CR.custoreposicaohistorico_data

where P.grupo = 1 and length(P.produto)>=16

group by     P.produto, P.pronome, P.proean128
    ) CR on CR.produto_codigo = P.produto

    left join public.acabconf TAM on TAM.amccodigo = SUBSTRING(P.produto, 5, 2)
        and TAM.amctipacab = '01'
    left join public.acabconf COR on COR.amccodigo = SUBSTRING(P.produto, 9, 2)
        and COR.amctipacab = '02'
    left join public.acabconf SUP on SUP.amccodigo =SUBSTRING(P.produto, 7, 2)
        and SUP.amctipacab = '03'
    left join public.acabconf AIN on AIN.amccodigo =SUBSTRING(P.produto, 11, 2)
        and AIN.amctipacab = '04'
    left join public.acabconf SFX on SFX.amccodigo =SUBSTRING(P.produto, 13, 2)
        and SFX.amctipacab = '05'
    left join public.acabconf ALC on ALC.amccodigo =SUBSTRING(P.produto, 15, 2)
        and ALC.amctipacab = '06'

where P.grupo = 1
    and length(P.produto)>=16
