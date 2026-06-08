select 
    --count(distinct FAT.faturamento_nf_numero)
    FAT.faturamento_nf_numero,
    FAT.faturamento_data_faturamento,
    to_char(FAT.faturamento_data_faturamento, 'YYYY-MM') as year_month,
    to_char(FAT.faturamento_data_faturamento, 'IYYY-IW') as year_week_number,
    FAT.faturamento_empresa_codigo_fk,
    E.empresa_cnpj_cpf,
    E.empresa_descricao,
    FAT.faturamento_produto_codigo_fk,
    FAT.faturamento_qtde_produto,
    FAT.faturamento_valor_total,
    FAT.faturamento_valor_desconto,
    FAT.faturamento_tabela_preco_item_codigo_fk,
    TV.tabelavenda_descricao,
    FAT.faturamento_tabela_venda_codigo_fk,
    FAT.faturamento_cfop_codigo_fk,
    P.produto,
    P.pronome as produto_nome,
    P.grupo,
    G.grunome as grupo_nome,
    P.subgrupo,
    S.subnome as subgrupo_nome,
    C.cidnome as cidade_nome,
    C.estado as cidade_estado,
    C.cidibge AS cidade_ibge,
      case when FAT.faturamento_tabela_venda_codigo_fk in ('004','035','042','031','045','075','056') then 'Sim' else 'Não' end as tabela_venda,
      case when FAT.faturamento_tabela_venda_codigo_fk in ('004','035','042','031','045','075','056')
        then ((FAT.faturamento_valor_total*2)/FAT.faturamento_qtde_produto)
        else FAT.faturamento_valor_total
      end as valor_unitario_correto,
      case when FAT.faturamento_tabela_venda_codigo_fk in ('004','035','042','031','045','075','056')
        then (FAT.faturamento_valor_total*2)
        else FAT.faturamento_valor_total
      end as valor_total_correto
from public.pw_faturamento FAT
    inner join public.produto P on P.produto = FAT.faturamento_produto_codigo_fk
    inner join public.grupo G on G.grupo = P.grupo
    inner join public.grupo1 S on S.subgrupo = P.subgrupo and S.grupo = P.grupo
    inner join public.pw_empresa E on E.empresa_codigo_pk = FAT.faturamento_empresa_codigo_fk
    inner join public.cidade C on C.cidade = E.empresa_cidade_codigo_fk
    left join public.pw_tabela_venda TV on TV.tabelavenda_codigo_pk = FAT.faturamento_tabela_venda_codigo_fk
where FAT.faturamento_data_faturamento >= '2025-06-01'
  and FAT.faturamento_data_faturamento <= '2026-05-31'
  and P.grupo = 1


--   and FAT.faturamento_produto_codigo_fk in (
--     select produto from public.produto where grupo = 1
--   );
-- select * from public.pw_empresa E0
-- where E0.empresa_tipo_empresa = 'Fornecedor'
-- limit 100;

-- select * from cidade;

-- select * from pw_tabela_venda as TV where TV.tabelavenda_codigo_pk in ('004','035','042','031','045','075','056');
