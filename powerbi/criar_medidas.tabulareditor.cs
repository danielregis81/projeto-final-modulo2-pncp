// =====================================================================
// criar_medidas.tabulareditor.cs
// ---------------------------------------------------------------------
// Script do Tabular Editor 2 (gratuito) que cria a tabela "_Medidas" e as
// 15 medidas obrigatorias (+ 3 extras) de uma vez so, poupando digitacao
// manual no Power BI.
//
// COMO USAR (depois de importar as 5 tabelas no Power BI Desktop):
//   1. Power BI Desktop -> aba Ferramentas Externas -> Tabular Editor
//      (se nao aparecer, abra o TabularEditor.exe e conecte na instancia
//       do Power BI: menu File > Open > From DB... escolha a porta local
//       "localhost:xxxxx" que o Power BI expoe).
//   2. No Tabular Editor: menu "C# Script" (ou "Advanced Scripting"),
//      cole TODO este arquivo e clique em Executar (F5).
//   3. Salve (Ctrl+S) para gravar as medidas de volta no modelo do Power BI.
//
// Observacao: ajusta a tabela base "fato_item_contratado". Se o Power BI
// tiver importado com outro nome, troque a constante FATO abaixo.
// =====================================================================

var FATO = "fato_item_contratado";
var CAL  = "Calendario";

// 1) cria (ou reaproveita) a tabela de medidas, sem coluna de dados
Table tbl;
if (Model.Tables.Contains("_Medidas"))
    tbl = Model.Tables["_Medidas"];
else
    tbl = Model.AddCalculatedTable("_Medidas", "{BLANK()}");

// helper para criar/atualizar medida
Action<string,string,string,string> M = (nome, dax, pasta, formato) => {
    Measure m = tbl.Measures.Contains(nome) ? tbl.Measures[nome] : tbl.AddMeasure(nome);
    m.Expression = dax;
    m.DisplayFolder = pasta;
    if (!string.IsNullOrEmpty(formato)) m.FormatString = formato;
};

var MOEDA = "#,0.00";
var PCT   = "0.0%";
var INT   = "#,0";

// ---------- P1 Economia ----------
M("Valor Estimado Comparável",
  "CALCULATE ( SUM ( " + FATO + "[valor_total_estimado] ), " + FATO + "[comparavel] = 1 )",
  "P1 Economia", MOEDA);

M("Volume Homologado",
  "SUM ( " + FATO + "[valor_total_homologado] )",
  "P1 Economia", MOEDA);

M("Economia (R$)",
  "VAR EstimadoComp = CALCULATE ( SUM ( " + FATO + "[valor_total_estimado] ), " + FATO + "[comparavel] = 1 ) " +
  "VAR HomologadoComp = CALCULATE ( SUM ( " + FATO + "[valor_total_homologado] ), " + FATO + "[comparavel] = 1 ) " +
  "RETURN EstimadoComp - HomologadoComp",
  "P1 Economia", MOEDA);

M("Economia %",
  "DIVIDE ( [Economia (R$)], [Valor Estimado Comparável] )",
  "P1 Economia", PCT);

M("% de Itens Comparáveis",
  "DIVIDE ( CALCULATE ( COUNTROWS ( " + FATO + " ), " + FATO + "[comparavel] = 1 ), COUNTROWS ( " + FATO + " ) )",
  "P1 Economia", PCT);

// ---------- P2 Fornecedores ----------
M("Participação do Fornecedor %",
  "DIVIDE ( [Volume Homologado], CALCULATE ( [Volume Homologado], ALL ( dim_fornecedor ) ) )",
  "P2 Fornecedores", PCT);

M("Ranking do Fornecedor",
  "RANKX ( ALL ( dim_fornecedor[nome_fornecedor] ), [Volume Homologado],, DESC )",
  "P2 Fornecedores", INT);

M("Concentração Top 10 %",
  "VAR Total = CALCULATE ( [Volume Homologado], ALL ( dim_fornecedor ) ) " +
  "VAR Top10 = CALCULATE ( [Volume Homologado], KEEPFILTERS ( TOPN ( 10, ALL ( dim_fornecedor[nome_fornecedor] ), [Volume Homologado], DESC ) ) ) " +
  "RETURN DIVIDE ( Top10, Total )",
  "P2 Fornecedores", PCT);

// ---------- P3 Modalidades ----------
M("Participação no Volume %",
  "DIVIDE ( [Volume Homologado], CALCULATE ( [Volume Homologado], ALLSELECTED () ) )",
  "P3 Modalidades", PCT);

M("Deságio vs Média Geral (p.p.)",
  "VAR EconLinha = [Economia %] " +
  "VAR EconGeral = CALCULATE ( [Economia %], REMOVEFILTERS () ) " +
  "RETURN ( EconLinha - EconGeral ) * 100",
  "P3 Modalidades", "0.0");

// ---------- P4 Ciclo ----------
M("Ciclo Médio (dias)",
  "AVERAGE ( " + FATO + "[dias_ciclo] )",
  "P4 Ciclo", "0.0");

M("Ciclo Máximo (dias)",
  "MAX ( " + FATO + "[dias_ciclo] )",
  "P4 Ciclo", INT);

M("Itens sem Ciclo",
  "COUNTROWS ( " + FATO + " ) - COUNT ( " + FATO + "[dias_ciclo] )",
  "P4 Ciclo", INT);

// ---------- P5 Regional ----------
M("Qtd Unidades Compradoras",
  "DISTINCTCOUNT ( dim_orgao[cnpj_orgao] )",
  "P5 Regional", INT);

// ---------- P6 Perfil ----------
M("Ticket Médio por Item (R$)",
  "DIVIDE ( [Volume Homologado], COUNTROWS ( " + FATO + " ) )",
  "P6 Perfil", MOEDA);

// ---------- Extras (opcionais) ----------
M("Itens com Sobrepreço",
  "CALCULATE ( COUNTROWS ( " + FATO + " ), " + FATO + "[valor_total_homologado] > " + FATO + "[valor_total_estimado] )",
  "Extras", INT);

M("Variação Mensal %",
  "VAR Atual = [Volume Homologado] " +
  "VAR Anterior = CALCULATE ( [Volume Homologado], DATEADD ( " + CAL + "[Date], -1, MONTH ) ) " +
  "RETURN DIVIDE ( Atual - Anterior, Anterior )",
  "Extras", PCT);

M("Volume Acumulado no Ano",
  "CALCULATE ( [Volume Homologado], DATESYTD ( " + CAL + "[Date] ) )",
  "Extras", MOEDA);

Info("Pronto: tabela _Medidas criada/atualizada com as medidas. Salve com Ctrl+S.");
