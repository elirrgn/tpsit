#!/bin/bash
cd /

doBackup() {
    cd $home
    cartella=car #Inizializzo la variabile per entrare nel while
    esclusi=() #Cartella delle cartelle da escludere vuota
    #Memorizzo quali cartelle sono da escludere nel backup
    while [ "$cartella" != "fine" ]; do #Ciclo fino a quando l'utente inserisce "fine"
        clear
        echo "Scegli tra le seguenti cartelle: "
        echo
        ls
        echo
        echo "Cartelle escluse: "
        for folder in "${esclusi[@]}"; do
            echo "$folder"
        done
        echo
        echo "Inserisci il nome di una cartella da escludere (scrivi 'fine' per terminare): "
        read cartella
        #Controllo se la cartella inserita dall'utente esiste, se si la aggiungo
        if [ "$cartella" != "fine" ]; then
            if [ -d "$cartella" ]; then
                esclusi+=("$cartella/")
            else
                echo "La cartella $cartella non esiste."
                sleep 2
            fi
        fi
    done
    clear
    data=$(date +"%d-%m-%Y:%H-%M")
    #Creo la cartella del backup formato "gg-MM-aaaa:hh-mm"
    backupPath="/backup/$data"
    echo "Creazione cartella di Backup"
    #Se la cartella esiste, cancello il backup precedente dello stesso minuto
    if [ -e $backupPath ]
        then
            sudo rm -r $backupPath
    fi
    sudo mkdir "/backup/$data"
    #Se la password inserite nel sudo è errata tre volte e non è stata creata la cartella chiudo il programma con la stringa di errore
    if [ ! -e $backupPath ]
        then
            echo "Password Errata, backup non eseguibile"
            exit 0
    fi
    sudo touch "/backup/$data/report.txt" #Creo il file report
    sudo chmod 777 "/backup/$data/report.txt" #Do totali diritti di accesso al file
    sleep 1
    echo "BackUp in corso..."
    echo "Report Backup (Cartella Dimensione)" >> "/backup/$data/report.txt"
    #Ciclo per ogni cartella nel path attuale (home)
    for cart in */; do
        # Controlla se la cartella è da escludere
        escluso=false
        for folder in "${esclusi[@]}"; do
            if [ "$folder" == "$cart" ]; then
                escluso=true
                break
            fi
        done
        # Se la cartella non è esclusa, la copia nel backup
        if ! $escluso; then
            sudo cp -r "$cart" "$backupPath"
            dimensione_elemento=$(du -s "$cart" | cut -f1)
            sudo echo "$cart $dimensione_elemento KB" >> "$backupPath/report.txt"
            # Aggiungi la dimensione dell'elemento corrente alla somma totale
            somma_totale=$(( somma_totale + dimensione_elemento ))
        fi
    done
    #Salvo il risultato totale del report e stampo a schermo il contenuto del file
    echo >> "/backup/$data/report.txt"
    echo "Totale $somma_totale KB">> "/backup/$data/report.txt"
    cat "/backup/$data/report.txt"
    echo
    echo
    echo "Backup Completato Correttamente"
}



#Controlla se l'utente è root o ha i privilegi di amministratore
if [[ $(id -u) -eq 1000 ]]; then
    #Controllo se la cartella di backup esiste, se non esiste la creo
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
    echo "Richiesti i diritti amministratore per creare la cartella backup"
    sleep 2
fi
