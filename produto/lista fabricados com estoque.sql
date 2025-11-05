select
    produto as codigo_produto,
    pronome as produto_descricao,
    prosldmin as saldo_min,
    prosldmax as saldo_max,
    proloteco as lote_economico,
    prolotmul as lote_multiplo,
    prolotmax as lote_maximo,
    proorigem as produto_origem,
    grupo,
    subgrupo
from produto
where
    proorigem = 'F'