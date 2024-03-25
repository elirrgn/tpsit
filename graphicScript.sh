#!/bin/bash

function getExcluded() {
    cd $home
    whiptail --title "Backup Bash" --msgbox "Cartelle disponibili: \n\n$(ls)"  20 80
    cartella=$(whiptail --title "Backup Bash" --inputbox "Inserisci il nome di una cartella da escludere (scrivi 'fine' per terminare): " 3>&1 1>&2 2>&3 8 60) 
    cartella+="/"
    if [ "$cartella" != "fine/" ]; then
        if [ -d "$cartella" ]; then
            esclusi+=("$cartella")
        else
            whiptail --title "Backup Bash" --msgbox "La cartella $cartella non esiste" 8 60
        fi
    fi
    #Memorizzo quali cartelle sono da escludere nel backup
    while [ "$cartella" != "fine/" ]; do #Ciclo fino a quando l'utente inserisce "fine"
        whiptail --title "Backup Bash" --msgbox "Cartelle disponibili:\n\n$(ls)"  20 80
        lista=""
        for folder in "${esclusi[@]}"; do
            lista+="$folder\n"
        done
        whiptail --title "Backup Bash" --msgbox "Cartelle già escluse:\n$lista"  20 80
        cartella=$(whiptail --title "Backup Bash" --inputbox "Inserisci il nome di una cartella da escludere (scrivi 'fine' per terminare): " 3>&1 1>&2 2>&3 8 60) 
        cartella+="/"
        giaEsclusa=false
        for elemento in "${esclusi[@]}"; do
            if [ "$cartella" = "$elemento" ]; then
                giaEsclusa=true
                break
            fi
        done
        if [ "$cartella" != "fine/" ]; then
            if $giaEsclusa; then
                whiptail --title "Backup Bash" --msgbox "La cartella $cartella è già esclusa" 8 60
            elif [ -d "$cartella" ]; then
                esclusi+=("$cartella")
            else
                whiptail --title "Backup Bash" --msgbox "La cartella $cartella non esiste" 8 60
            fi
        fi
    done
}

function folderCreation() {
    clear
    data=$(date +"%d-%m-%Y:%H-%M")
    #Creo la cartella del backup formato "gg-MM-aaaa:hh-mm"
    backupPath="/backup/$data"
    whiptail --title "Backup Bash" --msgbox "Creazione cartella del backup" 8 60
    #Se la cartella esiste, cancello il backup precedente dello stesso minuto
    if [ -e $backupPath ]
        then
            sudo rm -r $backupPath
    fi
    sudo mkdir "/backup/$data"
    #Se la password inserite nel sudo è errata tre volte e non è stata creata la cartella chiudo il programma con la stringa di errore
    if [ ! -e $backupPath ]
        then
            whiptail --title "Backup Bash" --msgbox "Password Errata, backup non eseguibile" 8 60
            exit 0
    fi
    sudo touch "/backup/$data/report.txt" #Creo il file report
    sudo chmod 777 "/backup/$data/report.txt" #Do totali diritti di accesso al file
} 

function backup() {
    whiptail --title "Backup Bash" --msgbox "BackUp in corso..." 8 60
    echo "Report Backup (Cartella Dimensione)" >> "/backup/$data/report.txt"
    SECONDS=0
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
}

function reportBackup() {
    #Salvo il risultato totale del report e stampo a schermo il contenuto del file
    echo >> "/backup/$data/report.txt"
    echo "Il backup è stato eseguito in $SECONDS secondi" >> "/backup/$data/report.txt"
    echo >> "/backup/$data/report.txt"
    echo "Totale $somma_totale KB">> "/backup/$data/report.txt"
    whiptail --title "Backup Bash" --msgbox "$(cat "/backup/$data/report.txt")" 20 80
}


function nonRoot() {
    whiptail --title "Backup Bash" --msgbox "Sono richiesti i diritti amministratore per fare un backup, è permesso visualizzare i backup precedenti" 8 60
    open .
}

#main part
cd /
whiptail --title "Backup Bash" --msgbox "Controllando i diritti amministratore..." 8 60
if [[ $(id -u) -eq 1000 ]]; then
    #Controllo se la cartella di backup esiste, se non esiste la creo
    if [ -e "backup" ] 
        then
            cd backup
            whiptail --title "Backup Bash" --msgbox "Cartella backup già esistente" 8 60

        else
            #creazione cartella, richiesti permessi da amministratore
            sudo mkdir backup
            cd backup
            whiptail --title "Backup Bash" --msgbox "Cartella backup creata correttamente" 8 60
    fi
    esclusi=() #Lista delle cartelle da escludere vuota
    getExcluded $esclusi
    folderCreation
    backup $esclusi
    reportBackup
    whiptail --title "Backup Bash" --msgbox "Backup Completato Correttamente" 8 60
else
    if [ -e "backup" ]
        then
            cd backup
            nonRoot
        else
            whiptail --title "Errore" --msgbox "La cartella di Backup non esiste, sono richiesti i diritti amministratore per creare la cartella backup" 8 60       
    fi
    
fi