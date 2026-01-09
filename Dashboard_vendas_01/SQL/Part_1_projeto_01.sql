-- Modelando os dados para conseguir fazer a análise:
/*
Nosso foco é inicial é conseguir descobrir os meses e agrupá-los, descobrir a quantidade de visitas
o site recebe, compreender quantas vendas são feitas, desta forma saberemos um pouco da receita
e o índice de venda em relação ao número de visitas, alé de ter uma noção de quanto se recebe a cada venda
*/

-- faremos duas tabelas temporárias, uma para a quantidade de visitas e as outras informações

WITH dicas as (
	SELECT date_trunc('month', visit_page_date) :: date as mes, 
		count(*) as visita
	FROM sales.funnel
	GROUP BY mes
	ORDER BY mes
),

	pagamentos as (
	SELECT 
		date_trunc('month', fun.paid_date) :: date as mes,
		count(fun.paid_date) as compras_pagas, 
		sum(pro.price *(1 + fun.discount)) as receita
		
	FROM sales.funnel as fun
	LEFT JOIN sales.products as pro
		ON fun.product_id = pro.product_id
	WHERE fun.paid_date IS NOT NULL
	GROUP BY mes
	ORDER BY mes
	)
	
SELECT dic.mes as "mês", 
	dic.visita as "leads (#)",
	pag.compras_pagas "vendas (#)", 
	(pag.receita / 1000) as "Receita (k, R$)", 
	(pag.compras_pagas :: float / dic.visita :: float) as "Conversão (%)",
	(pag.receita / pag.compras_pagas /1000) as "Ticket médio (k, R$)"
FROM dicas as dic
LEFT JOIN pagamentos as pag
	ON dic.mes = pag.mes


-- Agora descobriremos os estados que mais vendem

SELECT 
	'Brasil' as país,
	cus.state as estado,
	count(fun.paid_date) as "vendas (#)"
FROM sales.customers as cus
LEFT JOIN sales.funnel as fun
	ON cus.customer_id = fun.customer_id
WHERE fun.paid_date BETWEEN '2021-08-01' and '2021-08-31'
GROUP BY estado, país
ORDER BY "vendas (#)" desc




-- Marcas que mais venderam no mês
SELECT 
	pro.brand as marca,
	count(fun.paid_date) as "vendas (#)"
FROM sales.products as pro
LEFT JOIN sales.funnel as fun
	ON pro.product_id = fun.product_id
WHERE fun.paid_date BETWEEN '2021-08-01' and '2021-08-31'
GROUP BY marca
ORDER BY "vendas (#)" desc



-- Lojas que mais venderam

SELECT 
	sto.store_name as loja,
	count(fun.paid_date) as "vendas (#)"
FROM sales.stores as sto
LEFT JOIN sales.funnel as fun
	ON sto.store_id = fun.store_id
WHERE fun.paid_date BETWEEN '2021-08-01' and '2021-08-31'
GROUP BY loja
ORDER BY "vendas (#)" desc


-- (Query 5) Dias da semana com maior número de visitas ao site

SELECT
	extract('dow' from visit_page_date) as dia_semana,
	CASE 
		WHEN extract('dow' from visit_page_date) = 0 THEN 'Domingo'
		WHEN extract('dow' from visit_page_date) = 1 THEN 'Segunda'
		WHEN extract('dow' from visit_page_date) = 2 THEN 'Terça'
		WHEN extract('dow' from visit_page_date) = 3 THEN 'Quarta'
		WHEN extract('dow' from visit_page_date) = 4 THEN 'Quinta'
		WHEN extract('dow' from visit_page_date) = 5 THEN 'Sexta'
		WHEN extract('dow' from visit_page_date) = 6 THEN 'Sábado'
		else null END AS "dia da semana",
	count(*) as "visitas (#)"
FROM sales.funnel
WHERE visit_page_date BETWEEN '2021-08-01' and '2021-08-31'
GROUP BY dia_semana
ORDER BY dia_semana