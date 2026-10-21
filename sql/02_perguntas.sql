-- =====================================================================
-- 02_perguntas.sql  -  As 6 perguntas de negocio da Controladoria em SQL
-- ---------------------------------------------------------------------
-- Cada consulta responde UMA pergunta estrategica (secao 4.4 do enunciado).
-- As respostas aqui batem com o dashboard do Power BI e com a prova real
-- (anexo 8). Regras de ouro usadas (secao 4.4):
--   * Percentual = SOMA / SOMA (nunca media de percentuais).
--   * A economia so conta nos itens comparaveis (comparavel = 1).
--   * NULLIF(denominador, 0) protege a divisao por zero.
--   * O total do "todo" vem de subconsulta (nao de JOIN que multiplicaria linhas).
--
-- Rodar no MySQL Workbench (ou: mysql -u root -p pncp_controladoria < sql/02_perguntas.sql)
-- =====================================================================
USE pncp_controladoria;


-- ---------------------------------------------------------------------
-- PERGUNTA 1 - Economia global do Poder Publico
-- "Qual o percentual e o valor financeiro nominal economizado pelo governo
--  (diferenca entre estimado e homologado)?"
-- Prova real: economia nominal R$ 992.861.686,95 | economia % 14,46% (base comparavel).
-- ---------------------------------------------------------------------
SELECT
    ROUND(SUM(CASE WHEN comparavel = 1 THEN valor_total_estimado   ELSE 0 END), 2) AS estimado_comparavel,
    ROUND(SUM(CASE WHEN comparavel = 1 THEN valor_total_homologado ELSE 0 END), 2) AS homologado_comparavel,
    ROUND(SUM(economia_valor), 2)                                                  AS economia_nominal,
    ROUND(
        100 * SUM(economia_valor)
        / NULLIF(SUM(CASE WHEN comparavel = 1 THEN valor_total_estimado ELSE 0 END), 0)
    , 2) AS economia_percentual
FROM fato_item_contratado;


-- ---------------------------------------------------------------------
-- PERGUNTA 2 - Concentracao e risco de fornecedores
-- "Quem sao os maiores fornecedores em volume financeiro e qual percentual
--  do orcamento publico esta concentrado neles?" (os 10 maiores)
-- Volume = soma do valor_total_homologado por fornecedor (ni ja limpo = mesmo fornecedor).
-- ---------------------------------------------------------------------
SELECT
    f.nome_fornecedor,
    f.ni_fornecedor,
    ROUND(SUM(ft.valor_total_homologado), 2) AS volume_homologado,
    ROUND(
        100 * SUM(ft.valor_total_homologado)
        / NULLIF((SELECT SUM(valor_total_homologado) FROM fato_item_contratado), 0)
    , 2) AS percentual_do_orcamento
FROM fato_item_contratado ft
JOIN dim_fornecedor f ON f.sk_fornecedor = ft.sk_fornecedor
GROUP BY f.sk_fornecedor, f.nome_fornecedor, f.ni_fornecedor
ORDER BY volume_homologado DESC
LIMIT 10;


-- ---------------------------------------------------------------------
-- PERGUNTA 3 - Eficacia por modalidade
-- "Quais modalidades licitatorias trazem maior desagio/economia e quais
--  concentram o maior volume de recursos?"
-- Economia % = soma(economia) / soma(estimado comparavel) dentro de cada modalidade.
-- ---------------------------------------------------------------------
SELECT
    m.nome_modalidade,
    ROUND(SUM(ft.valor_total_homologado), 2) AS volume_homologado,
    ROUND(SUM(ft.economia_valor), 2)         AS economia_nominal,
    ROUND(
        100 * SUM(ft.economia_valor)
        / NULLIF(SUM(CASE WHEN ft.comparavel = 1 THEN ft.valor_total_estimado ELSE 0 END), 0)
    , 2) AS economia_percentual
FROM fato_item_contratado ft
JOIN dim_modalidade m ON m.sk_modalidade = ft.sk_modalidade
GROUP BY m.sk_modalidade, m.nome_modalidade
ORDER BY economia_percentual DESC;


-- ---------------------------------------------------------------------
-- PERGUNTA 4 - Tempo do ciclo de compras
-- "Qual a duracao media (em dias) entre o lancamento do edital e a sua
--  homologacao final, segmentada por orgao?"
-- Agrupa pelo NOME do orgao (varias unidades/CNPJ com o mesmo nome contam juntas).
-- Conta so itens com ciclo (dias_ciclo nao nulo) e mantem orgaos com 5 ou mais.
-- ---------------------------------------------------------------------
SELECT
    o.nome_orgao,
    COUNT(ft.dias_ciclo)            AS itens_com_ciclo,
    ROUND(AVG(ft.dias_ciclo), 1)    AS ciclo_medio_dias,
    MAX(ft.dias_ciclo)              AS ciclo_maximo_dias
FROM fato_item_contratado ft
JOIN dim_orgao o ON o.sk_orgao = ft.sk_orgao
WHERE ft.dias_ciclo IS NOT NULL
GROUP BY o.nome_orgao
HAVING COUNT(ft.dias_ciclo) >= 5
ORDER BY ciclo_medio_dias DESC;


-- ---------------------------------------------------------------------
-- PERGUNTA 5 - Distribuicao regional
-- "Quais estados e regioes concentram as maiores despesas e quais
--  apresentam os melhores indicadores de economia?"
-- ---------------------------------------------------------------------
SELECT
    l.regiao,
    l.uf_sigla,
    ROUND(SUM(ft.valor_total_homologado), 2) AS volume_homologado,
    ROUND(SUM(ft.economia_valor), 2)         AS economia_nominal,
    ROUND(
        100 * SUM(ft.economia_valor)
        / NULLIF(SUM(CASE WHEN ft.comparavel = 1 THEN ft.valor_total_estimado ELSE 0 END), 0)
    , 2) AS economia_percentual
FROM fato_item_contratado ft
JOIN dim_localidade l ON l.sk_localidade = ft.sk_localidade
GROUP BY l.regiao, l.uf_sigla
ORDER BY volume_homologado DESC;


-- ---------------------------------------------------------------------
-- PERGUNTA 6 - Perfil dos gastos
-- "Como os recursos se distribuem entre bens, servicos e obras e engenharia?"
-- O perfil_gasto ja esta na propria fato (nao precisa de JOIN).
-- Prova real (% do volume homologado): Obras 60,8% | Servicos 36,6% | Bens 2,6%.
-- ---------------------------------------------------------------------
SELECT
    perfil_gasto,
    COUNT(*)                                 AS qtd_itens,
    ROUND(SUM(valor_total_homologado), 2)    AS volume_homologado,
    ROUND(
        100 * SUM(valor_total_homologado)
        / NULLIF((SELECT SUM(valor_total_homologado) FROM fato_item_contratado), 0)
    , 1) AS percentual_do_volume
FROM fato_item_contratado
GROUP BY perfil_gasto
ORDER BY volume_homologado DESC;
