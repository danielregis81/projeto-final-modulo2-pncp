# Power BI — modo express (ganhar tempo)

Sequência mínima de cliques. Tudo já está instalado nesta máquina (Power BI Desktop,
MySQL Connector/NET 8.4, Tabular Editor 2) e o MySQL está carregado.

> Se o MySQL não estiver no ar, suba com:
> `& "C:\mysql84\mysql-8.4.0-winx64\bin\mysqld.exe" --datadir=C:\mysql84\data --console`

## 1. Conectar (2 min)
1. Abra o **Power BI Desktop** → *Obter dados* → **Banco de dados MySQL**.
2. Servidor `127.0.0.1:3306` · Banco `pncp_controladoria` → OK.
3. Credenciais, aba **Banco de dados**: usuário `root`, senha `projeto_pncp_2026` → Conectar.
   (Aviso de conexão não criptografada → OK.)
4. Marque **as 5 tabelas** (`fato_item_contratado`, `dim_orgao`, `dim_fornecedor`,
   `dim_modalidade`, `dim_localidade`) → **Carregar**.
   - *(Opcional, p/ prototipar gráficos rápido: marque também as views `vw_*`.)*

## 2. Desligar data automática (30 s)
*Arquivo → Opções → Arquivo atual → Carregamento de dados* → desmarque
**"Hora/data automática"**.

## 3. Calendário DAX (1 min)
*Modelagem → Nova tabela* e cole (fórmula completa em `GUIA_POWERBI.md` §3):
```DAX
Calendario =
ADDCOLUMNS ( CALENDAR ( DATE(2025,1,1), DATE(2025,12,31) ),
  "Ano", YEAR([Data]), "MesNum", MONTH([Data]),
  "Mês", FORMAT([Data],"MMM","pt-BR"), "Ano-Mês", FORMAT([Data],"MMM/YY","pt-BR") )
```
- Marque como **tabela de datas** e ordene *Mês* por *MesNum*.

## 4. Relações (1 min)
Na *Visão de Modelo*, arraste `sk_` de cada dimensão para o fato (4 relações 1:N) e
`Calendario[Data]` → `fato[data_publicacao]`. Esconda as colunas `sk_`.

## 5. As 15 medidas num clique (1 min) — Tabular Editor
1. Aba **Ferramentas Externas** → **Tabular Editor**
   (se não aparecer o botão, abra `%LOCALAPPDATA%\TabularEditor2\TabularEditor.exe` e
   conecte em *File → Open → From DB* na instância local do Power BI).
2. Aba **C# Script** → cole todo o `criar_medidas.tabulareditor.cs` → **Executar (F5)**.
3. **Ctrl+S** (grava as medidas no modelo). Volte ao Power BI: a tabela `_Medidas`
   aparece com as 15 medidas (+3 extras) em pastas P1…P6.

## 6. Montar as 6 páginas (o grosso do tempo)
Uma página por pergunta. Mínimo viável por página:
- **Cartões** com as medidas da pergunta (ver tabela em `medidas_dax.md`).
- **1 gráfico** (barras/rosca/mapa) + **1 caixa de texto** com a conclusão.

| Página | Gráfico rápido | Eixo / Valores |
|--------|----------------|----------------|
| 1 Economia | cartões | Economia (R$), Economia %, Volume Homologado |
| 2 Fornecedores | barras | nome_fornecedor × Volume Homologado (Top 10) |
| 3 Modalidades | barras | nome_modalidade × Volume e Economia % |
| 4 Ciclo | barras | nome_orgao × Ciclo Médio (dias) |
| 5 Regional | mapa/treemap | uf_sigla × Volume Homologado |
| 6 Perfil | rosca | perfil_gasto × Volume Homologado |

## 7. UX (se sobrar tempo)
- *Inserir → Botões* + *Exibir → Indicadores* (bookmarks) para o menu.
- Uma página marcada como **Informação de ferramenta** (tooltip) em *Formatar página*.

## 8. Salvar e versionar
Salve em `powerbi/dashboard.pbix`. Depois no terminal:
```
git add powerbi/dashboard.pbix
git commit -m "Adiciona o dashboard do Power BI (.pbix)"
git push
```

## Conferência
Os números têm de bater com a prova real (README) e com `vw_economia_global`
(Economia 14,46%; perfil Obras 60,8 / Serviços 36,6 / Bens 2,6).
