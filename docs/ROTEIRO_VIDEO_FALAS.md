# Roteiro do vídeo — falas prontas (é só ler)

Leia em tom de conversa, pausado. Entre colchetes `[ ]` estão as AÇÕES (o que fazer na
tela), não precisa falar. Tempo-alvo: ~6 min. Grave na horizontal (16:9), câmera aberta.

---

## 1. Abertura  [câmera em você]

"Olá, meu nome é Daniel Régis. Vou apresentar o projeto de Análise de Dados das
contratações públicas do PNCP, o Portal Nacional de Contratações Públicas.

O objetivo foi construir uma esteira de dados ponta a ponta: pegar a base bruta,
cheia de inconsistências, e transformar num dashboard executivo e confiável para a
Controladoria. A solução tem três camadas: Python para auditar e limpar os dados,
MySQL com modelagem estrela para armazenar, e Power BI para visualizar."

---

## 2. Python — limpeza  [compartilhe a tela: VS Code em src/limpeza.py]

"Começando pela limpeza em Python. A base de origem não tem nenhuma trava de validação,
então cada problema virou uma função testável aqui no arquivo limpeza.py.

Por exemplo: os CNPJ vinham com máscara e perdendo o zero à esquerda — eu removo a
máscara e recomponho o número no tamanho certo. Os valores em dinheiro vinham como
texto, e a regra desta base é que ponto ou vírgula sozinho é sempre decimal; só o
símbolo repetido é separador de milhar. É por causa dessa regra que o volume total
fecha corretamente em 8 bilhões, e não estoura para 31 bilhões. E os nulos disfarçados,
como 'N/A' ou 'SEM INFORMAÇÃO', eu converto para nulo de verdade.

[rode no terminal: python -m src.limpeza]

Aqui eu rodo o autoteste das funções de limpeza, e ele passa nos 54 casos de teste.

Além de limpar, o pipeline descarta itens inválidos — valores negativos, sigilosos ou
absurdos. São 99 itens rejeitados, que não entram no fato."

---

## 3. MySQL — modelagem  [tela: sql/01_criar_banco.sql]

"Os dados tratados vão para o MySQL, num modelo estrela: uma tabela fato no centro e
quatro dimensões — órgão, fornecedor, modalidade e localidade.

Cada tabela tem uma chave substituta como chave primária, e guarda também a chave
natural como única. A fato se liga às dimensões por chaves estrangeiras, o que garante
a integridade referencial. Também coloquei restrições CHECK para impedir valores
monetários negativos, e uma linha 'Não informado' em cada dimensão, para que nenhuma
chave estrangeira fique sem destino.

A carga é automatizada: um script Python insere os dados em lote e, ao final, confere
as contagens com a prova real do enunciado. O fato tem exatamente 6.126 itens, como
esperado."

---

## 4. Power BI — dashboard  [tela: Power BI aberto, passe pelas 6 páginas]

"Agora o produto final, no Power BI. O modelo estrela foi importado do MySQL, com um
calendário criado em DAX, e quinze medidas explícitas usando CALCULATE, DIVIDE e
variáveis. São seis páginas, uma para cada pergunta de negócio.

[página 1] Economia: o governo economizou cerca de 993 milhões de reais, o que dá 14,5%
sobre o valor estimado, considerando só os itens comparáveis.

[página 2] Fornecedores: os dez maiores fornecedores concentram 41% de todo o volume
homologado — um indicador de risco de dependência.

[página 3] Modalidades: aqui comparo volume e economia por modalidade. O pregão
eletrônico movimenta o maior volume, e as modalidades competitivas economizam mais.

[página 4] Ciclo: o tempo médio entre a publicação do edital e a homologação é de 48
dias, com um caso extremo de 611 dias.

[página 5] Regional: a distribuição por região. O Centro-Oeste concentra o maior
volume de gasto.

[página 6] Perfil do gasto: obras e engenharia representam 60,8% do volume, serviços
36,6% e bens 2,6%.

[passe o mouse sobre um gráfico] Os visuais são interativos, com navegação entre as
páginas."

---

## 5. Planejamento e fecho  [tela: docs/img/sprints.png e o GitHub]

"Por fim, o planejamento. Dividi o trabalho em sprints, e cada sprint termina com algo
conferível — um teste que passa ou um número que bate com a prova real. O histórico de
commits no GitHub mostra essa evolução.

O ponto mais importante: todos os números do dashboard conferem com o anexo de prova
real do enunciado. Isso mostra que o pipeline é confiável e totalmente reproduzível a
partir do README. Era isso, muito obrigado."

---

## Lembretes de gravação
- Não mostre a janela de senha do MySQL nem o arquivo .env.
- Áudio nítido, ambiente silencioso, 1 ensaio antes.
- Exporte em 16:9, suba no Google Drive como "qualquer pessoa com o link", teste em aba anônima.
- Cole o link no README.
