select
    RM.
from pw_requisicoes_materiais RM
    left join pw_ordem OP on OP.ordem_codigo_pk::text = RM.requisicoesmateriais_documento
where RM.requisicoesmateriais_data_requisicao = '2025-07-28';