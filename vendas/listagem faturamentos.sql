select 
    --count(distinct FAT.faturamento_nf_numero)
    FAT.faturamento_nf_numero,
    FAT.faturamento_data_faturamento,
    FAT.faturamento_empresa_codigo_fk,
    FAT.faturamento_produto_codigo_fk,
    FAT.faturamento_qtde_produto,
    FAT.faturamento_valor_total,
    FAT.faturamento_valor_desconto,
    FAT.faturamento_tabela_preco_item_codigo_fk,
    FAT.faturamento_tabela_venda_codigo_fk,
    FAT.faturamento_cfop_codigo_fk,
    P.produto,
    P.pronome as produto_nome,
    P.grupo,
    G.grunome as grupo_nome,
    P.subgrupo,
    S.subnome as subgrupo_nome,
    E.empresa,
    E.empnome as empresa_nome,
    C.cidnome as cidade_nome,
    C.estado as cidade_estado,
    C.cidibge as cidade_ibge
from public.pw_faturamento FAT
    inner join public.produto P on P.produto = FAT.faturamento_produto_codigo_fk
    inner join public.grupo G on G.grupo = P.grupo
    inner join public.grupo1 S on S.subgrupo = P.subgrupo and S.grupo = P.grupo

    left join public.empresa E on E.empresa = FAT.faturamento_empresa_codigo_fk
    left join public.cidade C on C.cidade = E.empcidade
where FAT.faturamento_data_faturamento >= %s
  and FAT.faturamento_data_faturamento <= %s





--   and FAT.faturamento_produto_codigo_fk in (
--     select produto from public.produto where grupo = 1
--   );

