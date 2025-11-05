WITH RECURSIVE componentes AS (
    -- Base: Componentes diretos
    SELECT 
        e.estproduto AS produto_codigo,
        e.estfilho AS insumo_codigo,
        e.estqtduso AS quantidade_direta,
        1 AS nivel_estrutura,
        CAST(e.estfilho AS TEXT) AS cadeia_estrutura,
        CAST(e.estqtduso AS NUMERIC) AS quantidade_total,
        LPAD(ROW_NUMBER() OVER (PARTITION BY e.estproduto ORDER BY e.estfilho)::TEXT, 3, '0') AS caminho_ordenacao
    FROM public.estrutur e
    WHERE e.estproduto IN (
        SELECT P.produto
        FROM public.produto P 
        WHERE P.grupo = 1 AND LENGTH(P.produto) >= 16
    )

    UNION ALL

    -- Recursão: componentes de componentes
    SELECT 
        c.produto_codigo,
        e.estfilho AS insumo_codigo,
        e.estqtduso AS quantidade_direta,
        c.nivel_estrutura + 1,
        c.cadeia_estrutura || ' -> ' || e.estfilho,
        c.quantidade_total * e.estqtduso,
        c.caminho_ordenacao || '.' || LPAD(ROW_NUMBER() OVER (PARTITION BY c.insumo_codigo ORDER BY e.estfilho)::TEXT, 3, '0')
    FROM public.estrutur e
    INNER JOIN componentes c ON e.estproduto = c.insumo_codigo
    WHERE c.nivel_estrutura < 10
)

SELECT 
    c.produto_codigo,
    c.nivel_estrutura,
    c.insumo_codigo,
    c.quantidade_direta,
    c.quantidade_total,
    c.cadeia_estrutura,
    c.caminho_ordenacao,
    p_prod.pronome AS nome_produto,
    p_insu.pronome AS nome_insumo,
    CASE 
        WHEN p_insu.proorigem = 'C' THEN 'INSUMO_COMPRADO'
        ELSE 'COMPONENTE_INTERNO'
    END AS tipo_componente
FROM componentes c
LEFT JOIN public.produto p_prod ON p_prod.produto = c.produto_codigo
LEFT JOIN public.produto p_insu ON p_insu.produto = c.insumo_codigo
ORDER BY c.produto_codigo, c.caminho_ordenacao;
