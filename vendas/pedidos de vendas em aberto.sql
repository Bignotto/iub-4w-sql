  select
    p.pedidovenda_codigo_pk         as "pedidoId",
    p.pedidovenda_status            as "status",
    p.pedidovenda_data_emissao      as "emissao",
    p.pedidovenda_empresa_codigo_fk as "empresaId",
    e.empcgc                        as "cnpj",
    e.empnome                       as "empresaNome",
    p.pedidovenda_produto_codigo_fk as "produtoId",
    p.pedidovenda_qtde_saldo_produto as "qtdeSaldo",
    p.pedidovenda_qtde_produto      as "qtdeTotal",
    c.cidibge                       as "cidadeIbge",
    c.cidnome                       as "cidadeNome",
    c.estado                        as "estado",
    p.pedidovenda_lotecarga_codigo_fk as "rota",
    p.pedidovenda_data_emissao as "dataEmissao",
    p.pedidovenda_data_previsao as "dataPrevisao",
    p.pedidovenda_situacao as "situacao",
    p.pedidovenda_status as "status",
    TV.tabelavenda_descricao as "tabelaVendaDescricao",
    p.pedidovenda_valor_produto_unitario as "valorUnitarioPedido",
    case when TV.tabelavenda_codigo_pk in ('004', '035', '042', '031', '045', '075', '056')
         then 'Sim'
         else 'Não'
    end as "tabelaVendaPromocional",
    case when TV.tabelavenda_codigo_pk in ('004', '035', '042', '031', '045', '075', '056')
         then p.pedidovenda_valor_produto_total * 2
         else p.pedidovenda_valor_produto_total
    end as "valorTotalPedido",
    p.pedidovenda_cfop_codigo_fk as "cfop",
    CP.connome as "condicaoPagamento"
  from public.pw_pedido_venda p
    inner join public.produto pr on pr.produto = p.pedidovenda_produto_codigo_fk
    inner join public.empresa e  on e.empresa  = p.pedidovenda_empresa_codigo_fk
    inner join public.cidade c   on c.cidade   = e.empcidade
    left join public.pw_tabela_venda TV on TV.tabelavenda_codigo_pk = p.pedidovenda_tabelavenda_codigo_fk
    left join public.condpag CP on CP.condicao = p.pedidovenda_condicao_pagto_codigo_fk
  where p.pedidovenda_status <> 'Atendido Total'
    and p.pedidovenda_situacao <> 'Cancelado'
    and pr.grupo = 1
  order by p.pedidovenda_data_emissao 

  --select * from public.pw_pedido_venda p where p.pedidovenda_codigo_pk = 1634
  --select * from public.pw_pedido_venda p limit 1000


--select * from public.pw_empresa