#!/bin/bash

# Script para generar la versión MSDOS de VSHOOT10.PRG
# Copia VSHOOT10.PRG a VSHOOT10_ms-dos.PRG y lo convierte a CP437

echo "Generando versión MSDOS..."

# Copiar el archivo
cp TINYHELL.PRG VSHOOTM2.PRG

# Convertir a CP437
iconv -f utf-8 -t cp437 -c VSHOOTM2.PRG > temp && mv temp VSHOOTM2.PRG

echo "Versión MSDOS generada: VSHOOTM2.PRG"