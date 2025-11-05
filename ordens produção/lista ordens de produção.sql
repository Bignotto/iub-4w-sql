select 
    op.ordem_codigo_pk as orgem_codigo,
    op.ordem_tipo_ordem_fk as ordem_tipo,
    op.ordem_lote_producao_codigo_fk as lote_producao,
    op.ordem_status as status,
    op.ordem_produto_codigo_fk as produto_codigo,
    p.pronome as produto_nome,
    g.grupo as produto_grupo,
    g.grunome as produto_grupo_nome,
    s.subgrupo as produto_subgrupo,
    s.subnome as produto_subgrupo_nome,
    op.ordem_deposito_codigo_fk as deposito_codigo,
    op.ordem_data_emissao as data_emissao,
    op.ordem_data_previsao as data_previsao,
    op.ordem_data_encerramento as data_encerramento,
    op.ordem_qtde_digitada as quantidade_produzir

from pw_ordem op
    inner join produto p on p.produto = op.ordem_produto_codigo_fk
    inner join grupo g on g.grupo = p.grupo
    inner join grupo1 s on s.subgrupo = p.subgrupo
        and s.grupo = p.grupo

where op.ordem_status <> 'Encerr'
    and p.grupo = 1

order by op.ordem_data_previsao desc