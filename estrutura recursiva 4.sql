-- PostgreSQL version of the BOM script

DO $$
DECLARE
    produto_codigo TEXT;
    produto_cursor CURSOR FOR 
        SELECT DISTINCT produto
        FROM public.produto p
        WHERE p.produto IN (
            -- Your product selection criteria here
            -- This is a placeholder - replace with your actual product selection logic
            '015.080104051112','020.080106051228','013.080103060010','004.080002020411','013.080105010010'
            -- Replace with your actual product selection query
        );
        
BEGIN
    -- Create temporary table to store all BOM results
    CREATE TEMP TABLE IF NOT EXISTS temp_bom_results (
        root_product TEXT,
        component_hierarchy TEXT,
        level INTEGER,
        component_code TEXT,
        direct_quantity NUMERIC,
        total_quantity NUMERIC,
        component_path TEXT,
        parent_name TEXT,
        child_name TEXT,
        parent_code TEXT
    );
    
    -- Clear any existing data
    DELETE FROM temp_bom_results;
    
    -- Loop through each product
    OPEN produto_cursor;
    LOOP
        FETCH produto_cursor INTO produto_codigo;
        EXIT WHEN NOT FOUND;
        
        -- Insert BOM data for current product using our recursive query
        INSERT INTO temp_bom_results (
            root_product, component_hierarchy, level, component_code, 
            direct_quantity, total_quantity, component_path, 
            parent_name, child_name, parent_code
        )
        WITH RECURSIVE product_components AS (
            -- Base case: Direct components of the main product
            SELECT 
                estproduto,
                estfilho,
                estqtduso,
                1 as level,
                CAST(estfilho AS TEXT) as component_path,
                CAST(estqtduso AS NUMERIC) as total_quantity,
                CAST(ROW_NUMBER() OVER (ORDER BY estfilho) AS TEXT) as sort_path,
                estproduto as root_product
            FROM public.estrutur 
            WHERE estproduto = produto_codigo
            
            UNION ALL
            
            -- Recursive case: Components of components
            SELECT 
                t.estproduto,
                t.estfilho,
                t.estqtduso,
                pc.level + 1,
                pc.component_path || ' -> ' || t.estfilho,
                CAST(pc.total_quantity * t.estqtduso AS NUMERIC) as total_quantity,
                pc.sort_path || '.' || LPAD(ROW_NUMBER() OVER (PARTITION BY pc.estfilho ORDER BY t.estfilho)::TEXT, 3, '0'),
                pc.root_product
            FROM public.estrutur t
            INNER JOIN product_components pc ON t.estproduto = pc.estfilho
            WHERE pc.level < 10  -- Prevent infinite recursion
        )
        SELECT 
            root_product,
            REPEAT('  ', level - 1) || '├─ ' || estfilho as component_hierarchy,
            level,
            estfilho as component_code,
            estqtduso as direct_quantity,
            total_quantity,
            component_path,
            pai.pronome as parent_name,
            filho.pronome as child_name,
            estproduto as parent_code
        FROM product_components
            LEFT JOIN public.produto pai ON pai.produto = estproduto
            LEFT JOIN public.produto filho ON filho.produto = estfilho
        ORDER BY sort_path;
        
        -- Optional: Log progress
        RAISE NOTICE 'Processed product: %', produto_codigo;
        
    END LOOP;
    CLOSE produto_cursor;
    
    -- Display final results
    RAISE NOTICE 'BOM processing complete. Results stored in temp_bom_results table.';
    
END $$;

-- Query the results
SELECT 
    tbr.*,
    -- Add any additional joins you need here similar to your original query
    p_root.pronome as root_product_name,
    -- You can add more fields as needed
    CASE 
        WHEN tbr.level = 1 THEN 'DIRECT_COMPONENT'
        ELSE 'SUB_COMPONENT'
    END as component_type
FROM temp_bom_results tbr
    LEFT JOIN public.produto p_root ON p_root.produto = tbr.root_product
ORDER BY 
    tbr.root_product
    --,tbr.level
    --,tbr.component_code;
;