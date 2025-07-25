
select
    P.produto AS insumo_codigo,
    P.pronome AS insumo_nome,
    G.grupo AS insumo_grupo,
    G.grunome AS insumo_grupo_nome,
    S.subgrupo AS insumo_subgrupo,
    S.subnome AS insumo_subgrupo_nome,
    P.proorigem AS insumo_origem,
    P.prosldmin AS estoque_minimo,
    P.prosldmax AS estoque_maximo,
    P.prolotmax AS lote_maximo,
    P.proloteco AS lote_economico,
    P.unimedida AS unidade_medida
from public.produto P 
    inner join public.grupo G on G.grupo = P.grupo
    inner join public.grupo1 S on S.subgrupo = P.subgrupo
        and S.grupo = P.grupo

where P.grupo not in (1,2,3,999)
--select * from public.grupo