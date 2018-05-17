#!/bin/bash

arquivosCriados=()
QTD_USENSES=4
i=0

for f in Experiment-*/USense*/SourceNormalizados/SocialStrength.csv
do
  ((++i))

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
    i=0
    cat "${arquivosCriados[@]}" 1> "$currExperimentPath/SocialsStrength.csv"
  }
done

find Experiment-*/**/SourceNormalizados -name '*.csv~' -delete
