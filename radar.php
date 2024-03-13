<!DOCTYPE html>
<html>
<head>
    <title>Radar</title>
    <style>
body {
            font-family: 'Verdana', sans-serif;
            padding-top: 20px;
            background-color: #000;
            color: #fff;
        }

        h1 {
            font-weight: 100;
            text-align: center;
            padding-bottom: 4px;
        }

        .container {
            max-width: 1200px;
            margin: 20px auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed; /* Sets the table width based on the specified width and ignores the content */
        }

        th, td {
            padding: 0px;
            border-bottom: 1px solid #fff;
            text-align: center;
        }

        th {
            background-color: #004165;
        }

        tr:nth-child(even) {
            background-color: #00304e;
        }

        tr:nth-child(odd) {
            background-color: #00243a;
        }

        a.icao-link {
            color: #fff;
        }

        .flight-status {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 5px;
            color: #fff;
        }

        .adsb {
            background-color: #1a8cff;
        }

        a {
            color: #1a8cff;
            text-decoration: none;
        }

        a:hover {
            text-decoration: underline;
        }

        /* Sets a fixed height for all table rows */
        tr {
            height: 50px;
        }

        /* Sets the text for cells of empty rows */
        tr > td[colspan="9"]:empty::before {
            content: "";
            color: #fff;
        }
    </style>
    <meta http-equiv="refresh" content="5">
</head>
<body>

<div class="container">
  <div class="header">
    <h1>Dump1090 Radar Table</h1>
  </div>
<table>
    <tr>
        <th>ICAO</th>
        <th>Flight</th>
        <th>Squawk</th>
        <th>Altitude</th>
        <th>Ground Speed</th>
        <th>Distance (NM)</th>
        <th>Heading</th>
        <th>Latitude</th>
        <th>Longitude</th>
        <th>Status</th>
    </tr>

<?php
function calculate_distance($lat1, $lon1, $lat2, $lon2) {
    if ($lat1 == 0 || $lon1 == 0 || $lat2 == 0 || $lon2 == 0) {
        return "N/A"; // If any of the coordinates are missing, returns "N/A"
    }

    $R = 3440.065;
    $lat1_rad = deg2rad($lat1);
    $lon1_rad = deg2rad($lon1);
    $lat2_rad = deg2rad($lat2);
    $lon2_rad = deg2rad($lon2);
    $dlon = $lon2_rad - $lon1_rad;
    $dlat = $lat2_rad - $lat1_rad;
    $a = sin($dlat / 2)**2 + cos($lat1_rad) * cos($lat2_rad) * sin($dlon / 2)**2;
    $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
    $distance = $R * $c;
    return $distance;
}

$response = file_get_contents('http://raspberrypi:8080/data/aircraft.json');
if ($response) {
    $data = json_decode($response, true);
    $aircrafts = $data['aircraft'] ?? [];
    $reference_point = array(40.7934, 14.3686);
    $aircraft_distances = [];

    foreach ($aircrafts as $aircraft) {
        $aircraft_lat = $aircraft['lat'] ?? 0;
        $aircraft_lon = $aircraft['lon'] ?? 0;
        $distance = calculate_distance($reference_point[0], $reference_point[1], $aircraft_lat, $aircraft_lon);

        // Checks if the coordinates are present and sets the $status variable
        if ($aircraft_lat != 0 && $aircraft_lon != 0) {
            $status = "ADSB";
        } else {
            // If coordinates are missing, checks if the 'category' field is present
            $status = isset($aircraft['category']) && !empty($aircraft['category']) ? "ADSB" : "N/A";
        }
        
        // Limit the number of decimal places to 2 if it's a number
        if (is_numeric($distance)) {
            $formatted_distance = number_format($distance, 2);
        } else {
            $formatted_distance = $distance;
        }

        $aircraft_distances[] = [
            'icao' => $aircraft['hex'],
            'flight' => $aircraft['flight'],
            'squawk' => $aircraft['squawk'],
            'altitude' => $aircraft['alt_baro'],
            'ground_speed' => $aircraft['gs'],
            'distance' => $formatted_distance,
            'heading' => $aircraft['track'],
            'latitude' => $aircraft['lat'],
            'longitude' => $aircraft['lon'],
            'status' => $status,
            'distance_numeric' => $distance // Saves the numeric distance for sorting
        ];
    }

    // Sorts the aircraft by distance
    usort($aircraft_distances, function($a, $b) {
        return $a['distance_numeric'] <=> $b['distance_numeric'];
    });

    // Prints the data in the HTML table
    foreach ($aircraft_distances as $aircraft_data) {
        echo "<tr>";
        echo "<td><a class='icao-link' href='https://globe.adsbexchange.com/?icao={$aircraft_data['icao']}' target='_blank'>{$aircraft_data['icao']}</a></td>";
        echo "<td><a href='https://www.flightradar24.com/{$aircraft_data['flight']}' target='_blank'>{$aircraft_data['flight']}</a></td>";
        echo "<td>{$aircraft_data['squawk']}</td>";
        echo "<td>{$aircraft_data['altitude']}</td>";
        echo "<td>{$aircraft_data['ground_speed']}</td>";
        echo "<td>{$aircraft_data['distance']}</td>";
        echo "<td>{$aircraft_data['heading']}</td>";
        echo "<td>{$aircraft_data['latitude']}</td>";
        echo "<td>{$aircraft_data['longitude']}</td>";
        echo "<td><span class='flight-status " . strtolower($aircraft_data['status']) . "'>{$aircraft_data['status']}</span></td>";
        echo "</tr>";
    }
} else {
    http_response_code(500);
    echo "<tr><td colspan='10'>500 Internal Server Error</td></tr>";
}
?>
</table>
</div>

</body>
</html>
