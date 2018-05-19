#!/bin/bash
# 18-05-2018 (c) Micael Levi L. C.
#
# Deve ser executado no diretório "social-interaction".
# E irá afetar todos os 3 experimentos.
#
# Nos dados originais, em alguns casos
# o separador TAB se misturava com espaços.
# Este script irá criar uma versão normalizada/corrigida
# onde o separador será o ponto-e-vírgula (alguns valores dos campos possuem espaços)
# e os campos desnecessários (os 2 últimos do arquivo original) removidos.
#
# Será gerado um arquivo "SocialsStrengthNormalizado.csv" com
# os campos de "SocialStrength.dat" devidamente separados.
#

: '
social-interaction
  │
  ├── Experiment-1
  │   ├── USense2
  │   │   ├── SocialStrengthNormalizado.csv *
  │   │   └── Source
  │   ├── USense3
  │   │   ├── SocialStrengthNormalizado.csv *
  │   │   └── Source
  │   ├── USense4
  │   │   ├── SocialStrengthNormalizado.csv *
  │   │   └── Source
  │   └── USense5
  │       ├── SocialStrengthNormalizado.csv *
  │       └── Source
  ...
'


SEP=';'

for i in Experiment-[0-9]/USense[0-9]/**/SocialStrength.dat
do
  novoDir="${i%/*}"
  novoDir="${novoDir%/*}"
  arquivoOriginal="${i##*/}"
  arquivoNormalizado="${novoDir}/${arquivoOriginal/%.dat/Normalizado.csv}"

  sed -r 's/^\s*// ; s/\s+\t/\t/ ; s/\t\s/\t/ ; s/  -  /-/' "$i" | ## apagando espaços excedentes
  tr '\t' $SEP | ## alterando o separador padrão TAB
  cut -d $SEP -f-4 1> "$arquivoNormalizado" ## recuperar apenas as 4 primeiras colunas

  echo "Criado: '$arquivoNormalizado'"
done
