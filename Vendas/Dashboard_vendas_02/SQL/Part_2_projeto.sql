-- (Query 1) Gênero dos leads
-- Colunas: gênero, leads(#)

SELECT
	case
		when ibge.gender = 'male' then 'homens'
		when ibge.gender = 'female' then 'mulheres'
	end as "gênero",
	count(*) as "leads (#)"

FROM sales.customers as cus
LEFT JOIN temp_tables.ibge_genders as ibge
	ON lower(ibge.first_name) = lower(cus.first_name)
group by ibge.gender

-- (Query 2) Status profissional dos leads
-- Colunas: status profissional, leads (%)

SELECT
	CASE
		WHEN professional_status = 'freelancer' THEN 'freelancer'
		when professional_status = 'clt' then 'clt'
		when professional_status = 'retired' then 'aposentado(a)'
		when professional_status = 'self_employed' then 'autônomo(a)'
		when professional_status = 'other' then 'outro'
		when professional_status = 'businessman' then 'empresário(a)'
		when professional_status = 'civil_servant' then 'funcionário(a) público(a)'
		when professional_status = 'student' then 'estudante'
	END AS "profissão",
	(count(*)::float)/(select count(*) from sales.customers) as "leads (#)"
FROM sales.customers
group by "profissão"
order by "leads (#)"


-- (Query 3) Faixa etária dos leads
-- Colunas: faixa etária, leads (%)

select 
	case
		when (current_date-birth_date)/360 < 20 then '0-20'
		when (current_date-birth_date)/360 < 40 then '20-40'
		when (current_date-birth_date)/360 < 60 then '40-60'
		when (current_date-birth_date)/360 < 80 then '60-80'
		else '80+' 
	end as "faixa etária",
	((count(*)::float) / (select count(*) from sales.customers)) as "loads (#)"
from sales.customers
group by "faixa etária"
order by "faixa etária" desc

-- (Query 4) Faixa salarial dos leads
-- Colunas: faixa salarial, leads (%), ordem


SELECT
	case 
		when income < 5000 then '0-5000'
		when income < 10000 then '5000-10000'
		when income < 15000 then '10000-15000'
		when income < 20000 then '15000-20000'
		else '20000+'
	end as "faixa salarial",

	case
		when income < 5000 then 1
		when income < 10000 then 2
		when income < 15000 then 3
		when income < 20000 then 4
		else 5
	end as "ordem",
	count(*)::float / (select count(*) from sales.customers) as "leads (#)"
FROM sales.customers
group by "faixa salarial", "ordem"
order by "ordem"

-- (Query 5) Classificação dos veículos visitados
-- Colunas: classificação do veículo, veículos visitados (#)
-- Regra de negócio: Veículos novos tem até 2 anos e seminovos acima de 2 anos

WITH classificacao_veiculo as (
	
	SELECT fun.visit_page_date,
		pro.model_year,
		extract(year from fun.visit_page_date) - pro.model_year::integer as idade_veículo,
		case
			when extract(year from fun.visit_page_date) - pro.model_year::integer <= 2 then 'novo'
			else 'semi-novo'
		end as "classificação do veículo"
	FROM sales.products as pro
	left join sales.funnel as fun
		on pro.product_id = fun.product_id
)

SELECT "classificação do veículo",
	count(*) as "veiculos visitados (#)"
FROM classificacao_veiculo
group by "classificação do veículo"

-- (Query 6) Idade dos veículos visitados
-- Colunas: Idade do veículo, veículos visitados (%), ordem

with veiculos as (
	SELECT
		case
			when extract(year from fun.visit_page_date) - pro.model_year::int <= 2 then 'até 2 anos'
			when extract(year from fun.visit_page_date) - pro.model_year::int <= 4 then 'de 2 a 4 anos'
			when extract(year from fun.visit_page_date) - pro.model_year::int <= 6 then 'de 4 a 6 anos'
			when extract(year from fun.visit_page_date) - pro.model_year::int <= 8 then 'de 6 a 8 anos'
			when extract(year from fun.visit_page_date) - pro.model_year::int <= 10 then 'de 8 a 10 anos'
			else '+10 anos'
		end as "idade_veiculo",

		case
			when extract(year from fun.visit_page_date) - pro.model_year::int <= 2 then 1
			when extract(year from fun.visit_page_date) - pro.model_year::int <= 4 then 2
			when extract(year from fun.visit_page_date) - pro.model_year::int <= 6 then 3
			when extract(year from fun.visit_page_date) - pro.model_year::int <= 8 then 4
			when extract(year from fun.visit_page_date) - pro.model_year::int <= 10 then 5
			else 6
		end as "ordem"
	
	FROM sales.funnel as fun
	LEFT JOIN sales.products as pro
		on pro.product_id = fun.product_id
)


SELECT idade_veiculo,
	count(*)::float /(SELECT COUNT(*) FROM sales.funnel) as "veiculos visitados (%)",
	ordem
	
FROM veiculos
group by ordem, idade_veiculo
order by ordem


-- (Query 7) Veículos mais visitados por marca
-- Colunas: brand, model, visitas (#)

SELECT
	pro.brand,
	pro.model,
	count(*) as "visitas (#)" 
FROM sales.products as pro
left join sales.funnel as fun
	on pro.product_id = pro.product_id
group by pro.brand, pro.model
order by pro.brand, pro.model, "visitas (#)"
