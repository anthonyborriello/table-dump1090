#!/bin/bash

# Pulisci la schermata
clear

# Funzione per chiedere all'utente se dump1090 è installato
ask_dump1090() {
    read -p "Have you installed dump1090? (y/n): " dump1090_installed

    # Converti la risposta in minuscolo
    dump1090_installed=${dump1090_installed,,}

    # Verifica la risposta dell'utente
    if [[ "$dump1090_installed" != "y" && "$dump1090_installed" != "n" ]]; then
        echo "Please answer with y or n."
        ask_dump1090
    fi

    if [[ "$dump1090_installed" == "n" ]]; then
        echo "Error: dump1090 is not installed."
        echo "Please install dump1090 first in order to use this script."
        exit 1
    fi
}

# Chiedi all'utente se dump1090 è installato
ask_dump1090

# Pulisci la schermata
clear

# Verifica se i pacchetti PHP sono installati
if ! dpkg -l | grep -q '^ii.*php[0-9].[0-9]-fpm.*' && ! dpkg -l | grep -q '^ii.*php[0-9].[0-9]-cgi.*'; then
    echo "Error: PHP packages are not installed."
    echo "Installing PHP and the required packages..."
    sudo apt-get update
    sudo apt-get install php php-fpm php-cgi
    sudo lighttpd-enable-mod fastcgi-php
    sudo service lighttpd force-reload
fi

# Funzione per chiedere all'utente di inserire le coordinate
ask_coordinates() {
    read -p "Enter latitude (e.g., 41.9028): " latitude
    read -p "Enter longitude (e.g., 12.4964): " longitude

    # Verifica se le coordinate inserite hanno il formato corretto
    if [[ ! "$latitude" =~ ^[0-9]+(\.[0-9]{1,4})?$ || ! "$longitude" =~ ^[0-9]+(\.[0-9]{1,4})?$ ]]; then
        echo "Please enter valid coordinates."
        ask_coordinates
    fi
}

# Funzione per chiedere all'utente di inserire il nome del server
ask_server_name() {
    read -p "Please provide the name of your server (default is raspberrypi): " server_name

    # Imposta il nome del server su "raspberrypi" se non viene fornito un valore
    server_name=${server_name:-raspberrypi}
}

echo "Welcome to the setup script for Table Dump1090."
echo "An idea of Antonio Borriello (https://github.com/anthonyborriello)"
echo "This script will guide you through the customization process."
echo

# Chiedi all'utente di inserire le coordinate
echo "Please provide the latitude and longitude of your station."
echo "These should be the same coordinates used for dump1090."
echo "Here are some examples:"
echo " - Rome: 41.9028 12.4964"
echo " - New York: 40.7128 -74.0060"
echo " - Tokyo: 35.6895 139.6917"
echo " - London: 51.5074 -0.1278"
ask_coordinates

# Chiedi all'utente di inserire il nome del server
ask_server_name

# Scarica il file radar_table.php nella cartella home dell'utente
echo "Downloading radar_table.php from GitHub..."
wget -O ~/radar_table.php https://raw.githubusercontent.com/anthonyborriello/table-dump1090/main/radar_table.php
echo "Download completed."

# Sostituisci le coordinate e il nome del server nel file radar_table.php
sed -i "s/\$reference_point = array(41.9028, 12.4964);/\$reference_point = array($latitude, $longitude);/" ~/radar_table.php
sed -i "s#http://raspberrypi:8080/data/aircraft.json#http://$server_name:8080/data/aircraft.json#" ~/radar_table.php

# Sposta il file nella cartella del web server
sudo mv ~/radar_table.php /var/www/html

# Mostra un messaggio di setup completato con un link finale colorato
echo "Setup completed successfully."
echo -e "You can now visit the page at: \e[32mhttp://$server_name/radar_table.php\e[0m"
