#
# 04-06-18 (c) Micael Levi
# Python 3.x
# Responde as questões dos slides.
#

import sys
import csv
import re
from collections import defaultdict
from datetime import datetime, timedelta
from math import floor


# ===================================================== #
FMT_TIMESTAMP = '%d/%m-%H:%M:%S.%f'
TIMESTAMP = 0
FIRST_NODE_ID = 2
SECOND_NODE_ID = 3
TYPE = 4
# ===================================================== #

fn_relacao = lambda row: frozenset([row[FIRST_NODE_ID], row[SECOND_NODE_ID]])

def subTimestamps(t1, t2) -> timedelta:
    return timedelta(seconds=float(t1)) - timedelta(seconds=float(t2))


## A chave é um par; o valor é a quantidade de encontros desse par
encontros = defaultdict(int)
## A chave é um par; o valor é a diferença entre o tempo de `down` pelo de tempo de `up`
duracoes  = defaultdict(str)
qtd_contatos = 0

times_up = defaultdict(str)

diff_reencontros = []
diff_encontros = []
times_encontros = defaultdict(str)

time_up1=''
time_up2=''


if __name__ == '__main__':

    if len(sys.argv) < 1:
        print('ARGS: <arquivo-formato-the-one>')
        sys.exit(1)

    with open(sys.argv[1], 'r') as usense_tratado:
        reader = csv.reader(usense_tratado, delimiter=' ')
        for row in reader:
            rel = fn_relacao(row)

            if row[TYPE] == 'up':
                encontros[rel] += 1
                duracoes[rel] = row[TIMESTAMP]

                if encontros[rel] > 1: ## reencontro
                    diff_reencontro = subTimestamps(row[TIMESTAMP], times_encontros[rel]).total_seconds()
                    diff_reencontros.append(diff_reencontro)
                    del times_encontros[rel] ## Manter apenas o tempo do último encontro

                times_encontros[rel] = row[TIMESTAMP]

            else:
                if rel in times_encontros: ## possui um 'up' associado
                    if not time_up1:
                        time_up1 = times_encontros[rel]
                    else:
                        diff_encontro = subTimestamps(times_encontros[rel], time_up1).total_seconds()
                        diff_encontros.append(diff_encontro)
                        time_up1 = ''

                if type(duracoes[rel]) is str:
                    ## ^^^^^^^^^^^^^^^^^^^^^^^ gambi ~ algum caso tá com `down` sem `up`?
                    qtd_contatos += 1
                    duracoes[rel] = subTimestamps(row[TIMESTAMP], duracoes[rel]).total_seconds()

        usense_tratado.close()

        soma_duracoes = sum( duracoes.values() )
        reencontros = {k: v for k, v in encontros.items() if v > 1}
        soma_reencontros = sum( reencontros.values() )
        qtd_reencontros = len(reencontros)
        soma_diff_encontros = sum(diff_encontros)
        soma_diff_reencontros = sum(diff_reencontros)

        print("(1) Tempo médio entre contatos =", soma_diff_encontros/len(diff_encontros), "segundos")
        print("(2) Duração média dos contatos =", soma_duracoes/qtd_contatos, "segundos")
        print("(3) Número médio de reencontros =", floor(soma_reencontros/qtd_reencontros), "reencontros")
        print("(4) Tempo médio entre reencontros =", soma_diff_reencontros/len(diff_reencontros), "segundos")
