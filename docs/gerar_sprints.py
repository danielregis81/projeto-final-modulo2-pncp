"""
gerar_sprints.py  -  desenha o quadro de Sprints do projeto (docs/img/sprints.png)
----------------------------------------------------------------------------------
Gera uma figura limpa (estilo quadro Kanban/cronograma) com as 8 sprints, seus
objetivos, o "como saber que acabou" e o status. Versionada para a figura ser
reproduzível. Rodar:  python docs/gerar_sprints.py
"""

from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

SAIDA = Path(__file__).resolve().parent / "img" / "sprints.png"

# (numero, objetivo, entrega/"como saber que acabou", status)
SPRINTS = [
    ("0", "Repositório, planejamento e entender os dados",
     "Dicionário dos CSV descrito; sujeiras mapeadas", "Done"),
    ("1", "Auditar (contar os problemas)",
     "Cada inconsistência anotada e quantificada", "Done"),
    ("2", "Limpar — completar src/limpeza.py",
     "python -m src.limpeza → 54/54 ✔", "Done"),
    ("3", "Montar fato e dimensões (regras da seção 4)",
     "Linhas e somas batem com o anexo 8", "Done"),
    ("4", "Banco — schema SQL e carga no MySQL",
     "Contagens no banco = prova real; sem FK solta", "Done"),
    ("5", "Perguntas em SQL",
     "As 6 respostas batem com o dashboard", "Done"),
    ("6", "Power BI — 15 medidas e 1 história por pergunta",
     "Medidas e páginas respondem as 6 perguntas", "In Progress"),
    ("7", "README, figura das Sprints e vídeo",
     "Projeto reproduzível só lendo o README", "In Progress"),
]

CORES = {
    "Done":        ("#1b7f4b", "#e4f3ea"),   # verde
    "In Progress": ("#b5820a", "#fcf3dd"),   # ambar
    "To Do":       ("#555555", "#eeeeee"),   # cinza
}


def main():
    SAIDA.parent.mkdir(parents=True, exist_ok=True)
    n = len(SPRINTS)
    fig, ax = plt.subplots(figsize=(12, 7.4))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, n + 1.6)
    ax.axis("off")

    # Titulo
    ax.text(0.1, n + 1.15, "Planejamento em Sprints — Controladoria PNCP",
            fontsize=18, fontweight="bold", color="#1f2a44")
    ax.text(0.1, n + 0.75,
            "Esteira End-to-End: PNCP → Python → MySQL → Power BI   |   cada Sprint termina com algo conferível",
            fontsize=10.5, color="#5a6475")

    # Cabecalho de colunas
    ax.text(0.95, n + 0.25, "SPRINT", fontsize=9.5, fontweight="bold", color="#8893a5")
    ax.text(2.1, n + 0.25, "OBJETIVO", fontsize=9.5, fontweight="bold", color="#8893a5")
    ax.text(6.75, n + 0.25, "COMO SABER QUE ACABOU", fontsize=9.5, fontweight="bold", color="#8893a5")
    ax.text(10.95, n + 0.25, "STATUS", fontsize=9.5, fontweight="bold", color="#8893a5")

    for i, (num, obj, entrega, status) in enumerate(SPRINTS):
        y = n - i - 0.2
        borda, fundo = CORES[status]

        # Faixa da linha
        ax.add_patch(FancyBboxPatch((0.1, y - 0.33), 11.8, 0.74,
                     boxstyle="round,pad=0.02,rounding_size=0.08",
                     linewidth=1, edgecolor="#dfe3ea", facecolor="#ffffff"))

        # Bolha do numero da sprint
        ax.add_patch(FancyBboxPatch((0.35, y - 0.22), 0.55, 0.55,
                     boxstyle="round,pad=0.02,rounding_size=0.12",
                     linewidth=1.5, edgecolor=borda, facecolor=fundo))
        ax.text(0.625, y + 0.03, num, fontsize=13, fontweight="bold",
                color=borda, ha="center", va="center")

        ax.text(2.1, y + 0.02, obj, fontsize=10.2, color="#1f2a44", va="center")
        ax.text(6.75, y + 0.02, entrega, fontsize=8.8, color="#5a6475", va="center")

        # Pilula de status
        ax.add_patch(FancyBboxPatch((10.9, y - 0.17), 0.95, 0.42,
                     boxstyle="round,pad=0.02,rounding_size=0.2",
                     linewidth=0, facecolor=borda))
        ax.text(11.375, y + 0.04, status, fontsize=8.6, fontweight="bold",
                color="white", ha="center", va="center")

    fig.savefig(SAIDA, dpi=150, bbox_inches="tight", facecolor="#f6f7f9")
    print(f"figura gerada: {SAIDA}")


if __name__ == "__main__":
    main()
