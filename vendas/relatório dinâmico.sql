select 
    --count(distinct FAT.faturamento_nf_numero)
    FAT.faturamento_nf_numero,
    to_char(FAT.faturamento_data_faturamento, 'DD/MM/YYYY') as faturamento_data_faturamento,
    to_char(FAT.faturamento_data_faturamento, 'YYYY-MM') as faturamento_ano_mes,
    FAT.faturamento_empresa_codigo_fk,
    E.empresa_cnpj_cpf,
    E.empresa_descricao,
    FAT.faturamento_produto_codigo_fk::text,
    FAT.faturamento_qtde_produto,
    FAT.faturamento_valor_total,
    FAT.faturamento_valor_desconto,
    round(
        case when FAT.faturamento_qtde_produto <> 0
             then FAT.faturamento_valor_total / FAT.faturamento_qtde_produto
             else null
        end, 4
    ) as faturamento_valor_unitario,
    FAT.faturamento_tabela_preco_item_codigo_fk::text,
    FAT.faturamento_tabela_venda_codigo_fk::text,
    TV.tabelavenda_descricao as tabela_venda_descricao,
    FAT.faturamento_cfop_codigo_fk,
    V.tabelavenda_descricao,
    P.produto,
    P.pronome as produto_nome,
    P.grupo,
    G.grunome as grupo_nome,
    P.subgrupo,
    S.subnome as subgrupo_nome,
    c.cidnome as empresa_cidade,
    c.estado as empresa_estado,
    c.cidibge as empresa_cidade_ibge,
    case when TV.tabelavenda_codigo_pk in ('004', '035', '042', '031', '045', '075', '056')
         then 'Sim'
         else 'Não'
    end as tabela_venda_promocional,
    case when TV.tabelavenda_codigo_pk in ('004', '035', '042', '031', '045', '075', '056')
         then FAT.faturamento_valor_total * 2
         else FAT.faturamento_valor_total
    end as valor_correo
from public.pw_faturamento FAT
    inner join public.produto P on P.produto = FAT.faturamento_produto_codigo_fk
    inner join public.grupo G on G.grupo = P.grupo
    inner join public.grupo1 S on S.subgrupo = P.subgrupo and S.grupo = P.grupo
    inner join public.pw_empresa E on E.empresa_codigo_pk = FAT.faturamento_empresa_codigo_fk
    inner join public.pw_tabela_venda V on V.tabelavenda_codigo_pk = FAT.faturamento_tabela_venda_codigo_fk
    left join public.cidade C on c.cidade = E.empresa_cidade_codigo_fk
    left join public.pw_tabela_venda TV on TV.tabelavenda_codigo_pk = FAT.faturamento_tabela_venda_codigo_fk
where FAT.faturamento_data_faturamento >= '2025-06-01'
  and FAT.faturamento_data_faturamento <= '2026-05-31'

  --select * from public.pw_tabela_venda where tabelavenda_codigo_pk = '001';


--   and FAT.faturamento_produto_codigo_fk in (
--     select produto from public.produto where grupo = 1
--   );
-- select * from public.pw_empresa E0 where E0.empresa_tipo_empresa = 'Fornecedor' limit 100;
-- select * from public.cidade
-- select * from public.
-- '004',
-- '035',
-- '042',
-- '031',
-- '045',
-- '075',
-- '056',
