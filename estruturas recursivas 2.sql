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
        estproduto as root_product -- Add root product code
    FROM public.estrutur 
    WHERE estproduto in ('015.080104051112','020.080106051228','013.080103060010','004.080002020411','013.080105010010')
    
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
        pc.root_product -- Carry forward the root product code
    FROM public.estrutur t
    INNER JOIN product_components pc ON t.estproduto = pc.estfilho
    WHERE pc.level < 10  -- Prevent infinite recursion (adjust as needed)
) --select * from product_components;

SELECT 
    root_product,
    REPEAT('  ', level - 1) || '├─ ' || estfilho as component_hierarchy,
    level,
    estfilho as component_code,
    estqtduso as direct_quantity,
    total_quantity,
    component_path,
    pai.pronome as parent_name,
    filho.pronome as child_name
FROM product_components
    left join public.produto pai on pai.produto = estproduto
    left join public.produto filho on filho.produto = estfilho
ORDER BY sort_path;