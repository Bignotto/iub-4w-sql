/*
Nível de estoque de um insumo ao longo do tempo — uma linha por dia, para gráfico de linha.

Entradas => pritransac < 10
Saídas   => pritransac > 10
Não existe transação 10

Sem filtro de depósito, igual ao movimento.sql: insumo só deveria andar nos depósitos
1 (almoxarifado) e 2 (linha de produção), e um lançamento fora disso é erro que precisa
aparecer no saldo, não ser escondido. A coluna movimento_fora_de_deposito conta essas
linhas por dia; se ela não for zero, rode o movimento.sql para ver quais são.

O calendário é contínuo (generate_series): dias sem movimento repetem o saldo do dia
anterior, senão o gráfico interpola uma reta entre dois pontos distantes e mente sobre
o nível de estoque no meio do período.

estoque_acumulado é o saldo no fim do dia e parte do primeiro movimento existente em
toqmovi — 2024-12-01, com a carga de implantação lançada como transação 6. Ao trocar de
produto, confira o último valor contra pw_saldo_estoque (query no final do arquivo): se
não bater, o insumo não tem a implantação e a curva fica com o patamar errado.
*/

with movimento as (
    select
        p.pridata::date as data_movimento,
        case
            when p.pritransac < 10 then p.priquanti
            else 0
        end as entrada,
        case
            when p.pritransac > 10 then p.priquanti
            else 0
        end as saida,
        case
            when coalesce(p.prideposit, -1) not in (1,2) then 1
            else 0
        end as fora_de_deposito
    from public.toqmovi p
    where p.priquanti <> 0 --descarta lançamento zerado; negativo é estorno e fica
        and p.priproduto = '2130003'
),
por_dia as (
    select
        m.data_movimento,
        sum(m.entrada)             as entradas,
        sum(m.saida)               as saidas,
        sum(m.entrada - m.saida)   as movimento_liquido,
        sum(m.fora_de_deposito)    as movimento_fora_de_deposito
    from movimento m
    group by m.data_movimento
),
calendario as (
    select generate_series(
        (select min(data_movimento) from por_dia),
        current_date,
        interval '1 day'
    )::date as data_movimento
)
select
    C.data_movimento                      as data,
    coalesce(D.entradas, 0)               as entradas,
    coalesce(D.saidas, 0)                 as saidas,
    coalesce(D.movimento_liquido, 0)      as movimento_liquido,
    sum(coalesce(D.movimento_liquido, 0)) over (
        order by C.data_movimento
        rows between unbounded preceding and current row
    )                                     as estoque_acumulado,
    coalesce(D.movimento_fora_de_deposito, 0) as movimento_fora_de_deposito
from calendario C
    left join por_dia D on D.data_movimento = C.data_movimento

order by C.data_movimento asc

/*
-- validação: o último estoque_acumulado tem que bater com o saldo do sistema
select sum(e.saldoestoque_qtde_saldo_estoque) as saldo_sistema
from public.pw_saldo_estoque e
where e.saldoestoque_produto_codigo_fk = '2130003';

-- variante: só os dias com movimento (mais leve, mas o gráfico interpola os buracos)
--   remova o CTE calendario e faça o select direto sobre por_dia
*/
