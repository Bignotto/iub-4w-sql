select 
    p.priproduto as insumo_codigo,
    P0.pronome as insumo_nome,
    p.pridata as data_movimento,
	p.prideposit as deposito_codigo,
    p.priquanti as quantidade,
    p.pricusto as custo,
    trim(p.pridocto) as documento,
	p.pritransac as transacao,
	CASE
		WHEN p.pritransac > 10 THEN -1
		WHEN p.pritransac < 10 THEN 1
	END AS sinal,
    CASE
		WHEN p.pritransac > 10 THEN -1 * p.priquanti
		WHEN p.pritransac < 10 THEN 1 * p.priquanti
	END AS sinal_quantidade,

    SUM(CASE
        WHEN p.pritransac > 10 THEN -1 * p.priquanti
        WHEN p.pritransac < 10 THEN 1 * p.priquanti
    END) OVER (
        PARTITION BY p.priproduto 
        ORDER BY p.pridata, p.pritransac
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS estoque_acumulado,
    t.trsnome as nome_transacao,
    G.grupo AS insumo_grupo,
    G.grunome AS insumo_grupo_nome,
    S.subgrupo AS insumo_subgrupo,
    S.subnome AS insumo_subgrupo_nome
from toqmovi p
    inner join transa t 
        on t.transacao = p.pritransac
    left join produto p0 on p0.produto = p.priproduto
    left join grupo G on G.grupo = p0.grupo
    left join grupo1 S on S.subgrupo = p0.subgrupo
        and S.grupo = p0.grupo
where  p.prideposit not in (99) --mercado livre
    and p.priquanti > 0
    and p0.grupo not in (999,2)
    and p.pridata >= current_date - interval '6 months'

order by p.pridata asc

--limit 100

--select * from transa order by 1 asc

/*
Entradas => transação < 10
Saídas => transação > 10
Não tem transação 10

*/
