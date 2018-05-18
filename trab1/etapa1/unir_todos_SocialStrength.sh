#!/bin/bash
# (c) Micael Levi
#
# Deve ser executado no diretório "social-interaction".
# E irá afetar todos os 3 experimentos.
#
# Como os dados originais dividem as conexões de cada nó (device)
# em diretórios diferentes, esse script reunirá todos os
# "SocialStrength.csv" gerados após a normalização,
# de acordo com cada experimento, e ordenados pelo "TimeStamp".
# Além de inserir a coluna de "action" que é sempre "CONN",
# alterar o nome dos id "Usense2", etc, para o formato numérico pedido na questão 1,
# e remover as duas últimas colunas por não serem úteis para o resultado final.
#

arquivosCriados=()
QTD_USENSES=4
i=1
DECREMENTO=2

for f in Experiment-*/USense*/SocialStrengthNormalizado.csv
do
  currExperimentPath="${f%%/*}"
  currUSenseNumber="${f#*/}"
  currUSenseNumber="${currUSenseNumber%%/*}"
  currUSenseNumber="${currUSenseNumber:$(( ${#currUSenseNumber}-1 )):1}"
  currUSenseNumber=$(( currUSenseNumber - $DECREMENTO )) # transformando em ID
  tmpFile="${f}~"

  sed -r "s/[^;]+/\0;CONN;${currUSenseNumber}/" "$f" |
  awk -F ';' -v d=$DECREMENTO 'BEGIN {OFS=";"} { $4=substr($4,7); $4-=d }1' |
  cut -d ';' -f-6 1> "$tmpFile" && echo "Criado arquivo temporário: '$tmpFile'"

  arquivosCriados+=( "$tmpFile" )

  [[ $i -eq $QTD_USENSES ]] && {
    i=1
    arquivosMesclados="$currExperimentPath/SocialsStrength.csv"

    cat "${arquivosCriados[@]}" 1> "$arquivosMesclados"
    sort -o "$arquivosMesclados" -t'/' -k2M -k1n "$arquivosMesclados"
    echo -e "\nArquivos reunidos e ordenados em: '$arquivosMesclados'"
  }

  ((++i))
done

## Apagar csv "temporários"
find Experiment-*/USense*/ -name '*.csv~' -type f -delete

## Para conferir se todas as linhas possuem 6 ocorrências de ponto-e-vírgula
echo -e "\nQuantidade de linhas em cada arquivo"
wc -l Experiment-*/SocialsStrength.csv | head -3

echo -e "\nQuantidade de linhas em cada arquivo gerado que contém 5 ocorrências de ponto-e-vírgula"
for f in Experiment-*/SocialsStrength.csv; do sed -nr 's/;/;/5p' "$f" | wc -l; done
