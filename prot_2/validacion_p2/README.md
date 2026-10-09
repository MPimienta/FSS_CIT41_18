# Validacion de P2-1 y P2-2

Contribucion al grupo CIT41-LAB-G18. Ambos escenarios comparten las fuentes
de `src/`; cada escenario aporta `testing_1.ads` y `fss_config.ads` en `tests/`.
Este directorio puede compilarse y ejecutarse de forma independiente. El codigo
que ya existia en los demas archivos de `prot_2/` se conserva para la integracion
del grupo. Ejecutar el Makefile del directorio padre NO ejecuta esta version.

Las fuentes proceden de la implementacion FSS ya validada en la VM de STR.
Se conserva el codigo comun, incluidas las extensiones posteriores, para
mantener la correspondencia con las evidencias. En ambos escenarios
`Prototype = 2`: colisiones, display periodico y cambio de modo estan
desactivados. La configuracion inicial de `src/` es P2-1.

## Ejecutar en la VM de STR

Desde la raiz del repositorio:

```sh
cd prot_2/validacion_p2
sh EJECUTAR.sh P2-1
sh EJECUTAR.sh P2-2
```

Ejecutar un escenario cada vez. En el indicador `tsim>` escribir `go`;
al terminar la simulacion, escribir `quit` para volver al terminal.
Requiere `make`, `sparc-ork-gnatmake`, `tsim-erc32`, `script` y `sha256sum`.
Con Python 3 se comprueba tambien el registro automaticamente.

El lanzador copia las fuentes a un directorio temporal, aplica la configuracion
del escenario y compila alli. Guarda las nuevas evidencias en
`~/Descargas/FSS-resultados/` (o `~/Downloads/FSS-resultados/`). Hay que guardar
esos resultados fuera de la VM antes de cerrar la sesion.

## Evidencias recibidas de la VM (29-09-2026)

| Escenario | Objetivo | Comprobaciones | Ventana detallada |
| --- | --- | --- | --- |
| P2-1 | Limites de velocidad de 300 y 1000 km/h y valor intermedio de 600 km/h | 18/18 | 20 s |
| P2-2 | Avisos de altitud, proteccion de los limites de 2000 y 10000 m y recuperacion | 21/21 | 70 s |

En cada escenario se recibieron `build.log`, `tsim.log` y `sources.sha256`;
los 23 hashes coinciden con las fuentes y la configuracion de su escenario.
Las evidencias originales estan en `tests/evidencias/<escenario>/originales/`.
Los JSON adyacentes incluyen revisiones independientes de las muestras.

Para repetir las comprobaciones sobre los registros recibidos:

```sh
python3 tests/verificar_logs.py --file tests/evidencias/P2-1/originales/tsim.log --case P2-1 --engine tsim
python3 tests/verificar_logs.py --file tests/evidencias/P2-2/originales/tsim.log --case P2-2 --engine tsim
```

Las medidas son observaciones de esas ejecuciones, no una demostracion de WCET.
En P2-2 se observo una altitud maxima de 10040 m: al leer el limite, el sistema
bloquea seguir ascendiendo y permite descender; no se afirma que nunca se
supere 10000 m. La compensacion de velocidad en ascensos y giros corresponde
principalmente a P2-3, que no forma parte de esta contribucion de pruebas.

## Archivos principales

- `src/fss.adb`: tareas y objeto protegido de control compartido.
- `src/fss_rules.adb`: reglas de velocidad, actitud y altitud.
- `src/devicesfss_v1.adb`: dispositivos simulados del entorno de practicas.
- `tests/P2-1/` y `tests/P2-2/`: entradas y configuraciones de cada escenario.
- `tests/verificar_logs.py`: comprobador de registros, compartido con la entrega validada.

Se mantienen los nombres del grupo en las fuentes. Esta contribucion corresponde
al proyecto FSS; no es el fichero `add.adb` de los ejercicios introductorios.
