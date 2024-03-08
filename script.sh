#!/bin/bash
cd /

doBackup() {
    cd $home
    cartella=car
    escluse=()
    aggiunti=0
    while [ "$cartella" != "fine" ]
        do
        echo "Scegli tra le seguenti cartelle: "
        echo
        ls
        echo
        echo "Cartelle escluse: "
        num=0
        for folder in "${escluse[@]}";
            do
            echo $folder
        done
        echo "Inserisci il nome di una cartella da escludere(se finito scrivere \"fine\"): "
        read cartella
        if [ -e $cartella ] 
            then
                escluse[$aggiunti]="$cartella"
                aggiunti=$aggiunti+1
        fi
    done
    echo Finito
}



# Controlla se l'utente è root o ha i privilegi di amministratore
if [[ $(id -u) -eq 1000 ]]; then
    #controllo se la cartella di backup esiste, se non esiste la creo
    if [ -e "backup" ] 
        then
            cd backup
            echo "Cartella backup già esistente"
        else
            #creazione cartella, richiesti permessi da amministratore
            sudo mkdir backup
            cd backup
            echo "Cartella backup creata correttamente"
    fi
    doBackup
else
    #controllo se la cartella di backup esiste
    if [ -e "backup" ] 
        then
            cd backup
            echo "Cartella backup già esistente"
        else
            echo "Richiesti i diritti amministratore per creare la cartella backup"
    fi
fi
