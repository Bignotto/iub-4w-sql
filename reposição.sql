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