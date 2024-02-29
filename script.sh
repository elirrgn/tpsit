#!/bin/bash
cd /

#controllo se la cartella di backup esiste se non esiste la creo
if [ -e "backup" ]
    then
        cd backup
    else
        #creazione cartella, richiesti permessi da ammistratore
        sudo mkdir backup
fi

