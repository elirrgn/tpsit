#!/bin/bash
cd /

# Controlla se l'utente è root o ha i privilegi di amministratore

if [[ $(id -u) -eq 0 ]]; then
    if [ -e "backup" ]
        then
            cd backup
        else
            #creazione cartella, richiesti permessi da ammistratore
            sudo mkdir backup
    fi

else
    if [ -e "backup" ]
        then
            cd backup
        else
            echo "Richiesti i diritti amministratore per creare la cartella backup"
    fi
fi

#controllo se la cartella di backup esiste se non esiste la creo

