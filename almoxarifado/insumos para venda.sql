-- PostgreSQL version of the BOM script

DO $$
DECLARE
    produto_codigo TEXT;
    produto_cursor CURSOR FOR 
        SELECT DISTINCT produto
        FROM public.produto p
        WHERE p.produto IN (
            -- saldo de produtos em pedidos abertos
            select
                distinct T0.pedidovenda_produto_codigo_fk
            from public.pw_pedido_venda T0
                inner join public.produto P on P.produto = T0.pedidovenda_produto_codigo_fk
            where T0.pedidovenda_status <> 'Atendido Total'
                AND P.grupo = 1 -- grupo 1 = urnas
                AND T0.pedidovenda_qtde_saldo_produto > 0
        );
        
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS temp_bom_results (
        produto_urna TEXT,
        level INTEGER,
        codigo_componente TEXT,
        quantidade_direta NUMERIC,
        quantidade_total NUMERIC,
        cadeia_componente TEXT,
        sort_path TEXT,
        nome_componente_pai TEXT,
        nome_componente_filho TEXT,
        codigo_pai TEXT
    );
    
    DELETE FROM temp_bom_results;
    
    OPEN produto_cursor;
    LOOP
        FETCH produto_cursor INTO produto_codigo;
        EXIT WHEN NOT FOUND;
        
        INSERT INTO temp_bom_results (
            produto_urna, level, codigo_componente, 
            quantidade_direta, quantidade_total, cadeia_componente, sort_path,
            nome_componente_pai, nome_componente_filho, codigo_pai
        )
        WITH RECURSIVE product_components AS (
            -- Base: Componentes diretos do produto
            SELECT 
                estproduto,
                estfilho,
                estqtduso,
                1 as level,
                CAST(estfilho AS TEXT) as cadeia_componente,
                CAST(estqtduso AS NUMERIC) as quantidade_total,
                LPAD(CAST(ROW_NUMBER() OVER (ORDER BY estfilho) AS TEXT),3,'0') as sort_path,
                estproduto as produto_urna
            FROM public.estrutur 
            WHERE estproduto = produto_codigo
            
            UNION ALL
            
            -- Recursiva: componentes de componentes
            SELECT 
                t.estproduto,
                t.estfilho,
                t.estqtduso,
                pc.level + 1,
                pc.cadeia_componente || ' -> ' || t.estfilho,
                CAST(pc.quantidade_total * t.estqtduso AS NUMERIC) as quantidade_total,
                LPAD(pc.sort_path,3,'0') || '.' || LPAD(ROW_NUMBER() OVER (PARTITION BY pc.estfilho ORDER BY t.estfilho)::TEXT, 3, '0'),
                pc.produto_urna
            FROM public.estrutur t
            INNER JOIN product_components pc ON t.estproduto = pc.estfilho
            WHERE pc.level < 10  -- Prevent infinite recursion
        )
        SELECT 
            produto_urna,
            level,
            estfilho as codigo_componente,
            estqtduso as quantidade_direta,
            quantidade_total,
            cadeia_componente,
            sort_path,
            pai.pronome as nome_componente_pai,
            filho.pronome as nome_componente_filho,
            estproduto as codigo_pai
        FROM product_components
            LEFT JOIN public.produto pai ON pai.produto = estproduto
            LEFT JOIN public.produto filho ON filho.produto = estfilho
        ORDER BY sort_path;
        
        RAISE NOTICE 'Processando produto: %', produto_codigo;
        
    END LOOP;
    CLOSE produto_cursor;
    
    RAISE NOTICE 'Estruturas processadas com sucesso. Resultados armazenados na tabela temporária temp_bom_results.';
    
END $$;

SELECT 
    tbr.*,
    p_root.pronome as produto_urna_descricao,
    CASE 
        WHEN p_child.proorigem = 'C' THEN 'DIRECT_COMPONENT'
        ELSE 'SUB_COMPONENT'
    END as component_type,
    venda_quantidade.total_saldo_produto as quantidade_produto_urna,
    venda_quantidade.total_saldo_produto * tbr.quantidade_total as necessidade_total
FROM temp_bom_results tbr
    LEFT JOIN public.produto p_root ON p_root.produto = tbr.produto_urna
    LEFT JOIN public.produto p_child on p_child.produto = tbr.codigo_componente
    LEFT JOIN (
        select
            T0.pedidovenda_produto_codigo_fk,
            sum(T0.pedidovenda_qtde_saldo_produto) as total_saldo_produto
        from public.pw_pedido_venda T0
            inner join public.produto P on P.produto = T0.pedidovenda_produto_codigo_fk
        where T0.pedidovenda_status <> 'Atendido Total'
            AND P.grupo = 1 -- grupo 1 = urnas
            AND T0.pedidovenda_qtde_saldo_produto > 0
        group by T0.pedidovenda_produto_codigo_fk
        order by 2 desc
    ) venda_quantidade ON venda_quantidade.pedidovenda_produto_codigo_fk = tbr.produto_urna
ORDER BY
   tbr.produto_urna
    --,tbr.level
    --,tbr.component_code
;