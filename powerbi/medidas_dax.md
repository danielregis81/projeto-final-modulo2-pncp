# 15 Medidas DAX — Controladoria PNCP

Medidas da tabela dedicada **`_Medidas`** (crie uma tabela vazia só para elas; nada de
soma implícita arrastando coluna). Percentuais usam sempre `DIVIDE(soma, soma)`, nunca
média de percentuais. Organize em pastas de exibição por pergunta (P1…P6).

> Como criar a tabela de medidas: *Página Inicial → Inserir dados → Nova tabela* (deixe
> em branco) com nome `_Medidas`. Depois *Nova medida* e cole cada fórmula abaixo.

Convenção: `fato` = `fato_item_contratado`.

---

## P1 — Economia (quanto o governo economizou?)

### 1. Valor Estimado Comparável
Soma do valor estimado só dos itens comparáveis.
```DAX
Valor Estimado Comparável =
CALCULATE (
    SUM ( fato[valor_total_estimado] ),
    fato[comparavel] = 1
)
```

### 2. Volume Homologado
Soma do valor total homologado de todos os itens.
```DAX
Volume Homologado = SUM ( fato[valor_total_homologado] )
```

### 3. Economia (R$)
Estimado − homologado, só nos itens comparáveis.
```DAX
Economia (R$) =
VAR EstimadoComp =
    CALCULATE ( SUM ( fato[valor_total_estimado] ), fato[comparavel] = 1 )
VAR HomologadoComp =
    CALCULATE ( SUM ( fato[valor_total_homologado] ), fato[comparavel] = 1 )
RETURN
    EstimadoComp - HomologadoComp
```

### 4. Economia %
Economia (R$) ÷ Valor Estimado Comparável.
```DAX
Economia % =
DIVIDE ( [Economia (R$)], [Valor Estimado Comparável] )
```

### 5. % de Itens Comparáveis
Itens comparáveis ÷ total de itens (mostra quanto da base entra no cálculo da economia).
```DAX
% de Itens Comparáveis =
DIVIDE (
    CALCULATE ( COUNTROWS ( fato ), fato[comparavel] = 1 ),
    COUNTROWS ( fato )
)
```

---

## P2 — Fornecedores (quem concentra o orçamento? é um risco?)

### 6. Participação do Fornecedor %
Volume do fornecedor ÷ volume total (o total ignora o filtro de fornecedor).
```DAX
Participação do Fornecedor % =
DIVIDE (
    [Volume Homologado],
    CALCULATE ( [Volume Homologado], ALL ( dim_fornecedor ) )
)
```

### 7. Ranking do Fornecedor
Posição do fornecedor por volume (1º, 2º, 3º…).
```DAX
Ranking do Fornecedor =
RANKX (
    ALL ( dim_fornecedor[nome_fornecedor] ),
    [Volume Homologado],
    ,
    DESC
)
```

### 8. Concentração Top 10 %
Volume dos 10 maiores fornecedores ÷ volume total.
```DAX
Concentração Top 10 % =
VAR Total = CALCULATE ( [Volume Homologado], ALL ( dim_fornecedor ) )
VAR Top10 =
    CALCULATE (
        [Volume Homologado],
        KEEPFILTERS (
            TOPN ( 10, ALL ( dim_fornecedor[nome_fornecedor] ), [Volume Homologado], DESC )
        )
    )
RETURN
    DIVIDE ( Top10, Total )
```

---

## P3 — Modalidades (qual economiza mais e qual movimenta mais dinheiro?)

### 9. Participação no Volume %
Volume da linha atual (modalidade, UF, perfil…) ÷ volume total.
```DAX
Participação no Volume % =
DIVIDE (
    [Volume Homologado],
    CALCULATE ( [Volume Homologado], ALLSELECTED () )
)
```

### 10. Deságio vs Média Geral (p.p.)
Economia % da linha atual − Economia % geral (sem filtro), em pontos percentuais.
```DAX
Deságio vs Média Geral (p.p.) =
VAR EconLinha = [Economia %]
VAR EconGeral = CALCULATE ( [Economia %], REMOVEFILTERS () )
RETURN
    ( EconLinha - EconGeral ) * 100
```
> Formate como número com 1 casa decimal (ex.: 2,5), nunca como %.

---

## P4 — Ciclo (onde as compras demoram mais?)

### 11. Ciclo Médio (dias)
Média dos dias entre publicação e homologação; itens sem ciclo ficam de fora
(a média do DAX já ignora os vazios).
```DAX
Ciclo Médio (dias) = AVERAGE ( fato[dias_ciclo] )
```

### 12. Ciclo Máximo (dias)
Maior ciclo observado.
```DAX
Ciclo Máximo (dias) = MAX ( fato[dias_ciclo] )
```

### 13. Itens sem Ciclo
Itens cuja homologação ficou sem data (total de itens − itens com ciclo).
```DAX
Itens sem Ciclo =
COUNTROWS ( fato ) - COUNT ( fato[dias_ciclo] )
```

---

## P5 — Regional (onde se gasta mais e onde se consegue mais desconto?)

### 14. Qtd Unidades Compradoras
Número de CNPJ de órgão distintos (cada CNPJ é uma unidade compradora).
```DAX
Qtd Unidades Compradoras =
DISTINCTCOUNT ( dim_orgao[cnpj_orgao] )
```

---

## P6 — Perfil (bens, serviços ou obras?)

### 15. Ticket Médio por Item (R$)
Volume homologado ÷ quantidade de itens.
```DAX
Ticket Médio por Item (R$) =
DIVIDE ( [Volume Homologado], COUNTROWS ( fato ) )
```

---

## Medidas extras (opcionais, enriquecem a história)

### Itens com Sobrepreço
Itens em que o homologado superou o estimado.
```DAX
Itens com Sobrepreço =
CALCULATE (
    COUNTROWS ( fato ),
    fato[valor_total_homologado] > fato[valor_total_estimado]
)
```

### Variação Mensal % (volume vs mês anterior)
```DAX
Variação Mensal % =
VAR Atual = [Volume Homologado]
VAR Anterior =
    CALCULATE ( [Volume Homologado], DATEADD ( Calendario[Data], -1, MONTH ) )
RETURN
    DIVIDE ( Atual - Anterior, Anterior )
```

### Volume Acumulado no Ano
```DAX
Volume Acumulado no Ano =
CALCULATE (
    [Volume Homologado],
    DATESYTD ( Calendario[Data] )
)
```

---

## Mapa pergunta → página → medidas

| Página | Pergunta | Medidas |
|--------|----------|---------|
| 1 Economia    | Quanto o governo economizou?               | 1, 2, 3, 4, 5 |
| 2 Fornecedores| Quem concentra o orçamento? É um risco?    | 2, 6, 7, 8 |
| 3 Modalidades | Qual economiza mais e qual movimenta mais? | 2, 4, 5, 9, 10 |
| 4 Ciclo       | Onde as compras demoram mais?              | 11, 12, 13 |
| 5 Regional    | Onde se gasta mais e onde há mais desconto?| 2, 4, 9, 14 |
| 6 Perfil      | Em que o dinheiro é gasto?                 | 2, 4, 9, 15 |
