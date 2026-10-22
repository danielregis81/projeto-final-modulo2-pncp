# Roteiro do vídeo (máx. 7 min)

Review de Sprint em tom de apresentação executiva. Câmera aberta (rosto visível),
áudio nítido, tela do computador compartilhada. Vídeo na **horizontal (16:9)**.
Não precisa decorar — deixe este roteiro e o README abertos e vá narrando.

## Divisão do tempo (alvo: ~6 min)

### 0:00–0:40 — Abertura (câmera em você)
- "Oi, sou o Daniel. Este é o projeto de Análise de Dados do PNCP: uma esteira
  ponta a ponta que transforma a base bruta de compras públicas em um dashboard
  executivo para a Controladoria."
- Diga a stack numa frase: "Python para limpar, MySQL em modelo estrela, e Power BI
  para visualizar."

### 0:40–2:00 — Defesa do Python (compartilhe a tela: VS Code em src/limpeza.py e montar_tabelas.py)
- Mostre `src/limpeza.py`: "Cada armadilha da base virou uma função testável."
- Cite 2–3 exemplos concretos:
  - CNPJ: "tiro a máscara e recomponho o zero à esquerda."
  - Moeda: "ponto ou vírgula sozinho é decimal; só o repetido é milhar — por isso o
    volume fecha em 8 bilhões e não explode para 31."
  - Nulos disfarçados: "N/A, SEM INFORMAÇÃO viram nulo de verdade."
- Rode `python -m src.limpeza` e mostre o **54/54 ✔**.
- Mencione o descarte: "99 itens inválidos não entram no fato."

### 2:00–3:15 — Defesa do MySQL (tela: sql/01_criar_banco.sql e, se quiser, Workbench/terminal)
- Abra `sql/01_criar_banco.sql`: "Escolhi esquema estrela: 1 fato e 4 dimensões."
- Aponte: surrogate keys (sk_), chaves naturais UNIQUE, FKs, CHECK contra negativos,
  e a linha 'Não informado' para nenhuma FK ficar solta.
- Diga que a carga é automatizada (`src/carregar.py`, em lote) e confere as contagens.

### 3:15–5:30 — Demonstração do dashboard (tela: Power BI aberto)
- Passe pelas 6 páginas, uma frase de conclusão em cada:
  1. Economia: "Governo economizou R$ 992 mi, 14,5% sobre o estimado."
  2. Fornecedores: "Os 10 maiores concentram X% — sinal de risco."
  3. Modalidades: "Pregão move mais volume; competitivas economizam mais."
  4. Ciclo: "Média de 48 dias entre edital e homologação; máximo de 611."
  5. Regional: "Sudeste concentra o maior gasto."
  6. Perfil: "Obras 60,8%, Serviços 36,6%, Bens 2,6%."
- Passe o mouse sobre um gráfico para mostrar interação; mostre o calendário em DAX.
- Diga: "As 15 medidas são explícitas, em DAX, com VAR/RETURN e CALCULATE."

### 5:30–6:00 — Planejamento e fechamento (câmera em você)
- Mostre a figura das Sprints (docs/img/sprints.png) e o histórico de commits no GitHub:
  "Dividi em sprints, cada uma termina com um número que bate com a prova real."
- Fecho: "Os números do dashboard conferem com o anexo do enunciado — o pipeline é
  confiável e reproduzível só pelo README. Obrigado."

## Como gravar (prático)

1. **Ferramenta:** a mais simples é a **Xbox Game Bar** do Windows (tecla `Win + G` →
   botão de gravar), que grava a tela. Para gravar tela + webcam juntas, use o
   **OBS Studio** (grátis) ou o **Loom** (grátis, grava tela e rosto no canto).
   - Sugestão fácil: Loom ou OBS com uma "webcam no canto" + captura de tela.
2. **Antes de gravar:** deixe abertos o VS Code (nos arquivos citados), o Power BI com
   o dashboard, e a página do GitHub. Assim você só alterna as janelas.
3. **Áudio:** fale pausado, ambiente silencioso. Faça 1 ensaio lendo o roteiro.
4. **NÃO mostre** a janela de senha do MySQL nem o arquivo `.env`.
5. **Exporte** em 16:9 (horizontal). Confira que o áudio ficou audível.
6. **Suba no Google Drive**, defina o compartilhamento como **"qualquer pessoa com o
   link pode ver"** (leitor), e teste o link numa janela anônima.
7. **Cole o link no README** (campo "Defesa técnica em vídeo").

## Dica
Se o tempo apertar, priorize 3:15–5:30 (a demonstração do dashboard) — é onde está o
maior peso visual. O conteúdo técnico detalhado já está escrito na seção
"Defesa técnica (escrita)" do README, que serve de apoio.
