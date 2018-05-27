#
# 27-05-2018 (c) Micael Levi L. C.
#
# Deve ser executado no diretório "social-interaction"
# E usará o arquivo "SocialsStrength.csv" (passado como argumento)
#
# Vai gerar um arquivo de nome "base_final.tsv" quase
# no formatado requerido pelo professor.
# O tempo (primeira coluna) continua o original do dataset,
# mas os demais campos já seguem o formato desejado.
#

import sys
import csv
from datetime import datetime, timedelta
fmt_timestamp = '%d/%m-%H:%M:%S.%f'

D = {}
T = {}

ultimo_type = {}
ultimo_timestamp = {}
resultados = []

def relacao(a, b): return a + '_' + b

def printar(*colunas):
#     print( '\t'.join([*colunas]) )
    resultados.append([*colunas])

def subTimestamp(t1, secs = '60'):
    diferenca = datetime.strptime(t1, fmt_timestamp) - timedelta(seconds=float(secs))
    return diferenca.strftime(fmt_timestamp)

def operar_sobre_linha(timestamp, action, a, b, d):
    rel = relacao(a, b)

    if rel not in T: # 1
        if d != '0': # 1.1
            printar( subTimestamp(timestamp, d), action, a, b, 'upA' ) # 1.1.1
            T[rel] = timestamp # 1.2
            ultimo_type[rel] = 'up'

    elif T[rel] == -1: # 2
        if d != D[rel]: # 2.1
            if d != '0': # 1.1
                printar( subTimestamp(timestamp, d), action, a, b, 'upB' ) # 1.1.1
                T[rel] = timestamp # 1.2
                ultimo_type[rel] = 'up'

    else: # 3
        if d == D[rel]: # 3.1
            printar( T[rel], action, a, b, 'downA' ) # 3.1.1
            T[rel] = -1 # 3.1.2
            ultimo_type[rel] = 'down'
        elif d != '0': # 3.2
            if float(d) >= float(D[rel]): # 3.2.1
                T[rel] = timestamp
            else: # 3.2.2
                printar( T[rel], action, a, b, 'downB') # 3.2.1
                printar( subTimestamp(timestamp, d), action, a, b, 'upC') # 3.2.2
                ultimo_type[rel] = 'up'
        else: # 3.3
            printar( subTimestamp(timestamp), action, a, b, 'downC') # 3.3.1
            T[rel] = -1 # 3.3.2
            ultimo_type[rel] = 'up'

    D[rel] = d # 4
    ultimo_timestamp[rel] = timestamp


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("USAR: <arquivo-entrada.csv> <arquivo-saida.tsv>")
        sys.exit(1)

    print('Executando...')
    with open(sys.argv[1], 'r', newline='') as csvinfile:
        reader = csv.DictReader(csvinfile, delimiter=';')
        for row in reader:
            operar_sobre_linha(row['timestamp'], row['action'], row['first_node_ID'], row['second_node_ID'], row['encounter_duration'])
        csvinfile.close()

        # adicionar os 'down' que não foram captados
        for rel in ultimo_type:
            if ultimo_type[rel] == 'up':
                [a, b] = rel.split('_')
                resultados.append([ ultimo_timestamp[rel], 'CONN', a, b, 'down' ])

        # salvar ordenado pelo timestamp num arquivo .tsv
        with open(sys.argv[2], 'w', newline='') as csvoutfile:
            writer = csv.writer(csvoutfile, delimiter='\t')
            resultados_ordenados = sorted(resultados, key=lambda linha: linha[0])
            writer.writerows(resultados_ordenados)
            csvoutfile.close()
            print('arquivo "' + sys.argv[2] + '" criado')
