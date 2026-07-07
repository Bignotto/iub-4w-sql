select
    e.empresa as codigo,
    e.empnome as nome,
    e.emprazsoc as razao_social,
    e.empfanta as fantasia,
    e.empcgc as cnpj,
    e.empinsest as inscricao_estadual,
    e.empcep as cep,
    e.emprua as logradouro,
    e.empbairro as bairro,
    c.cidade_descricao as cidade,
    c.cidade_estado_codigo_fk as estado,
    c.cidade_ibge as ibge,

    e.empemail as email,
    e.empcelular as celular,
    e.emptelef as telefone

--select *
from public.empresa E
    inner join pw_cidade c on c.cidade_codigo_pk = e.empcidade

where E.empresa in (
    select distinct F.faturamento_empresa_codigo_fk
    from public.pw_faturamento F
    where F.faturamento_data_faturamento between '2024-01-01' and '2026-12-31'
  )
  and E.empdpess = 'Jurídica'
  and E.empdemptip = 'Cliente'
