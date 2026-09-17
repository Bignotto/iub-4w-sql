/*
Movimentação de estoque de um insumo (entradas e saídas) com saldo acumulado linha a linha.

Entradas => pritransac < 10
Saídas   => pritransac > 10
Não existe transação 10

DEPÓSITO: de propósito não há filtro de depósito aqui. Insumo só deveria se movimentar
nos depósitos 1 (almoxarifado) e 2 (linha de produção); 99 é venda no mercado livre e 999
é o depósito de itens que não movimentam estoque. Como a consulta roda um insumo por vez,
qualquer linha fora de 1/2 é erro de lançamento e precisa ser tratada — por isso ela entra
no resultado marcada na coluna alerta_deposito em vez de ser escondida por um where.

Histórico começa em 2024-12-01, com lançamentos de transação 6 (ENTRADA ACERTO
INVENTARIO) que são a carga de implantação do saldo. Como ela está na tabela, o acumulado
parte do zero e fecha contra o saldo atual sem precisar de saldo de abertura.

Todo movimento tem transação cadastrada em transa (confirmado com o fornecedor do ERP),
mas os joins seguem LEFT para que uma exceção apareça como nulo em vez de sumir da soma.

ORDEM DENTRO DO DIA: pridata é date, não tem hora. O desempate é (itecontrol, prisequen),
que é a chave primária de toqmovi — itecontrol identifica o documento e cresce junto com
a data (é a sequência de gravação), prisequen é a linha dentro do documento. Numa
transferência entre depósitos as duas pernas dividem o mesmo itecontrol e o prisequen
coloca a saída antes da entrada. A ordenação da janela e a do order by final têm que ser
idênticas, senão a coluna acumulada fica ilegível.

Validado em 17/09/2026 contra o servidor de testes: para o produto 2130003 o último
estoque_acumulado e o pw_saldo_estoque dão 4321,3580, e também batem depósito a depósito.
*/

with movimento as (
    select
        p.itecontrol      as controle,
        p.prisequen       as sequencia,
        p.priproduto      as insumo_codigo,
        p.pridata::date   as data_movimento,
        p.prideposit      as deposito_codigo,
        p.priquanti       as quantidade,
        p.pricusto        as custo,
        trim(p.pridocto)  as documento,
        p.pritransac      as transacao,
        case
            when coalesce(p.prideposit, -1) not in (1,2) then 'depósito inesperado para insumo'
        end as alerta_deposito,
        case
            when p.pritransac > 10 then -1
            when p.pritransac < 10 then  1
            else 0
        end as sinal,
        case
            when p.pritransac > 10 then -1 * p.priquanti
            when p.pritransac < 10 then  1 * p.priquanti
            else 0
        end as sinal_quantidade
    from public.toqmovi p
    where p.priquanti <> 0 --descarta lançamento zerado; negativo é estorno e fica
        and p.priproduto = '2130003'
),
acumulado as (
    select
        m.*,
        sum(m.sinal_quantidade) over (
            partition by m.insumo_codigo
            order by m.data_movimento, m.controle, m.sequencia
            rows between unbounded preceding and current row
        ) as estoque_acumulado
    from movimento m
)
select
    A.insumo_codigo,
    P0.pronome as insumo_nome,
    A.data_movimento,
    A.controle,
    A.sequencia,
    A.deposito_codigo,
    A.alerta_deposito,
    A.quantidade,
    A.custo,
    A.documento,
    A.transacao,
    T.trsnome as nome_transacao,
    A.sinal,
    A.sinal_quantidade,
    A.estoque_acumulado,
    G.grupo    as insumo_grupo,
    G.grunome  as insumo_grupo_nome,
    S.subgrupo as insumo_subgrupo,
    S.subnome  as insumo_subgrupo_nome
from acumulado A
    left join public.transa  T  on T.transacao = A.transacao
    left join public.produto P0 on P0.produto  = A.insumo_codigo
    left join public.grupo   G  on G.grupo     = P0.grupo
    left join public.grupo1  S  on S.subgrupo  = P0.subgrupo
        and S.grupo = P0.grupo

--filtro de data aqui, DEPOIS da janela, para não zerar o saldo inicial
--where A.data_movimento >= current_date - interval '6 months'

order by A.data_movimento asc, A.controle asc, A.sequencia asc --MESMA ordenação da janela

/*
-------------------------------------------------------------------------------
Validações e variantes
-------------------------------------------------------------------------------

-- validação: o último estoque_acumulado tem que bater com o saldo do sistema
select sum(e.saldoestoque_qtde_saldo_estoque) as saldo_sistema
from public.pw_saldo_estoque e
where e.saldoestoque_produto_codigo_fk = '2130003';

-- conferir se o histórico abre com a carga de implantação (transação 6)
select p.pridata, p.itecontrol, p.prisequen, p.pritransac, t.trsnome, p.priquanti, p.prideposit
from public.toqmovi p
    left join public.transa t on t.transacao = p.pritransac
where p.priproduto = '2130003'
order by p.pridata asc, p.itecontrol asc, p.prisequen asc
limit 20;

-- varredura: insumos lançados em depósito indevido (o que a coluna alerta_deposito
-- mostra para um produto, esta query mostra para todos de uma vez)
select p.priproduto, p.prideposit, count(*) as linhas, sum(p.priquanti) as qtde
from public.toqmovi p
    inner join public.produto P0 on P0.produto = p.priproduto
where P0.grupo not in (1,2,3,999)
    and coalesce(p.prideposit, -1) not in (1,2)
group by p.priproduto, p.prideposit
order by 1, 2;

-- variantes do filtro principal:
--    and P0.grupo not in (1,2,3,999)   --todos os insumos, sem fixar produto

-- estoque_acumulado é total móvel: nunca somar. Agrupamento por transação, mês ou
-- depósito usa quantidade / sinal_quantidade, que são aditivas.
-------------------------------------------------------------------------------
*/

--select transacao, trsnome from public.transa order by 1
--select * from public.toqmovi order by 1,5 limit 1000
