#
# 01-06-18 (c) Micael Levi
# Python 3.x
# A priori, deve ser executado no diretório raiz de cada experimento.
#
# - remove todos os espaços nos campos;
# - converte os valores de `device name` em IDs únicos;
# - adiciona a coluna `action` (após a coluna `timestamp`);
# - adicionar a coluna `first_node_ID` (após a coluna `action`);
# - remove as últimas 3 colunas de todas as linhas;
# - une as observações de todos os dispositivos Usense;
# - usando as heurísticas citadas no relatório, define os valores da coluna `type`;
# - converte o tempo do `timestamp` para segundos;
# - gera um arquivo de nome `base_final.csv` no formato pedido (ordenado pelo `time`);
#

import sys
import csv
import re
from collections import OrderedDict
from datetime import datetime, timedelta


FMT_TIMESTAMP = '%d/%m-%H:%M:%S.%f'
IDENTIFICADORES_USENSES = [2, 3, 4, 5]
device_name_id_counter = 3
regex_usense = re.compile('Usense(\d+)') ## Como os device name usenses estão identificados
D = {}
T = {}
ultimo_type = {}
timestamp_ultimo_up = {}
ultimo_encounter_duration_valido = {}
unidos = [] ## Lista com todas as linhas dos usenses
final = [] ## Lista com todas as linhas dos usense tratadas e com a coluna `type`


# ===================================================== #
# colunas úteis do arquivo `SocialStrenght.dat`
TIMESTAMP = 0
SECOND_DEVICE_NAME = 1
ENCOUNTER_DURATION = 2
# ===================================================== #


# ===================================================== #
# tratadores
fn_remover_barra = lambda s: re.sub('/\s*$', '', s)
fn_remover_espacos = lambda s: re.sub('[\s+]', '', s)
fn_normalizar_usense_name = lambda s: int(s) - IDENTIFICADORES_USENSES[0]
fn_relacao = lambda a, b: str(a) + '_' + str(b)

def get_next_id():
    global device_name_id_counter
    device_name_id_counter += 1
    return device_name_id_counter

def gerar_ID(device_name):
    if isinstance(device_name, int):
        return fn_normalizar_usense_name(device_name)

    num_usense_str = regex_usense.match(device_name)
    return (fn_normalizar_usense_name(num_usense_str.group(1))
            if num_usense_str
            else get_next_id())

def subTimestamp(t, secs = '60'):
    diferenca = datetime.strptime(t, FMT_TIMESTAMP) - timedelta(seconds=float(secs))
    return diferenca.strftime(FMT_TIMESTAMP)

def sumTimestamp(t, secs):
    soma = datetime.strptime(t, FMT_TIMESTAMP) + timedelta(seconds=float(secs))
    return soma.strftime(FMT_TIMESTAMP)

def subTimestamps(t1, t2) -> timedelta:
    diferenca = datetime.strptime(t1, FMT_TIMESTAMP) - datetime.strptime(t2, FMT_TIMESTAMP)
    return diferenca
# ===================================================== #


def gerar_arquivo(filename, rows):
    with open(filename, 'w', newline='') as csvoutfile:
        writer = csv.writer(csvoutfile, delimiter=' ')
        writer.writerows(rows)
        csvoutfile.close()
        print('[2] Arquivo gerado:', filename)


def salvar_row_com_tipo(timestamp, row, tipo):
    final.append([ timestamp, *row[1:len(row)-1], tipo ])


