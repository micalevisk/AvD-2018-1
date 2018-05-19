#!/bin/bash
# 18-05-2018 (c) Micael Levi L. C.
#
# Deve ser executado no diretório "social-interaction".
# E irá afetar todos os 3 experimentos.
#
# Como os dados originais dividem as conexões de cada nó (device)
# em diretórios diferentes, esse script reunirá todos os
# "SocialStrength.csv" gerados após a normalização,
# de acordo com cada experimento, e ordenados pelo "TimeStamp" que será convertido
# para o formato de instante de tempo em segundos, i.e., o primeiro horário registrado
# terá o tempo 60 segundos, o segundo (1 minuto depois), terá 120, e assim por diante.
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
  [[ -r "$f" ]] || exit ${1?'arquivo ausente ou sem permissão para leitura'}

  tmpFile="${f}~"
  currExperimentPath="${f%%/*}"
  currUSenseNumber="${f#*/}"
  currUSenseNumber="${currUSenseNumber%%/*}"
  currUSenseNumber="${currUSenseNumber:$(( ${#currUSenseNumber}-1 )):1}"
  currUSenseNumber=$(( currUSenseNumber - $DECREMENTO )) # transformando em ID

  sed -r "s/[^;]+/\0;CONN;${currUSenseNumber}/" "$f" | ## inserir os 2 campos faltantes, `action` e `first_node_ID`
  awk -F $SEP -v d=$DECREMENTO '$4~/Usense[2-5]/ { $4=substr($4,7); $4-=d }1' OFS=$SEP > "$tmpFile" ## transformar os DeviceName dos segundos nós em ID
  ##                                                                 ^^^ vai dar `-2` quando o `DeviceName` não for válido
  echo "Criado arquivo (temporário): '$tmpFile'"

  arquivosCriados+=( "$tmpFile" )
  rm -f "$f" ## apagar a versão normalizada antiga
  echo -e "Arquivo '$f' removido"

  if [[ $i -eq 4 ]]; then
    i=1
    arquivosMesclados="$currExperimentPath/SocialsStrength.csv"

    cat "${arquivosCriados[@]}" 1> "$arquivosMesclados" &&
    sort -o "$arquivosMesclados" -t'/' -k2M -k1n "$arquivosMesclados"

    ## converter timestamp para tempos em segundos
    gawk -i inplace -F $SEP 'BEGIN {t=-60} { if (!a[$1]){ t+=60; a[$1]=1 }; $1=""; print t $0 }' OFS=$SEP "$arquivosMesclados"

    ## remover linhas onde o campo `DeviceName` não é um dos IDs e o `Encounter Duration` é diferente de 0
    gawk -i inplace -F $SEP '$4~/^[0-4]$/ && $5 != "0"' "$arquivosMesclados"
    ##                            ^^^^^ está no range dos `Usensex` que foram convertidos para IDs

    echo -e "Arquivos reunidos e ordenados em: '$arquivosMesclados'\n"
    ## FORMATO: tempo;action;first_node_ID;second_node_ID;encounter_duration;average_encounter_duration
  fi

  ((++i))
done

## Apagar csv "temporários"
find Experiment-[0-9]/USense[2-5]/ -name '*Normalizado.csv~' -type f -delete
