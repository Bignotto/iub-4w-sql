DO $$
DECLARE
    produto_codigo TEXT;
    produto_cursor CURSOR FOR 
        SELECT DISTINCT produto
        FROM public.produto p
        WHERE p.produto IN (
            SELECT P.produto
            FROM public.produto P 
            INNER JOIN public.grupo G ON G.grupo = P.grupo
            WHERE P.grupo = 1 AND length(P.produto) >= 16
        );
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS temp_bom_results (
        produto_codigo TEXT,
        nivel_estrutura INTEGER,
        insumo_codigo TEXT,
        quantidade_direta NUMERIC,
        quantidade_total NUMERIC,
        cadeia_estrutura TEXT,
        caminho_ordenacao TEXT,
        nome_produto TEXT,
        nome_insumo TEXT,
        produto_pai_codigo TEXT
    );
    
    DELETE FROM temp_bom_results;
    
    OPEN produto_cursor;
    LOOP
        FETCH produto_cursor INTO produto_codigo;
        EXIT WHEN NOT FOUND;
        
        INSERT INTO temp_bom_results (
            produto_codigo, nivel_estrutura, insumo_codigo, 
            quantidade_direta, quantidade_total, cadeia_estrutura, caminho_ordenacao,
            nome_produto, nome_insumo, produto_pai_codigo
        )
        WITH RECURSIVE componentes AS (
            -- Base: Componentes diretos
            SELECT 
                estproduto AS produto_codigo,
                estfilho AS insumo_codigo,
                estqtduso AS quantidade_direta,
                1 AS nivel_estrutura,
                CAST(estfilho AS TEXT) AS cadeia_estrutura,
                CAST(estqtduso AS NUMERIC) AS quantidade_total,
                LPAD(CAST(ROW_NUMBER() OVER (ORDER BY estfilho) AS TEXT), 3, '0') AS caminho_ordenacao
            FROM public.estrutur
            WHERE estproduto = produto_codigo

            UNION ALL

            -- Recursão: componentes de componentes
            SELECT 
                c.produto_codigo,
                e.estfilho AS insumo_codigo,
                e.estqtduso AS quantidade_direta,
                c.nivel_estrutura + 1,
                c.cadeia_estrutura || ' -> ' || e.estfilho,
                c.quantidade_total * e.estqtduso,
                LPAD(c.caminho_ordenacao, 3, '0') || '.' || LPAD(ROW_NUMBER() OVER (PARTITION BY c.insumo_codigo ORDER BY e.estfilho)::TEXT, 3, '0')
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
            c.produto_codigo AS produto_pai_codigo
        FROM componentes c
        LEFT JOIN public.produto p_prod ON p_prod.produto = c.produto_codigo
        LEFT JOIN public.produto p_insu ON p_insu.produto = c.insumo_codigo
        ORDER BY c.caminho_ordenacao;

        RAISE NOTICE 'Processado: %', produto_codigo;
    END LOOP;
    CLOSE produto_cursor;

    RAISE NOTICE 'Estrutura processada com sucesso.';
END $$;

-- Consulta final sobre a tabela temporária
SELECT 
    tbr.*,
    p_root.pronome AS descricao_produto,
    CASE 
        WHEN p_child.proorigem = 'C' THEN 'INSUMO_COMPRADO'
        ELSE 'COMPONENTE_INTERNO'
    END AS tipo_componente
FROM temp_bom_results tbr
LEFT JOIN public.produto p_root ON p_root.produto = tbr.produto_codigo
LEFT JOIN public.produto p_child ON p_child.produto = tbr.insumo_codigo
ORDER BY tbr.produto_codigo, tbr.caminho_ordenacao;
