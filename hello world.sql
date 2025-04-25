select 
   distinct T0.amctipacab,
    T1.tpadesc
    -- T0.amccodigo,
    -- T0.amcdescri,
    -- T0.amccompos
from public.acabconf T0
    left join public.tipacab T1 on T1.tpacodi = T0.amctipacab
order by
    T0.amctipacab
