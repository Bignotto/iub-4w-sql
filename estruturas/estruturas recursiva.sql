WITH RECURSIVE product_components AS (
    -- Base case: Direct components of the main product
    SELECT 
        estproduto,
        estfilho,
        estqtduso,
        1 as level,
        CAST(estfilho AS TEXT) as component_path,
        CAST(estqtduso AS NUMERIC) as total_quantity
    FROM public.estrutur 
    WHERE estproduto = '015.080104051112'
    
    UNION ALL
    
    -- Recursive case: Components of components
    SELECT 
        t.estproduto,
        t.estfilho,
        t.estqtduso,
        pc.level + 1,
        pc.component_path || ' -> ' || t.estfilho,
        CAST(pc.total_quantity * t.estqtduso AS NUMERIC) as total_quantity
    FROM public.estrutur t
    INNER JOIN product_components pc ON t.estproduto = pc.estfilho
    WHERE pc.level < 10  -- Prevent infinite recursion (adjust as needed)
)
SELECT 
    level,
    estfilho as component_code,
    estqtduso as direct_quantity,
    total_quantity,
    component_path
FROM product_components
ORDER BY level, component_path;