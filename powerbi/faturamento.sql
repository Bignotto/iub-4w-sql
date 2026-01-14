select 
    FAT.*,
    TV.tabelavenda_descricao as tabela_venda_descricao
from public.pw_faturamento FAT
    inner join public.produto P on P.produto = FAT.faturamento_produto_codigo_fk
    inner join public.pw_tabela_venda TV on TV.tabelavenda_codigo_pk = FAT.faturamento_tabela_venda_codigo_fk

where FAT.faturamento_data_faturamento >= '2025-01-01'
  and P.grupo = 1


  