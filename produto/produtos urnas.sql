select
    SUBSTRING(P.pronome,1,6) AS curto_codigo,
    P.produto AS produto_codigo,
    P.pronome as produto_nome

from public.produto P 
    inner join public.grupo G on G.grupo = P.grupo

where P.grupo = 1
    and length(P.produto)>=16