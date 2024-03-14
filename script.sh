#!/bin/bash
cd /

doBackup() {
    cd $home
    cartella=car
    esclusi=()
    aggiunti=0
    while [ $cartella != "fine" ]
        do
        clear
        echo "Scegli tra le seguenti cartelle: "
        echo
        ls
        echo
        echo "Cartelle escluse: "
        num=0
        for folder in "${esclusi[@]}";
            do
            echo $folder
        done
        echo "Inserisci il nome di una cartella da escludere(se finito scrivere \"fine\"): "
        read cartella
        if [ -e $cartella ] 
            then
                esclusi[$aggiunti]="$cartella"
                aggiunti=$aggiunti+1
        fi
    done
    clear
    data=$(date +"%Y-%m-%d:%H-%M-%S")
    backupPath="/backup/$data"
    echo "Creazione cartella di Backup"
    sudo mkdir "/backup/$data"
    sleep 1
    echo "BackUp in corso..."
    cartelle=($(ls -d */))
    for cart in "${cartelle[@]}"
        do
        if [[ ! "${esclusi[@]}" =~ "$cart" ]]
            then
                sudo cp -r "$cart" "$backupPath"
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
            echo "Cartella backup già esistente (sei root)"
        else
            #creazione cartella, richiesti permessi da amministratore
            sudo mkdir backup
            cd backup
            echo "Cartella backup creata correttamente"
    fi
    sleep 2
    doBackup
else
    #controllo se la cartella di backup esiste
    if [ -e "backup" ] 
        then
            cd backup
            echo "Cartella backup già esistente"
            sleep 2
            doBackup
        else
            echo "Richiesti i diritti amministratore per creare la cartella backup"
    fi
    sleep 2
fi
