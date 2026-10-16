# Prototipo 2: escenarios P2-1, P2-2 y P2-3

Grupo CIT41-LAB-G18. Esta contribucion se ejecuta desde `prot_2/validacion_p2`.
Las fuentes compartidas estan en `src/`, con `Prototype = 2` en los tres casos.
Ejecutar el Makefile del directorio padre no ejecuta esta version.

## Archivos de la entrega

| Escenario | Fichero | Contenido |
| --- | --- | --- |
| P2-1 | `tests/P2-1/testing_2_1.ads` | Limites de velocidad y valor intermedio |
| P2-2 | `tests/P2-2/testing_2_2.ads` | Limites de altitud, recuperacion y roll combinado |
| P2-3 | `tests/P2-3/testing_2_3.ads` | Joystick, banda muerta, saturacion y compensacion |

`Escenarios_Prototipo_2.pdf` describe las situaciones de cada fichero.
Los ficheros conservan `package Testing_1`: el lanzador copia el seleccionado
como `testing_1.ads` en una carpeta temporal antes de compilar. No se compilan
los tres escenarios juntos ni es necesario cambiar el nombre del paquete Ada.

## Ejecutar en la VM de STR

```sh
cd prot_2/validacion_p2
sh EJECUTAR.sh P2-1
sh EJECUTAR.sh P2-2
sh EJECUTAR.sh P2-3
```

Ejecutar un escenario cada vez. En `tsim>` escribir `go`; esperar a
`TRACE_SUMMARY` y a la parada de simulacion, y escribir `quit`.
Las evidencias se guardan en `~/Descargas/FSS-resultados/` (o Downloads).
Guardarlas fuera de la VM antes de cerrar la sesion.

Para modificar entradas, editar el `.ads` del escenario y actualizar su
`inputs.json` para mantener la descripcion sincronizada. El JSON no se carga
ni se convierte automaticamente al ejecutar. Cada muestra representa 100 ms.

## Estado de validacion

| Escenario | Evidencia en VM/TSIM | Validacion local del 13-10-2026 |
| --- | --- | --- |
| P2-1 | 18/18; entradas y 23 hashes originales conservados | 18/18, GNAT nativo |
| P2-2 roll-v2 | 32/32 en TSIM (13-10-2026); dos observaciones temporales | 32/32, GNAT nativo |
| P2-3 | 20/20; entradas y 23 hashes originales conservados | 20/20, GNAT nativo |

La validacion local usa un adaptador para UART, interrupciones y workload.
Comprueba funcionalidad; sus tiempos no certifican plazos en ERC32.
`tests/evidencias/P2-2/originales/` conserva la prueba anterior, sin roll.
`tests/evidencias/P2-2/roll-v2-host/` contiene la nueva prueba local.
`tests/evidencias/P2-2/roll-v2-tsim/` contiene la nueva ejecucion de la VM,
sus registros originales, 23 hashes de fuentes coincidentes y `revision.json`.
Se contrastan 350 muestras de actitud y 234 de velocidad durante 70 s.
Las 32 comprobaciones automaticas pasan. La revision adicional detecta dos
inversiones de sellos de tiempo (1.137804 y 2.391204 ms), documentadas en
`tests/evidencias/P2-2/roll-v2-tsim/LEEME.txt`: funcionalidad validada con
observaciones; precision temporal fina pendiente de aclarar. No es una
demostracion general de WCET. El estado PENDING de los metadatos originales
del paquete y de la prueba host describe el momento anterior a esta ejecucion.
No se presenta el antiguo 21/21 como evidencia del escenario ampliado.

El lanzador exige las comprobaciones nuevas para P2-2. Para comprobar un log
de la nueva ejecucion manualmente:

```sh
python3 tests/verificar_logs.py --file RUTA/tsim.log --case P2-2 --engine tsim --p2-2-roll
```

La opcion `--p2-2-roll` rechaza el log historico sin giros. Para consultar las
pruebas originales se omite esa opcion. Los logs originales de P2-1 y P2-3 se
comprueban con `--case P2-1` o `--case P2-3`, respectivamente.

## P2-2 ampliado

Se conservan 70 s: descenso fuerte hasta 24 s, ascenso hasta 58 s y descenso
de recuperacion hasta 70 s. Se anaden giros positivos y negativos, entradas
Y de +/-90 limitadas a +/-45, banda muerta en +/-3 y vuelta a roll cero.
Se comprueba que la proteccion de altitud bloquea el pitch hacia fuera del
limite sin anular el roll, y que la compensacion de velocidad responde a la
actitud aplicada. Se observan 600, 700, 750 y 800 km/h con potencia 500.

La altitud se muestrea: se protege al detectar el limite. No se afirma que
nunca pueda superar 10000 m entre muestras. Se mantiene la comprobacion de
alarmas de altitud por debajo de 2500 m o por encima de 9500 m.
