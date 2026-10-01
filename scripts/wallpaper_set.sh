#!/bin/bash

# 1. Configura la cartella da scansionare ( . indica la cartella corrente )
TARGET_DIR="/home/gioele/wallpapers/"

# 2. Controlla se la cartella esiste
if [ ! -d "$TARGET_DIR" ]; then
    echo "Errore: La cartella $TARGET_DIR non esiste."
    exit 1
fi

# 3. Trova i file e inseriscili in un array
# Mantiene solo i file (esclude le cartelle) per sicurezza
mapfile -t files < <(find "$TARGET_DIR" -maxdepth 1 -type f -printf "%f\n" 2>/dev/null)

# Controlla se ci sono file nella cartella
if [ ${#files[@]} -eq 0 ]; then
    echo "Nessun file trovato nella cartella $TARGET_DIR."
    exit 0
fi

# 4. Mostra la lista dei file con un indice numerico (1-based)
echo "Seleziona un file dall'elenco:"
for i in "${!files[@]}"; do
    echo "[$((i + 1))] ${files[$i]}"
done

# 5. Leggi l'input dell'utente
echo -n "Inserisci il numero corrispondente alla tua scelta: "
read -r scelta

# 6. Valida l'input (controlla che sia un numero e che sia nel range corretto)
if ! [[ "$scelta" =~ ^[0-9]+$ ]] || [ "$scelta" -lt 1 ] || [ "$scelta" -gt "${#files[@]}" ]; then
    echo "Scelta non valida."
    exit 1
fi

# 7. Recupera il file selezionato (riportando l'indice a 0-based)
index=$((scelta - 1))
file_selezionato="${files[$index]}"

echo -e "\nHai selezionato: $file_selezionato"

rm -rf $TARGET_DIR/current/*
cp $TARGET_DIR/$file_selezionato $TARGET_DIR/current/

wal -i $TARGET_DIR/$file_selezionato

cd /home/gioele/dwm
sudo make clean install

/home/gioele/scripts/./check_wall.sh $TARGET_DIR/$file_selezionato
RETURN=$?

if [ $RETURN -eq 1 ]; then
    echo "L'immagine è più piccola!"
    feh --bg-center "$TARGET_DIR/$file_selezionato"
else
    echo "L'immagine è ok!"
    feh --bg-fill "$TARGET_DIR/$file_selezionato"
fi
