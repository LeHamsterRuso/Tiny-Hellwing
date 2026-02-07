# Tiny Hellwing

## Propósito
Este proyecto no tiene ánimo de lucro y fue creado como tutorial para enseñar a programar en MS-DOS. Más información en: [Tutorial en El General Failure](https://www.elgeneralfailure.com/2026/02/aprendiendo-programar-para-ms-dos-con.html). Gameplay completo: [https://www.youtube.com/watch?v=ctFYWD8VweI](https://www.youtube.com/watch?v=ctFYWD8VweI)

## Inspiración
El juego está inspirado en la serie *Youjo Senki / Saga of Tanya the Evil* de Carlo Zen, adaptando elementos de su narrativa y personajes a un género bullet hell clásico.

## Descripción
Tiny Hellwing es un bullet hell desarrollado para MS-DOS, inspirado en el universo de *Youjo Senki / Saga of Tanya the Evil* de Carlo Zen. El juego captura la esencia de combates aéreos intensos y desafiantes en un entorno retro.

## Créditos
Este juego ha sido programado por Sebastián J. Moncho Maquet, aka Le hamster_ruso ([@hamster_ruso en X](https://x.com/hamster_ruso)), en febrero de 2026.

## Requisitos
Para compilar y ejecutar este juego, necesitas:
- Sistema operativo MS-DOS o compatible (Windows 95, Windos 98, DOSBox, etc).
- Div 2 Games Studio instalado, incluyendo sus ejemplos.
- 28 MB de RAM (16 framework + 12 del juego)
- Procesador Pentium 100 MHz o superior.
- Tarjeta gráfica VGA/SVGA.
- Tarjeta de sonido SB16 o compatible.
- Disco duro con 200 MB aprox de espacio libre disponible.

Para jugar, necesitas:
- Sistema operativo MS-DOS o compatible (Windows 95, Windos 98, DOSBox, etc).
- 4 MB de RAM (sin audio); 12 MB de RAM con audio.
- Procesador Pentium 100 MHz o superior.
- Tarjeta gráfica VGA/SVGA.
- Tarjeta de sonido SB16 o compatible.
- Disco duro con 55 MB de espacio libre disponible.

## Compilación
1. Instala Div 2 Games Studio con todos sus ejemplos.
2. Abre el proyecto en Div 2 Games Studio.
3. Compila el archivo principal `PRG/TINYHELL.PRG`.

## Tildes y formatos
Al estar el código en español, dependiendo de si estás en un entorno MS-DOS real o en un DOSBox, puedes tener problemas con las tildes. Esto puede causar problemas de visualización en los diálogos (carácteres raros) o de overflow (strings más largos de la talla permitida). En la raíz del proyecto dejo una herramienta build_msdos.sh para Linux/MacOS que permite convertir el fichero de UTF8 al formato esperado por DOS. Esta herramienta no machaca el fichero original, si no que crea una copia VSHOOTM2.PRG convertida.

## Configuración para DOSBox
Para que el audio se escuche correctamente en DOSBox en Windows, es necesario configurar `core=dynamic` y `cycles=95000`. En principio, esta configuración no es necesaria en Linux/Mac.

## Notas sobre archivos
- El juego utiliza el sonido `PISTOLA0.WAV` del ejemplo TOKENKAI de Div 2 Games Studio, que no está incluido en este repositorio.
- También hace uso de la paleta `DIV2.PAL`, que viene preinstalada en el framework de Div Games Studio 2 y no se incluye tampoco aquí.

## Assets
Para los assets del juego, se han utilizado:
- Renders de un modelo 3D de Tanya creado por el autor: [Modelo 3D en Sketchfab](https://sketchfab.com/3d-models/tanya-degurechaff-from-saga-of-tanya-the-evil-fb725e63784d4839928aa8ea6fe28e56).
- El resto de assets han sido generados utilizando inteligencias artificiales generativas:
  - SUNO para las canciones de fondo, posteriormente convertidas a WAV (estéreo a 11025Hz) haciendo uso de afconvert.
  - Meshy AI para los enemigos, renderizados posteriormente utilizando Blender.
  - Los escenarios han sido generados por ChatGPT.
  - Las escenas de CG han sido creadas con Meshy (Nano Banana), Grok y ChatGPT.
  - Para los efectos de dithering y compresión a 256 colores de los assets se ha empleado GIMP.
