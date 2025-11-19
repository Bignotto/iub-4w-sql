select
    e.empresa_cnpj_cpf as cnpj,
    e.empresa_inscricao_estadual as ie,
    e.empresa_descricao as razao,
    e.empresa_codigo_pk as id_externo,
    e.empresa_status as status_cliente,
    e.empresa_nome_fantasia as fantasia,
    c.cidade_descricao as cidade,
    c.cidade_estado_codigo_fk as estado,
    c.cidade_ibge as ibge,
    e.empresa_cep as cep,
    trim(e.empresa_endereco) as endereco,
    trim(e.empresa_bairro) as bairro,
    trim(e.empresa_complemento) as complemento,
    trim(e.empresa_telefone) as telefone,
    trim(e.empresa_celular) as celular,
    trim(e.empresa_whatsapp) as whatsapp,
    trim(e.empresa_email_padrao) as email_padrao,
    trim(e.empresa_email_danfe) as email_danfe,
    trim(e.empresa_email_boletos) as email_boletos,
    trim(e.empresa_email_cte) as email_cte,
    e.empresa_grupo_economico_codigo_fk as grupo_economico_codigo,
    coalesce(e.empresa_distancia_do_cliente::integer,0) as distancia_do_cliente,
    e.empresa_limite_credito as limite_credito,
    coalesce(e.empresa_observacao,'') as observacao,
    e.empresa_tipo_empresa as tipo_empresa,
    e.empresa_tipo_pessoa as tipo_pessoa
from pw_empresa e
    inner join pw_cidade c on c.cidade_codigo_pk = e.empresa_cidade_codigo_fk

    --left join pw_macro_regiao m on m.macro_regiao_codigo_pk = e.macro_regiao_codigo_fk
    --left join pw_regiao_abrangencia r on r.regiao_abrangencia_codigo_pk = e.regiao_abrangencia_codigo_fk

where e.empresa_codigo_pk in (
    select distinct EMP.empresa_codigo_pk as id_externo
    from pw_faturamento FAT
        inner join pw_empresa EMP on EMP.empresa_codigo_pk = FAT.faturamento_empresa_codigo_fk
    where FAT.faturamento_data_faturamento between '2025-08-01' and '2025-12-31'
        and EMP.empresa_tipo_empresa = 'Cliente'
        and EMP.empresa_tipo_pessoa = 'Jurídica'
)

-- CLIENTES DOS ÚLTIMOS 3 MESES
--select distinct EMP.empresa_cnpj_cpf as cnpj
-- select distinct EMP.empresa_codigo_pk as id_externo
-- from pw_faturamento FAT
--     inner join pw_empresa EMP on EMP.empresa_codigo_pk = FAT.faturamento_empresa_codigo_fk
-- where FAT.faturamento_data_faturamento between '2025-08-01' and '2025-12-31'
--     and EMP.empresa_tipo_empresa = 'Cliente'
--     and EMP.empresa_tipo_pessoa = 'Jurídica'
