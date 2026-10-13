# FSS_CIT41_18

# Estructura y Flujo de Trabajo del Repositorio FSS

## Organización del Proyecto

El directorio raíz del repositorio organiza el código mediante subdirectorios dedicados a cada versión del sistema FSS. Cada uno de estos prototipos se identifica con el formato `prot_x`, sustituyendo la "x" por el número de versión correspondiente.

Dentro de cada directorio `prot_x` se alojan todos los ficheros necesarios para compilar y ejecutar la aplicación. Cualquier desarrollo que implique añadir, modificar o eliminar módulos para cumplir con las especificaciones del proyecto debe realizarse directamente en el subdirectorio de su versión correspondiente.

Para incorporar elementos complementarios que no formen parte del código de las especificaciones, como documentos, diagramas o scripts de validación externos, se debe crear un subdirectorio con un nombre representativo dentro del `prot_x` afectado, por ejemplo, una carpeta llamada `prot_x/validacion/`. Modificar archivos de testing estructurales como `testing_x.ads` sí se considera un cambio de especificación y debe mantenerse en el directorio base del prototipo.

## Flujo de Trabajo con Git

El objetivo principal es mantener la rama `master` como la versión más actualizada y estable del proyecto en todo momento.

Para evitar conflictos de integración, todo nuevo desarrollo debe realizarse en una rama aislada. Esta rama debe crearse a partir de la versión más actualizada del repositorio y recibir un nombre descriptivo que permita a cualquier miembro del equipo identificar rápidamente qué cambios incluye.

Una vez que el desarrollo de esa funcionalidad o corrección haya finalizado, se debe abrir una Pull Request (PR) para fusionar el trabajo. Tras realizar el merge de forma exitosa, la rama de desarrollo debe ser eliminada para mantener el repositorio limpio y ordenado, asumiendo que no se realizarán más iteraciones sobre ella.
