#!/bin/bash
# (c) Micael Levi
#
# Deve ser executado no diretório "social-interaction".
# E irá afetar todos os 3 experimentos.
#
# Como os dados originais dividem as conexões de cada nó (device)
# em diretórios diferentes, esse script reunirá todos os
# "SocialStrength.csv" gerados após a normalização,
# de acordo com cada experimento.
#

arquivosCriados=()
QTD_USENSES=4
i=1

for f in Experiment-*/USense*/SocialStrengthNormalizado.csv
do
  currExperimentPath="${f%%/*}"
  currUSenseNumber="${f#*/}"
  currUSenseNumber="${currUSenseNumber%%/*}"
  currUSenseNumber="${currUSenseNumber:$(( ${#currUSenseNumber}-1 )):1}"
  tmpFile="${f}~"

  # FIXME: algumas instâncias não foram tratadas
  sed -r "s/[^;]+;/\0Usense${currUSenseNumber};/" "$f" 1> "$tmpFile" && \
  echo "Criado: '$tmpFile'"
  arquivosCriados+=( "$tmpFile" )

  [[ $i -eq $QTD_USENSES ]] && {
    i=1
    arquivosMesclados="$currExperimentPath/SocialsStrength.csv"

    cat "${arquivosCriados[@]}" 1> "$arquivosMesclados"
    echo -e "\nArquivos reunidos em: '$arquivosMesclados'"
  }

  ((++i))
done

## Apagar csv "temporários"
find Experiment-*/USense*/ -name '*.csv~' -type f -delete

## Para conferir se todas as linhas possuem 6 ocorrências de ponto-e-vírgula
echo -e "\nQuantidade de linhas em cada arquivo"
wc -l Experiment-*/SocialsStrength.csv | head -3

echo -e "\nQuantidade de linhas em cada arquivo gerado que contém 7 ocorrências de ponto-e-vírgula"
for f in Experiment-*/SocialsStrength.csv; do sed -nr 's/;/;/6p' "$f" | wc -l; done
