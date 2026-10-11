#!/bin/sh
# Build a fresh copy in /tmp; never edit the extracted project sources.
set -eu
case_name=${1:-P2-1}
case "$case_name" in
    P2-1|P2-2) ;;
    *) echo "Uso: sh EJECUTAR.sh [P2-1|P2-2]"; exit 2 ;;
esac
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
for tool in make sparc-ork-gnatmake tsim-erc32 script sha256sum; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "Falta $tool. Ejecutar en la VM de STR con el entorno ORK/TSIM."
        exit 2
    fi
done
for file in src/fss.adb src/Makefile "tests/$case_name/testing_1.ads" "tests/$case_name/fss_config.ads"; do
    if [ ! -f "$project_dir/$file" ]; then echo "Paquete incompleto: $file"; exit 2; fi
done
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/fss-$case_name.XXXXXX")
downloads_dir="$HOME/Descargas"
if [ ! -d "$downloads_dir" ]; then downloads_dir="$HOME/Downloads"; fi
if [ ! -d "$downloads_dir" ]; then downloads_dir="$HOME"; fi
results_root="$downloads_dir/FSS-resultados"
if [ ! -d "$results_root" ]; then mkdir "$results_root"; fi
result_dir=$(mktemp -d "$results_root/$case_name.XXXXXX")
cp "$project_dir"/src/* "$work_dir/"
chmod u+w "$work_dir/fss_config.ads" "$work_dir/testing_1.ads"
cp "$project_dir/tests/$case_name/testing_1.ads" "$work_dir/testing_1.ads"
cp "$project_dir/tests/$case_name/fss_config.ads" "$work_dir/fss_config.ads"
cd "$work_dir"
sha256sum *.adb *.ads gnat.adc Makefile > "$result_dir/sources.sha256"
printf 'Caso: %s\nFuentes: %s\nTrabajo temporal: %s\nResultados: %s\n' "$case_name" "$project_dir" "$work_dir" "$result_dir"
if make > "$result_dir/build.log" 2>&1; then
    cat "$result_dir/build.log"
else
    cat "$result_dir/build.log"
    echo "Fallo de compilacion. Enviar $result_dir/build.log"
    exit 3
fi
if command -v sparc-ork-size >/dev/null 2>&1; then
    sparc-ork-size main >> "$result_dir/build.log"
fi
cp fss_config.ads testing_1.ads "$result_dir/"
echo "En tsim> escribir: go"
echo "Esperar a que la simulacion se detenga; despues escribir: quit"
echo "TRACE_SUMMARY aparece cuando se ha transmitido toda la ventana de prueba."
echo "El tiempo de cada evento es su instante de ocurrencia, no el de impresion."
script -q -c "tsim-erc32 main" "$result_dir/tsim.log"
if command -v python3 >/dev/null 2>&1; then
    if python3 "$project_dir/tests/verificar_logs.py" --file "$result_dir/tsim.log" --case "$case_name" --engine tsim > "$result_dir/verification.txt" 2>&1; then
        cat "$result_dir/verification.txt"
        echo "Registro completo: comprobaciones automaticas superadas."
    else
        cat "$result_dir/verification.txt"
        echo "Revision necesaria: registro incompleto o comprobaciones fallidas."
    fi
fi
echo "Guardar estos resultados fuera de la VM antes de cerrar la sesion:"
echo "$result_dir"
echo "Enviar build.log y tsim.log de esta carpeta. Las fuentes originales siguen intactas."
