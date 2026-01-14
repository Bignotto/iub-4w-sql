select
    NE.compra_nf_controle_pk as nota_entrada_codigo,
    NE.compra_nf_numero as nota_entrada_numero,
    NE.compra_data_emissao as nota_entrada_data_emissao,
    NE.compra_data_entrada as nota_entrada_data_entrada,

    NE.compra_empresa_codigo_fk as empresa_codigo,
    E.empcgc as empresa_cnpj,
    E.empnome as empresa_nome,
    C.cidade_descricao as empresa_cidade,
    C.cidade_estado_codigo_fk as empresa_estado,
    C.cidade_ibge as empresa_ibge,

    NE.compra_cfop_codigo_fk as cfop_codigo,
    NE.compra_produto_codigo_fk as produto_codigo,
    NE.compra_unidade_medida as unidade,
    P.pronome as produto_nome,
    G.grupo AS produto_grupo,
    G.grunome AS produto_grupo_nome,
    S.subgrupo AS produto_subgrupo,
    S.subnome AS produto_subgrupo_nome,
    ROUND(NE.compra_qtde_produto::numeric, 4) as qtde_entrada,
    ROUND(NE.compra_valor_total::numeric, 2) as valor_total,
    ROUND((NE.compra_valor_total::numeric / NULLIF(NE.compra_qtde_produto, 0)), 2) as valor_unitario

from public.pw_compra NE
    inner join empresa E on E.empresa = NE.compra_empresa_codigo_fk
    inner join pw_cidade C on C.cidade_codigo_pk = E.empcidade

    inner join produto P on P.produto = NE.compra_produto_codigo_fk
    inner join grupo G on G.grupo = P.grupo
    inner join grupo1 S on S.subgrupo = P.subgrupo
        and S.grupo = P.grupo
where NE.compra_data_entrada >= '2025-11-01'
  and NE.compra_data_entrada <= '2025-11-30'
