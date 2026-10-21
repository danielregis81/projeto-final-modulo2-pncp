# Guia de montagem do Power BI

Passo a passo para montar o `dashboard.pbix` a partir do banco `pncp_controladoria`.
As 15 medidas estão em [`medidas_dax.md`](medidas_dax.md).

## 1. Conectar ao MySQL
1. Instale o **MySQL Connector/NET 8.x** (site oficial `dev.mysql.com`). Sem ele o
   Power BI acusa "provedor MySql.Data.MySqlClient não encontrado".
2. Power BI Desktop → *Obter dados → Mais… → Banco de dados MySQL*.
3. Servidor: `127.0.0.1:3306` | Banco: `pncp_controladoria`.
4. Credenciais na aba **Banco de dados** (usuário/senha do MySQL). Se avisar que a
   conexão não é criptografada, clique em OK (é banco local).
5. No Navegador, marque **as 5 tabelas** do modelo (`fato_item_contratado`,
   `dim_orgao`, `dim_fornecedor`, `dim_modalidade`, `dim_localidade`) e **Carregar**.
6. Se aparecer uma coluna extra de relacionamento no fim de cada tabela, desmarque
   "Incluir colunas de relacionamento ao importar" ou ignore-a.

## 2. Desligar a hierarquia automática de data
*Arquivo → Opções → Arquivo atual → Carregamento de dados* → **desmarque**
"Hora/data automática". (Exigência do enunciado: o calendário é em DAX.)

## 3. Criar o Calendário em DAX
*Modelagem → Nova tabela*:

```DAX
Calendario =
VAR MinData = MIN ( fato_item_contratado[data_publicacao] )
VAR MaxData =
    MAXX (
        fato_item_contratado,
        MAX ( fato_item_contratado[data_publicacao], fato_item_contratado[data_homologacao] )
    )
RETURN
ADDCOLUMNS (
    CALENDAR ( MinData, MaxData ),
    "Ano", YEAR ( [Data] ),
    "MesNum", MONTH ( [Data] ),
    "Mês", FORMAT ( [Data], "MMM", "pt-BR" ),
    "AnoMes", FORMAT ( [Data], "YYYY-MM" ),
    "Ano-Mês", FORMAT ( [Data], "MMM/YY", "pt-BR" )
)
```

- Marque `Calendario` como **tabela de datas** (*Ferramentas de tabela → Marcar como
  tabela de data* → coluna `Data`).
- Ordene a coluna **Mês** pela coluna **MesNum** (*Classificar por coluna*), para os
  meses aparecerem em ordem cronológica, não alfabética.

## 4. Relacionamentos
Na *Visão de Modelo*, crie relações **1:N** das dimensões para a fato (uma por `sk_`):
- `dim_orgao[sk_orgao]` → `fato_item_contratado[sk_orgao]`
- `dim_fornecedor[sk_fornecedor]` → `fato_item_contratado[sk_fornecedor]`
- `dim_modalidade[sk_modalidade]` → `fato_item_contratado[sk_modalidade]`
- `dim_localidade[sk_localidade]` → `fato_item_contratado[sk_localidade]`
- `Calendario[Data]` → `fato[data_publicacao]` (relação **ativa**) e
  `Calendario[Data]` → `fato[data_homologacao]` (relação inativa; use `USERELATIONSHIP`
  quando precisar medir pela homologação).

Esconda as colunas técnicas (`sk_...`) do modo de exibição de relatório.

## 5. Criar as 15 medidas
Crie a tabela `_Medidas` (vazia) e cole as fórmulas de `medidas_dax.md`, organizadas em
pastas de exibição P1…P6.

## 6. Montar as 6 páginas (uma por pergunta)
Cada página = **pergunta (título) → números (cartões/visuais) → conclusão (caixa de texto)**.

| Página | Visual sugerido | Medidas |
|--------|-----------------|---------|
| 1 Economia    | cartões (Economia R$, Economia %) + barras estimado×homologado | 1–5 |
| 2 Fornecedores| barras Top 10 por volume + cartão Concentração Top 10 % | 2, 6, 7, 8 |
| 3 Modalidades | barras por modalidade (volume e economia %)            | 2, 4, 5, 9, 10 |
| 4 Ciclo       | barras ciclo médio por órgão + cartões médio/máximo    | 11, 12, 13 |
| 5 Regional    | mapa/treemap por UF e região                           | 2, 4, 9, 14 |
| 6 Perfil      | rosca bens/serviços/obras + cartão ticket médio        | 2, 4, 9, 15 |

## 7. Recursos avançados (UX)
- **Menu retrátil** com botões e indicadores (*bookmarks*) para navegar entre páginas.
- **Página de tooltip** personalizada para detalhar ao passar o mouse.
- **Princípios CRAP:** contraste, repetição, alinhamento, proximidade; cores com
  propósito (destacar o que importa).

## 8. Conferência
Os números do dashboard devem bater com a **prova real** (ver README) e com
`sql/02_perguntas.sql`. Ex.: Economia % = 14,46%; perfil Obras 60,8 / Serviços 36,6 /
Bens 2,6.

## 9. Salvar
Salve como `powerbi/dashboard.pbix` e versione o arquivo no repositório.