def definir_type(row):
    timestamp, _, a, b, d = row
    rel = fn_relacao(a, b)

    if rel not in T: # 1
        if d != '0': # 1.1
            timestamp_ultimo_up[rel] = subTimestamp(timestamp, d)
            salvar_row_com_tipo(timestamp_ultimo_up[rel], row, 'up')
            T[rel] = timestamp # 1.2
            ultimo_type[rel] = 'up'
            ultimo_encounter_duration_valido[rel] = d

    elif T[rel] == -1: # 2
        if d != D[rel]: # 2.1
            if d != '0': # 1.1
                timestamp_ultimo_up[rel] = subTimestamp(timestamp, d)
                salvar_row_com_tipo(timestamp_ultimo_up[rel], row, 'up')
                T[rel] = timestamp # 1.2
                ultimo_type[rel] = 'up'
                ultimo_encounter_duration_valido[rel] = d

    else: # 3
        if d == D[rel]: # 3.1
            salvar_row_com_tipo(T[rel], row, 'down')
            T[rel] = -1 # 3.1.2
            ultimo_type[rel] = 'down'

        elif d != '0': # 3.2
            if float(d) >= float(D[rel]): # 3.2.1
                T[rel] = timestamp
                ultimo_encounter_duration_valido[rel] = d
            else: # 3.2.2
                salvar_row_com_tipo(T[rel], row, 'down')
                timestamp_ultimo_up[rel] = subTimestamp(timestamp, d)
                salvar_row_com_tipo(timestamp_ultimo_up[rel], row, 'up')
                ultimo_type[rel] = 'up'
                ultimo_encounter_duration_valido[rel] = d

        else: # 3.3
            salvar_row_com_tipo( subTimestamp(timestamp), row, 'down') # 3.3.1
            T[rel] = -1 # 3.3.2
            ultimo_type[rel] = 'down'

    D[rel] = d # 4


def tratar_linha(row, usenseCorrente):
    row_tratada = list( map(fn_remover_espacos, row) )

    ## Transformar valor da coluna `device name` em `second_node_ID`
    row_tratada[SECOND_DEVICE_NAME] = gerar_ID(row_tratada[SECOND_DEVICE_NAME])

    ## Adicionar a coluna 'action' após a 'time'
    row_tratada.insert(TIMESTAMP+1, 'CONN')

    ## Adicionar a coluna `first_node_ID` antes da coluna `device name`
    row_tratada.insert(2, gerar_ID(usenseCorrente))
    del row_tratada[-3:] ## Remove as 3 últimas colunas

    return row_tratada

### Adiciona na lista que contém as linhas de todos os usenses
def anexar(usenseCorrente, nomeArquivo):
    with open(nomeArquivo, 'r') as datfile:
        reader = csv.reader(datfile, delimiter='\t')
        for row in reader:
            unidos.append( tratar_linha(row, usenseCorrente) )
        datfile.close()



if __name__ == '__main__':
    caminho_arquivo_gerado = 'base_final.csv'

    if len(sys.argv) < 2:
        print('ARGS: <diretório-experimento> [diretório-saída]')
        sys.exit(1)

    if len(sys.argv) >= 2:
        caminho_arquivo_gerado = fn_remover_barra(sys.argv[2]) + '/' + caminho_arquivo_gerado

    for numero_usense in IDENTIFICADORES_USENSES:
        caminho_arquivo_original = fn_remover_barra(sys.argv[1]) + '/USense{x}/Source/SocialStrength.dat'.format(x=numero_usense)

        try:
            anexar(numero_usense, caminho_arquivo_original)
            print('[1] Arquivo tratado:', caminho_arquivo_original)
        except FileNotFoundError: pass

    ## Atualizar os índices dos campos
    SECOND_DEVICE_NAME = 3
    ENCOUNTER_DURATION = 4

    resultados = sorted(unidos, key=lambda r: r[0])
    del unidos
    for row in resultados:
        definir_type(row)

    ## Adicionar os 'down' que não foram captados
    for rel in ultimo_type:
        if ultimo_type[rel] == 'up':
            [a, b] = rel.split('_')
            timestamp = sumTimestamp(timestamp_ultimo_up[rel], ultimo_encounter_duration_valido[rel])
            final.append([ timestamp, 'CONN', a, b, 'down' ])
    del resultados

    ## Ordenar pelo `timestamp`
    final = sorted(final, key=lambda r: r[TIMESTAMP])

    ## Converter os `timestamp` para segundos
    timestamp_inicial = final[0][TIMESTAMP]
    for idx, row in enumerate(final):
        final[idx][TIMESTAMP] = subTimestamps(row[TIMESTAMP], timestamp_inicial).total_seconds() + 1

    gerar_arquivo(caminho_arquivo_gerado, final)
