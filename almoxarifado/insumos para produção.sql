-- PostgreSQL version of the BOM script

DO $$
DECLARE
    produto_codigo TEXT;
    produto_cursor CURSOR FOR 
        SELECT DISTINCT produto
        FROM public.produto p
        WHERE p.produto IN (
            -- ops de urnas para o dia
            select
                distinct op.ordem_produto_codigo_fk as codigo_produto
            from pw_ordem op
                inner join produto p on p.produto = op.ordem_produto_codigo_fk
                inner join grupo g on g.grupo = p.grupo
                inner join grupo1 s on s.subgrupo = p.subgrupo
                    and s.grupo = p.grupo
            where op.ordem_data_previsao = '2025-07-21'
                and p.grupo = 1
            group by op.ordem_produto_codigo_fk
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
    op_quantidade.quantidade_total as quantidade_produto_urna,
    op_quantidade.quantidade_total * tbr.quantidade_total as necessidade_total
FROM temp_bom_results tbr
    LEFT JOIN public.produto p_root ON p_root.produto = tbr.produto_urna
    LEFT JOIN public.produto p_child on p_child.produto = tbr.codigo_componente
    LEFT JOIN (
        select
            op.ordem_produto_codigo_fk as codigo_produto,
            sum(op.ordem_qtde_digitada) as quantidade_total
        from pw_ordem op
            inner join produto p on p.produto = op.ordem_produto_codigo_fk
            inner join grupo g on g.grupo = p.grupo
            inner join grupo1 s on s.subgrupo = p.subgrupo
                and s.grupo = p.grupo
        where op.ordem_data_previsao = '2025-07-21'
        group by op.ordem_produto_codigo_fk
    ) op_quantidade
        ON op_quantidade.codigo_produto = tbr.produto_urna
ORDER BY
   tbr.produto_urna
    --,tbr.level
    --,tbr.component_code
;

--select * from public.produto where produto = '015.080104051112'