#!/bin/bash

#   Funzione per chiedere all'utente quali cartelle sono da escludere nel backup
function getExcluded() {
    cd $home
    esclusi=() #Lista delle cartelle da escludere vuota
    #Mostro le cartelle possibili di cui fare il backup
    whiptail --title "Backup Bash" --msgbox "Cartelle disponibili: \n\n$(ls -d */)"  20 80
    #Chiedo la prima cartella da escludere
    cartella=$(whiptail --title "Backup Bash" --inputbox "Inserisci il nome di una cartella da escludere (inserire il nome senza \"/\", inserire 'fine' per terminare): " 3>&1 1>&2 2>&3 8 60) 
    cartella+="/"

    #Controllo che la cartella esista e che l'utente non abbia inserito "fine"
    if [ "$cartella" != "fine/" ]; then
        if [ -d "$cartella" ]; then
            esclusi+=("$cartella")
        else
            whiptail --title "Backup Bash" --msgbox "La cartella $cartella non esiste" 8 60
        fi
    fi
    
    #Memorizzo quali cartelle sono da escludere nel backup
    while [ "$cartella" != "fine/" ]; do #Ciclo fino a quando l'utente inserisce "fine"
        whiptail --title "Backup Bash" --msgbox "Cartelle disponibili:\n\n$(ls -d */)"  20 80
        lista=""
        for folder in "${esclusi[@]}"; do
            lista+="$folder\n"
        done
        whiptail --title "Backup Bash" --msgbox "Cartelle già escluse:\n$lista"  20 80
        cartella=$(whiptail --title "Backup Bash" --inputbox "Inserisci il nome di una cartella da escludere (inserire il nome senza \"/\", inserire 'fine' per terminare): " 3>&1 1>&2 2>&3 8 60) 
        cartella+="/"

        #Controllo se la cartella inserita è già presente nell'array esclusi
        giaEsclusa=false
        for elemento in "${esclusi[@]}"; do
            if [ "$cartella" = "$elemento" ]; then
                giaEsclusa=true
                break
            fi
        done

        #Controllo che l'utente non abbia inserito "fine"
        if [ "$cartella" != "fine/" ]; then
            #Controllo che la cartella non sia già stata inserita nell'array esclusi
            if $giaEsclusa; then
                whiptail --title "Backup Bash" --msgbox "La cartella $cartella è già esclusa" 8 60
            #Controllo se la cartella esiste
            elif [ -d "$cartella" ]; then
                esclusi+=("$cartella")
            #Messaggio di errore se la cartella di errore non esiste
            else
                whiptail --title "Backup Bash" --msgbox "La cartella $cartella non esiste" 8 60
            fi
        fi
    done
}

#   Funzione per la creazione della cartella che conterrà il backup
function folderCreation() {
    #Creo la cartella del backup formato "gg-MM-aaaa:hh-mm"
    data=$(date +"%d-%m-%Y:%H-%M")
    backupPath="/backup/$data"
    whiptail --title "Backup Bash" --msgbox "Creazione cartella del backup" 8 60

    #Se la cartella esiste, cancello il backup precedente dello stesso minuto
    if [ -e $backupPath ]
        then
            sudo rm -r $backupPath
    fi

    #Creo la cartella di backup
    sudo mkdir "/backup/$data"

    #Se la password inserite nel sudo è errata tre volte e quindi non è stata creata la cartella chiudo il programma mostrando l'errore
    if [ ! -e $backupPath ]
        then
            whiptail --title "Backup Bash" --msgbox "Password Errata, backup non eseguibile" 8 60
            exit 0
    fi
    sudo touch "/backup/$data/report.txt" #Creo il file report nella cartella di backup
    sudo chmod 777 "/backup/$data/report.txt" #Do totali diritti di accesso al file
} 

#   Funzione per eseguire il backup date le cartelle da escludere, compilazione simultanea del file di report
function backup() {
    clear
    whiptail --title "Backup Bash" --msgbox "BackUp in corso..." 8 60
    echo "Report Backup (Cartella Dimensione)" >> "/backup/$data/report.txt"
    
    #Inizio a contare quanto dura il backup
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

        #Se la cartella non è esclusa, la copia nella cartella di backup
        if ! $escluso; then
            sudo cp -r "$cart" "$backupPath"
            dimensione_elemento=$(du -s "$cart" | cut -f1)
            sudo echo "$cart $dimensione_elemento KB" >> "$backupPath/report.txt"
            #Aggiungi la dimensione dell'elemento corrente alla somma totale
            somma_totale=$(( somma_totale + dimensione_elemento ))
        fi
    done
}

#   Funzione per concludere il file di report e stampa a schermo del report
function reportBackup() {
    #Salvo il risultato totale del report e stampo a schermo il contenuto del file
    echo >> "/backup/$data/report.txt"

    #Inserisco la durata in secondi del backup
    echo "Il backup è stato eseguito in $SECONDS secondi" >> "/backup/$data/report.txt"
    echo >> "/backup/$data/report.txt"

    #Inserimento dello spazio totale occupato dal backup
    echo "Totale $somma_totale KB">> "/backup/$data/report.txt"

    #Visualizzo a schermo il report
    whiptail --title "Backup Bash" --msgbox "$(cat "/backup/$data/report.txt")" 20 80
}

#   Funzione per chi non ha diritti amministratore, apertura della cartella dei backup
function nonRoot() {
    whiptail --title "Backup Bash" --msgbox "Sono richiesti i diritti amministratore per fare un backup, è permesso visualizzare i backup precedenti" 8 60
    open .
}

#main
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

    #Inizio del backup
    getExcluded
    folderCreation
    backup
    reportBackup
    whiptail --title "Backup Bash" --msgbox "Backup Completato Correttamente" 8 60
else

    #Controllo se la cartella di backup esiste, se non esiste invio un messaggio all'utente e chiudo il programma
    if [ -e "backup" ]
        then
            cd backup
            nonRoot
        else
            whiptail --title "Errore" --msgbox "La cartella di Backup non esiste, sono richiesti i diritti amministratore per creare la cartella backup" 8 60       
    fi
    
fi
