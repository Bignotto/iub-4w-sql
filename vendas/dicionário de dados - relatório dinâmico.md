# Dicionário de Dados — `vendas/relatório dinâmico.sql`

Descrição das colunas retornadas pela query de relatório dinâmico de vendas.

| # | Coluna (saída) | Origem | Tipo | Formato / Domínio | Descrição |
|---|---|---|---|---|---|
| 1 | `faturamento_nf_numero` | `FAT.faturamento_nf_numero` | numérico/texto (conforme coluna original) | valor original da tabela | Número da nota fiscal de faturamento. |
| 2 | `faturamento_data_faturamento` | `FAT.faturamento_data_faturamento` (formatado com `to_char`) | texto | `DD/MM/YYYY` | Data em que o faturamento ocorreu, formatada para exibição. |
| 3 | `faturamento_ano_mes` | `FAT.faturamento_data_faturamento` (formatado com `to_char`) | texto | `YYYY-MM` | Ano e mês do faturamento, usado para agrupamentos mensais. |
| 4 | `faturamento_empresa_codigo_fk` | `FAT.faturamento_empresa_codigo_fk` | inteiro/texto (código) | código da empresa | Chave estrangeira que identifica a empresa (cliente/filial) associada ao faturamento. |
| 5 | `empresa_cnpj_cpf` | `E.empresa_cnpj_cpf` | texto | CNPJ (14 dígitos) ou CPF (11 dígitos) | Documento fiscal (CNPJ ou CPF) da empresa. |
| 6 | `empresa_descricao` | `E.empresa_descricao` | texto | livre | Nome/razão social ou descrição cadastrada da empresa. |
| 7 | `faturamento_produto_codigo_fk` | `FAT.faturamento_produto_codigo_fk::text` | texto (convertido) | código do produto | Chave estrangeira que identifica o produto faturado. |
| 8 | `faturamento_qtde_produto` | `FAT.faturamento_qtde_produto` | numérico | quantidade | Quantidade do produto faturada na nota. |
| 9 | `faturamento_valor_total` | `FAT.faturamento_valor_total` | numérico (moeda) | valor em R$ | Valor total faturado para o item (produto x quantidade, já com eventuais ajustes). |
| 10 | `faturamento_valor_desconto` | `FAT.faturamento_valor_desconto` | numérico (moeda) | valor em R$ | Valor de desconto aplicado ao item faturado. |
| 11 | `faturamento_valor_unitario` | calculado: `faturamento_valor_total / faturamento_qtde_produto` | numérico (moeda) | valor em R$, 4 casas decimais | Valor unitário do produto, calculado dividindo o valor total pela quantidade. Retorna `null` quando a quantidade é zero (evita divisão por zero). |
| 12 | `faturamento_tabela_preco_item_codigo_fk` | `FAT.faturamento_tabela_preco_item_codigo_fk::text` | texto (convertido) | código do item na tabela de preços | Identifica o item/linha específico dentro da tabela de preços que definiu o valor do produto no faturamento (conceito distinto da tabela de venda). |
| 13 | `faturamento_tabela_venda_codigo_fk` | `FAT.faturamento_tabela_venda_codigo_fk::text` | texto (convertido) | código da tabela de venda | Chave estrangeira que identifica a tabela de venda utilizada no faturamento. |
| 14 | `tabela_venda_descricao` | `TV.tabelavenda_descricao` | texto | livre | Descrição da tabela de venda associada ao faturamento (via join `TV`). |
| 15 | `faturamento_cfop_codigo_fk` | `FAT.faturamento_cfop_codigo_fk` | texto/inteiro (código) | código CFOP (4 dígitos) | CFOP (Código Fiscal de Operações e Prestações) da operação fiscal do item faturado. |
| 16 | `produto` | `P.produto` | texto/inteiro (código) | código do produto | Código do produto no cadastro (tabela `produto`). |
| 17 | `produto_nome` | `P.pronome` | texto | livre | Nome/descrição do produto. |
| 18 | `grupo` | `P.grupo` | texto/inteiro (código) | código do grupo | Código do grupo ao qual o produto pertence (query filtra apenas `grupo = 1`). |
| 19 | `grupo_nome` | `G.grunome` | texto | livre | Nome/descrição do grupo do produto. |
| 20 | `subgrupo` | `P.subgrupo` | texto/inteiro (código) | código do subgrupo | Código do subgrupo ao qual o produto pertence. |
| 21 | `subgrupo_nome` | `S.subnome` | texto | livre | Nome/descrição do subgrupo do produto. |
| 22 | `empresa_cidade` | `c.cidnome` | texto | livre | Nome da cidade onde a empresa está localizada. |
| 23 | `empresa_estado` | `c.estado` | texto | sigla UF (2 letras) | Estado (UF) onde a empresa está localizada. |
| 24 | `empresa_cidade_ibge` | `c.cidibge` | texto/inteiro | código IBGE do município | Código IBGE da cidade da empresa, usado para integrações e cruzamentos com bases oficiais. |
| 25 | `tabela_venda_promocional` | calculado a partir de `TV.tabelavenda_codigo_pk` | texto | `'Sim'` ou `'Não'` | Indica se a tabela de venda utilizada é uma das tabelas promocionais (códigos `004`, `035`, `042`, `031`, `045`, `075`, `056`). |
| 26 | `valor_correo` | calculado a partir de `faturamento_valor_total` | numérico (moeda) | valor em R$ | Valor de referência para cálculo de meta/bonificação: quando a tabela de venda é promocional, dobra o `faturamento_valor_total`; caso contrário, mantém o valor original. |

## Observações / pendências

- **Filtro de período:** a query considera apenas faturamentos entre `2025-01-01` e `2030-12-31`.
- **Filtro de grupo:** a query retorna apenas produtos do `grupo = 1`.
- **Join duplicado removido:** o join redundante `pw_tabela_venda V` (que gerava a antiga coluna `tabelavenda_descricao`) foi removido da query; `TV` permanece como única referência à tabela de venda.
