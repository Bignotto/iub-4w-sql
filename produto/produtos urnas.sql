select
    P.produto AS produto_codigo

from public.produto P 
    inner join public.grupo G on G.grupo = P.grupo

where P.grupo = 1
    and length(P.produto)>=16