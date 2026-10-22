# Montagem das 6 páginas do dashboard

Guia prático: para cada página, qual visual criar, quais campos arrastar e a frase
de conclusão (caixa de texto). As medidas estão na tabela `_Medidas` (pastas P1–P6);
as colunas de dimensão estão nas tabelas `pncp_controladoria dim_*`.

Em cada página: renomeie a aba (duplo-clique) e, no fim, adicione uma **caixa de
texto** (Inserir → Caixa de texto) com a conclusão.

---

## Página 1 — Economia  ✅ (feita)
Pergunta: *Quanto o governo economizou?*
- Cartões: `Volume Homologado`, `Economia (R$)`, `Economia %`, `% de Itens Comparáveis`
- Gráfico de colunas: eixo X = `Calendario[Mês]` · eixo Y = `Volume Homologado`
- Conclusão: "O governo economizou R$ 992,86 mi (14,5%) sobre o estimado, considerando
  apenas os 89% de itens comparáveis."

## Página 2 — Fornecedores
Pergunta: *Quem concentra o orçamento? É um risco?*
- Cartão: `Concentração Top 10 %`  (quanto os 10 maiores somam)
- Gráfico de **barras** (horizontais):
  - Eixo Y = `pncp_controladoria dim_fornecedor[nome_fornecedor]`
  - Eixo X = `Volume Homologado`
  - No visual, filtro "N superiores" = 10 (painel Filtros → filtro do campo nome_fornecedor
    → tipo "N principais", 10, por Volume Homologado), para mostrar só o Top 10.
- Conclusão: "Os 10 maiores fornecedores concentram X% do volume homologado —
  indicador de risco de dependência."

## Página 3 — Modalidades
Pergunta: *Qual modalidade economiza mais e qual movimenta mais dinheiro?*
- Gráfico de colunas 1: eixo X = `dim_modalidade[nome_modalidade]` · eixo Y = `Volume Homologado`
- Gráfico de colunas 2: eixo X = `dim_modalidade[nome_modalidade]` · eixo Y = `Economia %`
- (opcional) tabela com `Deságio vs Média Geral (p.p.)` por modalidade
- Conclusão: "O Pregão Eletrônico movimenta o maior volume; as modalidades competitivas
  apresentam maior economia % frente ao Credenciamento."

## Página 4 — Ciclo
Pergunta: *Onde as compras demoram mais?*
- Cartões: `Ciclo Médio (dias)`, `Ciclo Máximo (dias)`, `Itens sem Ciclo`
- Gráfico de **barras**: eixo Y = `dim_orgao[nome_orgao]` · eixo X = `Ciclo Médio (dias)`
  - filtro "N superiores" = 15 por Ciclo Médio (para ver os órgãos mais lentos)
- Conclusão: "O ciclo médio é de 48 dias (máximo de 611); 230 itens ficaram sem ciclo
  por homologação anterior à publicação."

## Página 5 — Regional
Pergunta: *Onde se gasta mais e onde há mais desconto?*
- Cartão: `Qtd Unidades Compradoras`
- Mapa ou gráfico de colunas: eixo = `dim_localidade[regiao]` (ou `uf_sigla`) · valor = `Volume Homologado`
- Gráfico de colunas: eixo = `dim_localidade[regiao]` · valor = `Economia %`
- Conclusão: "O Sudeste concentra o maior volume; algumas regiões apresentam economia %
  acima da média nacional."

## Página 6 — Perfil
Pergunta: *Em que o dinheiro é gasto: bens, serviços ou obras?*
- Gráfico de **rosca** (donut): legenda = `fato_item_contratado[perfil_gasto]` · valores = `Volume Homologado`
- Cartão: `Ticket Médio por Item (R$)`
- Conclusão: "Obras e engenharia respondem por 60,8% do volume, serviços por 36,6% e
  bens por 2,6%."

---

## Toque final (UX — se der tempo)
- **Menu/bookmarks:** Inserir → Botões (um por página); Exibir → Indicadores (bookmarks)
  para navegar. Associe cada botão a um bookmark da página.
- **Tooltip:** crie uma página pequena, marque-a como "Informação de ferramenta"
  (Formatar página → Tipo de página = Dica de ferramenta), e use-a em um visual.
- **Cores/CRAP:** um tema consistente, destaque na cor do indicador-chave de cada página,
  alinhamento em grade.

## Conferência final
Os números têm de bater com a prova real (README): Economia 14,5% · Volume 8,04 bi ·
Perfil Obras 60,8 / Serviços 36,6 / Bens 2,6.

## Salvar e versionar
Arquivo → Salvar (`powerbi/dashboard.pbix`). Depois, no terminal:
`git add powerbi/dashboard.pbix && git commit -m "Adiciona o dashboard do Power BI" && git push`
