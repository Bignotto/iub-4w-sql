 select
     p.pedidovenda_codigo_pk       as "pedidoId",
     p.pedidovenda_data_emissao    as "emissao",
     p.pedidovenda_empresa_codigo_fk as "empresaId",
     e.empcgc                      as "cnpj",
     e.empnome                     as "empresaNome",
     p.pedidovenda_produto_codigo_fk as "produtoId",
     p.pedidovenda_qtde_saldo_produto as "qtdeSaldo",
     p.pedidovenda_qtde_produto    as "qtdeTotal",
     c.cidibge                     as "cidadeIbge",
     c.cidnome                     as "cidadeNome",
     c.estado                      as "estado",
     p.pedidovenda_lotecarga_codigo_fk
 from public.pw_pedido_venda p
     inner join public.produto pr on pr.produto = p.pedidovenda_produto_codigo_fk
     inner join public.empresa e on e.empresa = p.pedidovenda_empresa_codigo_fk
     inner join public.cidade c on c.cidade = e.empcidade
 where p.pedidovenda_status <> 'Atendido Total'
     AND pr.grupo = 1