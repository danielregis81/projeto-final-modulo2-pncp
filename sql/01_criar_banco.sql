-- =====================================================================
-- 01_criar_banco.sql  -  Schema estrela (Star Schema) da Controladoria PNCP
-- ---------------------------------------------------------------------
-- Modelo dimensional: 1 FATO (fato_item_contratado) + 4 DIMENSOES
-- (dim_orgao, dim_fornecedor, dim_modalidade, dim_localidade).
--
-- Decisoes de modelagem (secao 4.3 do enunciado):
--   * Toda tabela tem chave substituta (surrogate key, sk_...) como PK.
--   * As dimensoes guardam tambem a chave natural (cnpj_orgao, ni_fornecedor,
--     modalidade_id, uf_sigla) como UNIQUE.
--   * A fato aponta para as dimensoes por FK (integridade referencial).
--   * Dinheiro em DECIMAL(18,2); precos unitarios e quantidades em
--     DECIMAL(18,4); datas em DATE; comparavel em TINYINT (1/0).
--   * CHECK impede valores monetarios negativos (o banco e a 2a barreira).
--   * Cada dimensao recebe a linha "Nao informado" com sk = -1, para que
--     nenhuma FK da fato fique solta (sem destino).
--
-- O script e idempotente: pode ser rodado novamente sem erro.
-- Rodar:  python -m src.carregar   (ele executa este arquivo e carrega os dados)
--         ou abrir no MySQL Workbench e executar.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS pncp_controladoria
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE pncp_controladoria;

-- Recria do zero (a fato sai primeiro por causa das FKs).
DROP TABLE IF EXISTS fato_item_contratado;
DROP TABLE IF EXISTS dim_orgao;
DROP TABLE IF EXISTS dim_fornecedor;
DROP TABLE IF EXISTS dim_modalidade;
DROP TABLE IF EXISTS dim_localidade;

