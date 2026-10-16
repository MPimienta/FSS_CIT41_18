#!/bin/sh
set -eu
case "${1:-}" in P2-1|P2-2|P2-3) ;; *) echo "Uso: sh seleccionar_escenario.sh P2-1|P2-2|P2-3"; exit 2;; esac
scenario_file="testing_2_${1#P2-}.ads"
cd "$(dirname "$0")"
cp "../tests/$1/$scenario_file" testing_1.ads
cp "../tests/$1/fss_config.ads" fss_config.ads
make clean
make
