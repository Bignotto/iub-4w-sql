select
    e.empresa_codigo_pk as codigo,
    e.empresa_status as status_cliente,
    e.empresa_descricao as razao,
    e.empresa_nome_fantasia as fantasia,
    e.empresa_cnpj_cpf as cnpj,
    c.cidade_descricao as cidade,
    c.cidade_estado_codigo_fk as estado,
    c.cidade_ibge as ibge,
    e.empresa_telefone as telefone,
    e.empresa_celular as celular,
    e.empresa_whatsapp as whatsapp,
    trim(e.empresa_email_padrao) as email_padrao,
    trim(e.empresa_email_danfe) as email_danfe,
    trim(e.empresa_email_boletos) as email_boletos,
    trim(e.empresa_email_cte) as email_cte,
    e.empresa_grupo_economico_codigo_fk as grupo_economico_codigo,
    e.macro_regiao_codigo_fk as macro_codigo,
    m.macro_regiao_descricao as macro_descricao,
    e.regiao_abrangencia_codigo_fk as regiao_abrangencia_codigo,
    r.regiao_abrangencia_descricao as regiao_abrangencia_descricao,
    coalesce(e.empresa_distancia_do_cliente::integer,0) as distancia_do_cliente,
    e.empresa_limite_credito as limite_credito,
    coalesce(e.empresa_observacao,'') as observacao
from pw_empresa e
    inner join pw_cidade c on c.cidade_codigo_pk = e.empresa_cidade_codigo_fk

    left join pw_macro_regiao m on m.macro_regiao_codigo_pk = e.macro_regiao_codigo_fk
    left join pw_regiao_abrangencia r on r.regiao_abrangencia_codigo_pk = e.regiao_abrangencia_codigo_fk
where e.empresa_tipo_empresa = 'Cliente'