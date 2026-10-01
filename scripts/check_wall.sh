#!/bin/sh

IMG="$1"

# Verifica argomento e presenza del file
if [ -z "$IMG" ] || [ ! -f "$IMG" ]; then
    echo "Uso: $0 /percorso/immagine"
    exit 1
fi

# 1. Risoluzione schermo X11 con xrandr (o fallback su /sys)
if command -v xrandr >/dev/null 2>&1; then
    DISP_RES=$(xrandr | grep -w 'connected' -A 1 | grep '\*' | awk '{print $1}' | head -n1)
    DISP_W=$(echo "$DISP_RES" | cut -d'x' -f1)
    DISP_H=$(echo "$DISP_RES" | cut -d'x' -f2)
else
    DISP_RES=$(cat /sys/class/drm/card*-*/modes 2>/dev/null | head -n1)
    DISP_W=$(echo "$DISP_RES" | cut -d'x' -f1)
    DISP_H=$(echo "$DISP_RES" | cut -d'x' -f2)
fi

# 2. Estrazione dimensioni compatibile con JPG, PNG, WEBP, GIF usando 'file'
FILE_OUT=$(file -b "$IMG")

case "$FILE_OUT" in
    *JPEG*|*jpg*)
        # Cerca il pattern esatto dei pixel ignorando la "density 72x72"
        DIMENSIONS=$(echo "$FILE_OUT" | grep -oE 'precision [0-9]+, [0-9]+x[0-9]+' | grep -oE '[0-9]+x[0-9]+')
        ;;
    *PNG*)
        DIMENSIONS=$(echo "$FILE_OUT" | grep -oE '[0-9]+[ ]*x[ ]*[0-9]+' | head -n1 | tr -d ' ')
        ;;
    *WebP*|*WEBP*)
        DIMENSIONS=$(echo "$FILE_OUT" | grep -oE 'coord [0-9]+x[0-9]+' | grep -oE '[0-9]+x[0-9]+')
        ;;
    *GIF*)
        DIMENSIONS=$(echo "$FILE_OUT" | grep -oE '[0-9]+[ ]*x[ ]*[0-9]+' | head -n1 | tr -d ' ')
        ;;
    *)
        # Fallback generico: prende l'ultimo pattern NNNNxNNNN nell'output
        DIMENSIONS=$(echo "$FILE_OUT" | grep -oE '[0-9]+x[0-9]+' | tail -n1)
        ;;
esac

IMG_W=$(echo "$DIMENSIONS" | cut -d'x' -f1)
IMG_H=$(echo "$DIMENSIONS" | cut -d'x' -f2)

# Controllo di sicurezza
if [ -z "$DISP_W" ] || [ -z "$DISP_H" ] || [ -z "$IMG_W" ] || [ -z "$IMG_H" ]; then
    echo "Errore: impossibile determinare le dimensioni dello schermo o dell'immagine."
    exit -1
fi

# 3. Output
echo "Display  : ${DISP_W}x${DISP_H}"
echo "Immagine : ${IMG_W}x${IMG_H}"

# 4. Confronto
if [ "$IMG_W" -lt "$DISP_W" ] || [ "$IMG_H" -lt "$DISP_H" ]; then
    echo "Risultato: PIÙ PICCOLA"
    exit 1
else
    echo "Risultato: OK (uguale o più grande)"
    exit 0
fi
