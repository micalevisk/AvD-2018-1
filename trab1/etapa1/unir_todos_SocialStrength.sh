#!/bin/bash
# 22-05-2018 (c) Micael Levi L. C.
#
# Deve ser executado no diretório "social-interaction".
# E irá afetar todos os 3 experimentos.
#
# Como os dados originais dividem as conexões de cada nó (device)
# em diretórios diferentes, esse script reunirá todos os
# "SocialStrength.csv" gerados após a normalização,
# de acordo com cada experimento, e ordenados pelo "TimeStamp".
# Além de inserir a coluna de "action" que é sempre "CONN",
# alterar o nome dos id "Usense2", etc, para o formato numérico de ID de nó (i.e, Usense2 virará 0).
#
# Será gerado um arquivo "SocialsStrength.csv" no diretório raiz de cada experimento.
#

: '
social-interaction
  │
  ├── Experiment-1
  │   ├── SocialsStrength.csv *
  │   ├── USense2
  │   │   └── Source
  │   ├── USense3
  │   │   └── Source
  │   ├── USense4
  │   │   └── Source
  │   └── USense5
  │       └── Source
  ...
'


SEP=';'
DECREMENTO=2 ## para normalizar os nomes `UsenseX` em IDs de acordo com o `X` (valor de 2 a 5)
i=1 ## contador de arquivos normalizados para cada `Experiment`
arquivosCriados=() ## array de caminhos para os arquivos gerados

for f in Experiment-[0-9]/USense[2-5]/SocialStrengthNormalizado.csv
do
  [[ -r "$f" ]] || exit ${1?'arquivo .csv ausente ou sem permissão para leitura'}

  tmpFile="${f}~"
  currExperimentPath="${f%%/*}"
  currUSenseNumber="${f#*/}"
  currUSenseNumber="${currUSenseNumber%%/*}"
  currUSenseNumber="${currUSenseNumber:$(( ${#currUSenseNumber}-1 )):1}"
  currUSenseNumber=$(( currUSenseNumber - DECREMENTO )) # transformando em ID

  echo -e "\n-------- ${f%/*} --------"

  sed -r "s/[^;]+/\0;CONN;${currUSenseNumber}/" "$f" | ## inserir os 2 campos faltantes, `action` e `first_node_ID`
  awk -F $SEP -v d=$DECREMENTO 'BEGIN{ l=4 } {
    if ($4 ~ /^Usense[2-5]/) { ## se o campo tiver o valor iniciando com "Usense" seguido por um número
      $4 = substr($4, 7) - d   ## então ele receberá apenas o valor numérico subtraído de "d"
    } else {
      if (!n[$4]) { n[$4] = l++ }
      $4 = n[$4]
    }
  }1' OFS=$SEP > "$tmpFile" ## transformar os DeviceName dos segundos nós em ID

  echo "Criado arquivo (temporário): '$tmpFile'"
  arquivosCriados+=( "$tmpFile" )

  rm -f "$f" ## apagar a versão normalizada antiga
  echo -e "Arquivo '$f' removido"

  if [[ $i -eq 4 ]]; then
    i=1
    arquivosMesclados="$currExperimentPath/SocialsStrength.csv"

    echo "Mesclando os arquivos e ordenando pelo 'Timestamp'"
    cat "${arquivosCriados[@]}" 1> "$arquivosMesclados" &&
    sort -o "$arquivosMesclados" -t'/' -k2M -k1n "$arquivosMesclados"

    sed -i '1itimestamp;action;first_node_ID;second_node_ID;encounter_duration;average_encounter_duration' "$arquivosMesclados"
    echo -e "Arquivos reunidos e ordenados em: '$arquivosMesclados'\n"
  fi

  ((++i))
done

## Apagar csv "temporários" gerados para cada Experiment
find Experiment-[0-9]/USense[2-5]/ -name '*Normalizado.csv~' -type f -delete