-- ---------------------------------------------------------------------
-- DIMENSAO: ORGAO  (quem comprou)   -  esperado: 363 linhas (+ "Nao informado")
-- ---------------------------------------------------------------------
CREATE TABLE dim_orgao (
    sk_orgao    INT          NOT NULL AUTO_INCREMENT,
    cnpj_orgao  VARCHAR(20)  NOT NULL,
    nome_orgao  VARCHAR(255),
    poder       VARCHAR(20),
    PRIMARY KEY (sk_orgao),
    UNIQUE KEY uq_dim_orgao_cnpj (cnpj_orgao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- DIMENSAO: FORNECEDOR  (quem vendeu)   -  esperado: 2652 linhas (+ "Nao informado")
-- ---------------------------------------------------------------------
CREATE TABLE dim_fornecedor (
    sk_fornecedor   INT          NOT NULL AUTO_INCREMENT,
    ni_fornecedor   VARCHAR(20)  NOT NULL,
    nome_fornecedor VARCHAR(255),
    tipo_pessoa     VARCHAR(2),
    porte           VARCHAR(50),
    PRIMARY KEY (sk_fornecedor),
    UNIQUE KEY uq_dim_fornecedor_ni (ni_fornecedor)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- DIMENSAO: MODALIDADE  (como comprou)   -  esperado: 7 linhas (+ "Nao informado")
-- ---------------------------------------------------------------------
CREATE TABLE dim_modalidade (
    sk_modalidade   INT          NOT NULL AUTO_INCREMENT,
    modalidade_id   INT          NOT NULL,
    nome_modalidade VARCHAR(100),
    PRIMARY KEY (sk_modalidade),
    UNIQUE KEY uq_dim_modalidade_id (modalidade_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- DIMENSAO: LOCALIDADE  (onde)   -  esperado: 27 linhas (+ "Nao informado")
-- ---------------------------------------------------------------------
CREATE TABLE dim_localidade (
    sk_localidade INT          NOT NULL AUTO_INCREMENT,
    uf_sigla      VARCHAR(10)  NOT NULL,
    uf_nome       VARCHAR(100),
    regiao        VARCHAR(20),
    PRIMARY KEY (sk_localidade),
    UNIQUE KEY uq_dim_localidade_uf (uf_sigla)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- LINHA "NAO INFORMADO" (sk = -1) em cada dimensao.
-- Inserir 0 numa coluna AUTO_INCREMENT geraria o proximo numero, por isso
-- desligamos o modo NO_AUTO_VALUE_ON_ZERO ao gravar o -1 explicitamente.
-- ---------------------------------------------------------------------
SET @old_sql_mode = @@SESSION.sql_mode;
SET SESSION sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

INSERT INTO dim_orgao      (sk_orgao, cnpj_orgao, nome_orgao, poder)
    VALUES (-1, 'NAO-INFORMADO', 'Nao informado', 'Nao informado');
INSERT INTO dim_fornecedor (sk_fornecedor, ni_fornecedor, nome_fornecedor, tipo_pessoa, porte)
    VALUES (-1, 'NAO-INFORMADO', 'Nao informado', NULL, NULL);
INSERT INTO dim_modalidade (sk_modalidade, modalidade_id, nome_modalidade)
    VALUES (-1, -1, 'Nao informado');
INSERT INTO dim_localidade (sk_localidade, uf_sigla, uf_nome, regiao)
    VALUES (-1, 'NI', 'Nao informado', 'Nao informado');

SET SESSION sql_mode = @old_sql_mode;

-- ---------------------------------------------------------------------
-- FATO: ITEM CONTRATADO   -  grao: 1 linha por item de contratacao (vencedor)
-- esperado: 6126 linhas.  Chave natural: numero_controle_pncp + numero_item.
-- ---------------------------------------------------------------------
CREATE TABLE fato_item_contratado (
    sk_fato                   INT           NOT NULL AUTO_INCREMENT,
    numero_controle_pncp      VARCHAR(50)   NOT NULL,
    numero_item               INT           NOT NULL,

    -- Chaves estrangeiras para as dimensoes
    sk_orgao                  INT           NOT NULL,
    sk_fornecedor             INT           NOT NULL,
    sk_modalidade             INT           NOT NULL,
    sk_localidade             INT           NOT NULL,

    -- Datas (data_homologacao fica NULL quando a regra 7 anula a cronologia)
    data_publicacao           DATE,
    data_homologacao          DATE,

    -- Descricao e perfil do item
    descricao_item            TEXT,
    perfil_gasto              VARCHAR(30),

    -- Numeros (quantidades e precos em DECIMAL(18,4); totais em DECIMAL(18,2))
    quantidade                DECIMAL(18,4),
    valor_unitario_estimado   DECIMAL(18,4),
    valor_total_estimado      DECIMAL(18,2),
    valor_unitario_homologado DECIMAL(18,4),
    valor_total_homologado    DECIMAL(18,2),

    -- Calculados no Python (regra 6): comparavel (1/0) e economia; dias_ciclo (regra 7)
    comparavel                TINYINT       NOT NULL DEFAULT 0,
    economia_valor            DECIMAL(18,2) NOT NULL DEFAULT 0,
    dias_ciclo                INT,

    PRIMARY KEY (sk_fato),
    UNIQUE KEY uq_fato_item (numero_controle_pncp, numero_item),

    KEY idx_fato_orgao (sk_orgao),
    KEY idx_fato_fornecedor (sk_fornecedor),
    KEY idx_fato_modalidade (sk_modalidade),
    KEY idx_fato_localidade (sk_localidade),

    CONSTRAINT fk_fato_orgao
        FOREIGN KEY (sk_orgao)      REFERENCES dim_orgao (sk_orgao),
    CONSTRAINT fk_fato_fornecedor
        FOREIGN KEY (sk_fornecedor) REFERENCES dim_fornecedor (sk_fornecedor),
    CONSTRAINT fk_fato_modalidade
        FOREIGN KEY (sk_modalidade) REFERENCES dim_modalidade (sk_modalidade),
    CONSTRAINT fk_fato_localidade
        FOREIGN KEY (sk_localidade) REFERENCES dim_localidade (sk_localidade),

    -- 2a barreira (CHECK): o fato nao aceita valores monetarios negativos
    CONSTRAINT ck_fato_qtd           CHECK (quantidade                IS NULL OR quantidade                >= 0),
    CONSTRAINT ck_fato_vu_estimado   CHECK (valor_unitario_estimado   IS NULL OR valor_unitario_estimado   >= 0),
    CONSTRAINT ck_fato_vt_estimado   CHECK (valor_total_estimado      IS NULL OR valor_total_estimado      >= 0),
    CONSTRAINT ck_fato_vu_homologado CHECK (valor_unitario_homologado IS NULL OR valor_unitario_homologado >= 0),
    CONSTRAINT ck_fato_vt_homologado CHECK (valor_total_homologado    IS NULL OR valor_total_homologado    >= 0),
    CONSTRAINT ck_fato_comparavel    CHECK (comparavel IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
