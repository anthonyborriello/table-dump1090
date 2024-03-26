#!/bin/bash

# Clear the screen
clear

# Function to check if a package is installed
check_package_installed() {
    dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -c "ok installed"
}

# Check if Lighttpd is installed
if [ $(check_package_installed "lighttpd") -eq 0 ]; then
    echo "Lighttpd is not installed. Installing Lighttpd..."
    sudo apt-get update
    sudo apt-get install -y lighttpd
fi

# Check if PHP packages are installed
if [ $(check_package_installed "php") -eq 0 ] || [ $(check_package_installed "php-fpm") -eq 0 ] || [ $(check_package_installed "php-cgi") -eq 0 ]; then
    echo "PHP packages are not installed. Installing PHP and the required packages..."
    sudo apt-get update
    sudo apt-get install -y php8.2 php8.2-fpm php8.2-cgi
fi

# Enable the fastcgi-php module in Lighttpd
echo "Enabling fastcgi-php module in Lighttpd..."
sudo lighty-enable-mod fastcgi-php

# Force reload Lighttpd to apply changes
echo "Reloading Lighttpd service..."
sudo service lighttpd force-reload

# Function to ask the user if dump1090 is installed
ask_dump1090() {
    read -p "Have you installed dump1090? (y/n): " dump1090_installed

    # Convert the response to lowercase
    dump1090_installed=${dump1090_installed,,}

    # Check user's response
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

# Ask the user if dump1090 is installed
ask_dump1090

# Clear the screen
clear

# Function to ask the user to input coordinates
ask_coordinates() {
    read -p "Enter latitude (e.g., 41.9028): " latitude
    read -p "Enter longitude (e.g., 12.4964): " longitude

    # Check if the entered coordinates have the correct format
    if [[ ! "$latitude" =~ ^-?[0-9]+(\.[0-9]{1,4})?$ || ! "$longitude" =~ ^-?[0-9]+(\.[0-9]{1,4})?$ ]]; then
        echo "Please enter valid coordinates."
        ask_coordinates
    fi
}

# Function to ask the user to input the server name
ask_server_name() {
    read -p "Please provide the name of your server (default is raspberrypi): " server_name

    # Set the server name to "raspberrypi" if no value is provided
    server_name=${server_name:-raspberrypi}
}

echo "Welcome to the setup script for Table Dump1090."
echo "An idea of Antonio Borriello (https://github.com/anthonyborriello)"
echo "This script will guide you through the customization process."
echo

# Ask the user to input coordinates
echo "Please provide the latitude and longitude of your station."
echo "These should be the same coordinates used for dump1090."
echo "Here are some examples:"
echo " - Rome: 41.9028 12.4964"
echo " - New York: 40.7128 -74.0060"
echo " - Tokyo: 35.6895 139.6917"
echo " - London: 51.5074 -0.1278"
ask_coordinates

# Ask the user to input the server name
ask_server_name

# Download the radar_table.php file to the user's home folder
echo "Downloading radar_table.php from GitHub..."
wget -O ~/radar_table.php https://raw.githubusercontent.com/anthonyborriello/table-dump1090/main/radar_table.php
echo "Download completed."

# Replace the coordinates and server name in the radar_table.php file
sed -i "s/\$reference_point = array(41.9028, 12.4964);/\$reference_point = array($latitude, $longitude);/" ~/radar_table.php
sed -i "s#http://raspberrypi:8080/data/aircraft.json#http://$server_name:8080/data/aircraft.json#" ~/radar_table.php

# Move the file to the web server's folder
sudo mv ~/radar_table.php /var/www/html

# Show a setup completed message with a final colored link
echo "Setup completed successfully
