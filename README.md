# Table Dump1090

This project displays ADS-B flight data from the Dump1090 server in a dynamic HTML table.

## Features

- Real-time visualization of ADS-B flight data
- Sorting and filtering of data by various attributes
- Direct link to FlightRadar24 and ADS-B exchange for each flight

## Installation

1. Clone the repository.
2. Configure the Dump1090 server to provide the data.
3. Insert the `radar_table.php` page into your web service folder (usually `/var/www/html/`).
4. In the `radar_table.php` file, customize the URL in the `$response` variable to match your Dump1090 server setup  
(e.g., `'http://yourserveraddress:8080/data/aircraft.json'`)

## Customization

To specify the desired location for displaying flight data, you can modify the `radar_table.php` file. Follow these steps:

1. Open the `radar_table.php` file in a text editor.
2. Locate the following lines of code:
`$reference_point = array(41.9028, 12.4964);`
3. Replace the values with your Latitude and Longitude:  
example for Rome: `41.9028, 12.4964`
4. Save the changes and close the file.
5. Reload the `radar_table.php` page in your web browser to see the updated flight data for the new location.


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
