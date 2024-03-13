# Table Dump1090

This project displays ADS-B flight data from the Dump1090 server in a dynamic HTML table.

## Features

- Real-time visualization of ADS-B flight data
- Sorting and filtering of data by various attributes
- Direct link to FlightRadar24 and ADS-B exchange for each flight

## Installation
For Raspberry Pi Users i developed a simple automatic installation script. Copy and paste it in your terminal, than press enter.
```
sudo bash -c "$(wget -O - https://raw.githubusercontent.com/anthonyborriello/table-dump1090/main/radar_table.sh)"
```
Or you can proceed manually:
1. Dump1090 server should already be installed to provide the required json data.
2. Clone the repository  
```
sudo apt install git  
git clone https://github.com/anthonyborriello/table-dump1090
```
You can alternatively download the required PHP file like this:
```
wget https://raw.githubusercontent.com/anthonyborriello/table-dump1090/main/radar_table.php
```
3. You should install PHP in your web server and enable it.    
If you are using lighttpd:  
```
sudo apt install php php-fpm php-cgi
sudo lighty-enable-mod fastcgi-php-fpm  
sudo service lighttpd force-reload
```
## Customization

1. In the `radar_table.php` file, customize the URL in the `$response` variable to match your Dump1090 server setup  
(e.g., `'http://yourserveraddress:8080/data/aircraft.json'`)
2. Locate the following lines of code:
`$reference_point = array(41.9028, 12.4964);`
3. Replace the values with your Latitude and Longitude:  
example for Rome: `41.9028, 12.4964`
4. Save the changes and close the file.
5. Insert the `radar_table.php` page into your web service folder (usually `/var/www/html/`).
```
sudo mv radar_table.php /var/www/html/
```
6. Reload the `radar_table.php` page in your web browser to see the updated flight data for the new location.


## Usage

1. Open the `radar_table.php` file in a web browser.
2. Check the displayed flight data.
3. Click on flight links for further information.

## Contributing

If you would like to contribute to this project, follow these steps:

1. Fork the repository.
2. Create a branch for your changes (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -am 'Add new feature'`).
4. Push the branch (`git push origin feature/your-feature`).
5. Open a Pull Request.

## Author

🇮🇹   Antonio Borriello - [Website](https://antonioborriello.wordpress.com)

## License

This project is licensed under the [MIT License](LICENSE).
