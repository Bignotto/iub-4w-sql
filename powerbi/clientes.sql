-- Modificado: garantir que cada empresa_codigo_pk apareça apenas uma vez
WITH clientes_dedup AS (
    SELECT
        E.*,
        ROW_NUMBER() OVER (
            PARTITION BY E.empresa_codigo_pk
            ORDER BY E.empresa_representante_nome -- ajuste este ORDER BY para escolher qual registro manter (por ex. data de criação DESC)
        ) AS rn
    FROM vw_empresa E
    WHERE E.empresa_tipo_empresa = 'Cliente'
)
SELECT *
FROM clientes_dedup
WHERE rn = 1
    --AND empresa_codigo_pk = 4042; 

--select * from pw_cidade where cidade_ibge <> '';