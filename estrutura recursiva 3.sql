WITH RECURSIVE product_components AS (
    -- Base case: Direct components of the main product
    SELECT 
        estproduto,
        estfilho,
        estqtduso,
        1 as level,
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
        CAST(pc.total_quantity * t.estqtduso AS NUMERIC) as total_quantity
    FROM public.estrutur t
    INNER JOIN product_components pc ON t.estproduto = pc.estfilho
    WHERE pc.level < 10  -- Prevent infinite recursion
)
SELECT 
    estfilho as component_code,
    p.pronome as component_name,
    SUM(total_quantity) as total_required_quantity,
    COUNT(*) as usage_count,
    MAX(level) as max_depth_level
FROM product_components
    left join public.produto p on p.produto = estfilho
GROUP BY estfilho, p.pronome
ORDER BY total_required_quantity DESC;