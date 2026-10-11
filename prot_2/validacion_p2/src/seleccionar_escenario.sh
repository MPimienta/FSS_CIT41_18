#!/bin/sh
set -eu
case "${1:-}" in P2-1|P2-2) ;; *) echo "Uso: sh seleccionar_escenario.sh P2-1|P2-2"; exit 2;; esac
cd "$(dirname "$0")"
cp "../tests/$1/testing_1.ads" testing_1.ads
cp "../tests/$1/fss_config.ads" fss_config.ads
make clean
make
