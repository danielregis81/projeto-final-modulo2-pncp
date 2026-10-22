-- =====================================================================
-- 03_views_dashboard.sql  -  Views de apoio ao Power BI (opcional)
-- ---------------------------------------------------------------------
-- Estas views deixam cada pergunta "mastigada" para montar visuais mais
-- rápido no Power BI (arrastar e soltar), sem substituir as medidas DAX.
-- As medidas DAX continuam sendo a resposta oficial; as views só agilizam
-- a prototipagem dos gráficos. Rodar depois de src.carregar.
-- =====================================================================
USE pncp_controladoria;

-- P1 - Economia global (cartões)
CREATE OR REPLACE VIEW vw_economia_global AS
SELECT
    ROUND(SUM(CASE WHEN comparavel = 1 THEN valor_total_estimado ELSE 0 END), 2) AS estimado_comparavel,
    ROUND(SUM(valor_total_homologado), 2)                                        AS volume_homologado,
    ROUND(SUM(economia_valor), 2)                                                AS economia_nominal,
    ROUND(100 * SUM(economia_valor)
          / NULLIF(SUM(CASE WHEN comparavel = 1 THEN valor_total_estimado ELSE 0 END), 0), 2) AS economia_pct,
    ROUND(100 * SUM(comparavel) / COUNT(*), 1)                                   AS pct_itens_comparaveis
FROM fato_item_contratado;

-- P2 - Fornecedores (ranking por volume)
CREATE OR REPLACE VIEW vw_fornecedores AS
SELECT
    f.nome_fornecedor,
    f.ni_fornecedor,
    ROUND(SUM(ft.valor_total_homologado), 2) AS volume_homologado,
    ROUND(100 * SUM(ft.valor_total_homologado)
          / NULLIF((SELECT SUM(valor_total_homologado) FROM fato_item_contratado), 0), 2) AS pct_orcamento
FROM fato_item_contratado ft
JOIN dim_fornecedor f ON f.sk_fornecedor = ft.sk_fornecedor
GROUP BY f.sk_fornecedor, f.nome_fornecedor, f.ni_fornecedor;

-- P3 - Modalidades (volume e economia %)
CREATE OR REPLACE VIEW vw_modalidades AS
SELECT
    m.nome_modalidade,
    ROUND(SUM(ft.valor_total_homologado), 2) AS volume_homologado,
    ROUND(SUM(ft.economia_valor), 2)         AS economia_nominal,
    ROUND(100 * SUM(ft.economia_valor)
          / NULLIF(SUM(CASE WHEN ft.comparavel = 1 THEN ft.valor_total_estimado ELSE 0 END), 0), 2) AS economia_pct
FROM fato_item_contratado ft
JOIN dim_modalidade m ON m.sk_modalidade = ft.sk_modalidade
GROUP BY m.sk_modalidade, m.nome_modalidade;

-- P4 - Ciclo por órgão (>= 5 itens com ciclo)
CREATE OR REPLACE VIEW vw_ciclo_por_orgao AS
SELECT
    o.nome_orgao,
    COUNT(ft.dias_ciclo)         AS itens_com_ciclo,
    ROUND(AVG(ft.dias_ciclo), 1) AS ciclo_medio_dias,
    MAX(ft.dias_ciclo)           AS ciclo_maximo_dias
FROM fato_item_contratado ft
JOIN dim_orgao o ON o.sk_orgao = ft.sk_orgao
WHERE ft.dias_ciclo IS NOT NULL
GROUP BY o.nome_orgao
HAVING COUNT(ft.dias_ciclo) >= 5;

-- P5 - Regional (UF e região)
CREATE OR REPLACE VIEW vw_regional AS
SELECT
    l.regiao,
    l.uf_sigla,
    l.uf_nome,
    ROUND(SUM(ft.valor_total_homologado), 2) AS volume_homologado,
    ROUND(SUM(ft.economia_valor), 2)         AS economia_nominal,
    ROUND(100 * SUM(ft.economia_valor)
          / NULLIF(SUM(CASE WHEN ft.comparavel = 1 THEN ft.valor_total_estimado ELSE 0 END), 0), 2) AS economia_pct
FROM fato_item_contratado ft
JOIN dim_localidade l ON l.sk_localidade = ft.sk_localidade
GROUP BY l.regiao, l.uf_sigla, l.uf_nome;

-- P6 - Perfil do gasto
CREATE OR REPLACE VIEW vw_perfil_gasto AS
SELECT
    perfil_gasto,
    COUNT(*)                              AS qtd_itens,
    ROUND(SUM(valor_total_homologado), 2) AS volume_homologado,
    ROUND(100 * SUM(valor_total_homologado)
          / NULLIF((SELECT SUM(valor_total_homologado) FROM fato_item_contratado), 0), 1) AS pct_volume
FROM fato_item_contratado
GROUP BY perfil_gasto;
