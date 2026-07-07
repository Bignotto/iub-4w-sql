select
*
from pw_requisicoes_materiais RM

limit 5000
    --left join pw_ordem OP on OP.ordem_codigo_pk::text = RM.requisicoesmateriais_documento
--where RM.requisicoesmateriais_data_requisicao = '2025-07-28';

select * from pw_requisicoes_materiais limit 5000
select * from pw_compra limit 5000
select * from inventa limit 5000
select * from transter limit 5000