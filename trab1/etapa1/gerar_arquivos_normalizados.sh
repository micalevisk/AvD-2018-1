#!/bin/bash
# (c) Micael Levi
#
# Deve ser executado no diretório "social-interaction".
# E irá afetar todos os 3 experimentos.
#
# Nos dados originais, em alguns casos
# o separador TAB se misturava com espaços.
# Este script irá criar uma versão normalizada
# onde o separador será o ponto-e-vírgula (alguns valores possuem espaços).
# Será criado um diretório de nome "SourceNormalizados"
# e os arquivos `.dat` serão salvos (normalizados) como `.csv`
#

for i in Experiment-*/USense*/**/*.dat
do
  novoDir="${i%/*}Normalizados/"
  arquivoOriginal="${i##*/}"
  arquivoNormalizado="${novoDir}${arquivoOriginal/%dat/csv}"

  mkdir -p "$novoDir"
  sed -r 's/^\s*// ; s/\s+\t/\t/ ; s/\t\s/\t/ ; s/  -  /-/' "$i" | tr '\t' ';' > "$arquivoNormalizado"
  echo "Criado: '$arquivoNormalizado'"
done

## ANTES
: '
.
├── Experiment-1
│   ├── USense2
│   │   └── Source
│   ├── USense3
│   │   └── Source
│   ├── USense4
│   │   └── Source
│   └── USense5
│       └── Source
├── Experiment-2
│   ├── USense2
│   │   └── Source
│   ├── USense3
│   │   └── Source
│   ├── USense4
│   │   └── Source
│   └── USense5
│       └── Source
└── Experiment-3
    ├── USense2
    │   └── Source
    ├── USense3
    │   └── Source
    ├── USense4
    │   └── Source
    └── USense5
        └── Source

27 directories
'

## DEPOIS
: '
.
├── Experiment-1
│   ├── USense2
│   │   ├── Source
│   │   └── SourceNormalizados
│   ├── USense3
│   │   ├── Source
│   │   └── SourceNormalizados
│   ├── USense4
│   │   ├── Source
│   │   └── SourceNormalizados
│   └── USense5
│       ├── Source
│       └── SourceNormalizados
├── Experiment-2
│   ├── USense2
│   │   ├── Source
│   │   └── SourceNormalizados
│   ├── USense3
│   │   ├── Source
│   │   └── SourceNormalizados
│   ├── USense4
│   │   ├── Source
│   │   └── SourceNormalizados
│   └── USense5
│       ├── Source
│       └── SourceNormalizados
└── Experiment-3
    ├── USense2
    │   ├── Source
    │   └── SourceNormalizados
    ├── USense3
    │   ├── Source
    │   └── SourceNormalizados
    ├── USense4
    │   └── Source
    └── USense5
        ├── Source
        └── SourceNormalizados

38 directories
'
