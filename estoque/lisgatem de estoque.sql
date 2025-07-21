select
    e.saldoestoque_deposito_codigo_fk as codigo_deposito,
    g.grunome as nome_grupo,
    s.subnome as nome_subgrupo,
    e.saldoestoque_produto_codigo_fk as codigo_produto,
    p.pronome as nome_produto,
    e.saldoestoque_qtde_saldo_estoque as quantidade_saldo

from pw_saldo_estoque e
    inner join produto p on p.produto = e.saldoestoque_produto_codigo_fk
    inner join grupo g on g.grupo = p.grupo
    inner join grupo1 s on s.subgrupo = p.subgrupo
        and s.grupo = p.grupo

where e.saldoestoque_deposito_codigo_fk = 2
    and e.saldoestoque_qtde_saldo_estoque > 0
limit 100;