#!/bin/bash
# (c) Micael Levi
#
# Deve ser executado no diretório "social-interaction".
# E irá afetar todos os 3 experimentos.
#
# Nos dados originais, em alguns casos
# o separador TAB se misturava com espaços.
# Este script irá criar uma versão normalizada
# onde o separador será o ponto-e-vírgula (alguns valores possuem espaços),
# os registros com duração 0 e onde o DeviceName não é um dos usenses serão removidos.
# Será gerado um arquivo "SocialsStrengthNormalizado.csv" com
# os campos de `SocialStrength.dat` devidamente separados.
#

for i in Experiment-*/USense*/**/SocialStrength.dat
do
  novoDir="${i%/*}"
  novoDir="${novoDir%/*}"
  arquivoOriginal="${i##*/}"
  arquivoNormalizado="${novoDir}/${arquivoOriginal/%.dat/Normalizado.csv}"

  sed -r 's/^\s*// ; s/\s+\t/\t/ ; s/\t\s/\t/ ; s/  -  /-/' "$i" | tr '\t' ';' > "$arquivoNormalizado"
  sed -ri '/^[^;]+;[^;]+;0;/d ; /^[^;]+;Usense[2-5]/!d' "$arquivoNormalizado"
  echo "Criado: '$arquivoNormalizado'"
done
