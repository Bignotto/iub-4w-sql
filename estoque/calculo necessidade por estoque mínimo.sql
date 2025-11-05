select
    P.produto AS insumo_codigo,
    P.pronome AS insumo_nome,
    G.grupo AS insumo_grupo,
    G.grunome AS insumo_grupo_nome,
    S.subgrupo AS insumo_subgrupo,
    S.subnome AS insumo_subgrupo_nome,
    P.proorigem AS insumo_origem,
    P.prosldmin AS estoque_minimo,
    P.prosldmax AS estoque_maximo,
    P.prolotmax AS lote_maximo,
    P.proloteco AS lote_economico,
    P.prolotmul as lote_multiplo,
    P.unimedida AS unidade_medida,
    coalesce(I.estoque_atual,0) AS estoque_atual,
    case 
        when I.estoque_atual < P.prosldmin then 'S'
        else 'N'
    end as abaixo_estoque_minimo,

    case
        when proloteco = 0 then 0
        else (P.prosldmin - coalesce(I.estoque_atual,0)) / P.proloteco
    end as quantidade_lotes,

    case
        when proloteco = 0 then 0
        else CEILING((P.prosldmin - coalesce(I.estoque_atual,0))/P.proloteco) * P.proloteco
    end as quantidade_repor
from public.produto P 
    inner join public.grupo G on G.grupo = P.grupo
    inner join public.grupo1 S on S.subgrupo = P.subgrupo
        and S.grupo = P.grupo

    left join (
        select
            e.saldoestoque_produto_codigo_fk as insumo_codigo,
            sum(e.saldoestoque_qtde_saldo_estoque) as estoque_atual

        from pw_saldo_estoque e
            inner join produto p on p.produto = e.saldoestoque_produto_codigo_fk
            inner join grupo g on g.grupo = p.grupo

        where e.saldoestoque_qtde_saldo_estoque > 0
            and p.grupo not in (1,2,3,999)

        group by e.saldoestoque_produto_codigo_fk
        having sum(e.saldoestoque_qtde_saldo_estoque) > 0
    ) I on I.insumo_codigo = P.produto

where P.proorigem in ('F')
    and P.grupo not in (1,2,3,999)


