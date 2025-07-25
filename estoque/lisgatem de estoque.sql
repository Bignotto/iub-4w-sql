select
    e.saldoestoque_deposito_codigo_fk as codigo_deposito,
    e.saldoestoque_produto_codigo_fk as insumo_codigo,
    p.pronome as insumo_nome,
    e.saldoestoque_qtde_saldo_estoque as estoque_atual

from pw_saldo_estoque e
    inner join produto p on p.produto = e.saldoestoque_produto_codigo_fk
    inner join grupo g on g.grupo = p.grupo
    -- inner join grupo1 s on s.subgrupo = p.subgrupo
    --     and s.grupo = p.grupo

where e.saldoestoque_qtde_saldo_estoque > 0
    and p.grupo not in (1,2,3,999)
    --and e.saldoestoque_deposito_codigo_fk = 2