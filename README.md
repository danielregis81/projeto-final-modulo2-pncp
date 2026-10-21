# Análise de Dados com Python + MySQL — Controladoria PNCP

Esteira analítica ponta a ponta (End-to-End) sobre compras e contratações públicas
federais do **Portal Nacional de Contratações Públicas (PNCP)**. O objetivo é
transformar uma base bruta, cheia de inconsistências, em um produto analítico
confiável, auditável e executivo para a Controladoria.

```
PNCP (CSV brutos) → Python (auditoria + limpeza) → MySQL (Star Schema) → Power BI (dashboard)
```

## Contexto do problema

A Controladoria identificou gargalos severos nas compras públicas: indícios de
**sobrepreço**, **concentração** de contratos em grupos econômicos, **morosidade**
entre edital e homologação e **baixa adesão competitiva** em certas modalidades.

Os dados de origem vêm de sistemas legados sem travas de validação: identificadores
corrompidos, valores monetários em texto livre, datas em formatos despadronizados e
inconsistências de cronograma. A missão é liderar uma esteira que entregue à liderança
números em que ela possa confiar para decisão estratégica e auditoria.

- **Fonte:** PNCP / Dados Abertos do Governo Federal (contratações publicadas em 2025).
- **Recorte temporal:** 12 meses consecutivos (02/01/2025 a 31/12/2025).
- **Escopo:** cabeçalho dos certames (órgãos, datas, modalidades) cruzado com os itens
  licitados (valores estimados e homologados, quantidades e descrições).

## Stack

| Camada        | Tecnologia                        | Papel |
|---------------|-----------------------------------|-------|
| Ingestão      | CSV do PNCP (`data/raw/`)         | base bruta, tudo como texto |
| Transformação | Python 3.12 + pandas              | auditoria, limpeza e regras de negócio |
| Armazenamento | MySQL 8.4 (Star Schema)           | 1 fato + 4 dimensões, com integridade |
| Visualização  | Power BI Desktop + DAX            | dashboard executivo (6 perguntas) |

---

> **Status:** em construção. Este README cresce junto com o projeto (uma versão por Sprint).
