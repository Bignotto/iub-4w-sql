select
    TV.tabelavenda_descricao as tabela,
    TV.tabelavenda_codigo_pk as tabela_codigo,
    -- concatenar descrição + código em uma única coluna (garante cast se código for numérico)
    CONCAT(TV.tabelavenda_codigo_pk, ' ', CAST(TV.tabelavenda_descricao AS VARCHAR(50))) AS tabela_completa,
    TP.produto as produto,
    TP.prvenda as preco
    
from tabprven TP

    inner join produto P on P.produto = TP.produto
    left join pw_tabela_venda TV on TV.tabelavenda_codigo_pk = TP.ttpvcod

where P.grupo = 1
    and length(P.produto)>=16
    and (
        TV.tabelavenda_descricao = 'LP 2025 SP 30/60/90' OR
        TV.tabelavenda_descricao = 'LP 2024 MG/GO/RJ PRA' OR
        TV.tabelavenda_descricao = 'LP 2024 MG/GO/RJ V A' OR
        TV.tabelavenda_descricao = 'LP 2024 SP A VISTA'
    )