<?php
	require('../vRP-ingame/dbconnect_oop.php');
	
	$db = new Db();
	
	$rowsFaction = $db -> select("SELECT * FROM vrp_factions");

	$gwArray = array();
	
	$rowsGw = $db -> select("SELECT * FROM vrp_gangwar");
	
	foreach ($rowsFaction as &$rowFaction)
	{
		$factionName = $rowFaction["Name_Short"];
		$gwArray[$factionName] = 0;
		foreach ($rowsGw as &$rowGw)
		{
			if ($rowGw["Besitzer"] == $rowFaction["Id"]){
				$gwArray[$factionName] = $gwArray[$factionName]+1;
			}
		}
	
	}
	
	$output = "";
	foreach ($gwArray as $frak => $count) {
		$output = $output."['$frak', $count],";
	}
	
	$output =  substr($output, 0, -1);
?>

<html>
  <head>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript">
      google.charts.load('current', {'packages':['corechart']});
      google.charts.setOnLoadCallback(drawChart);
      function drawChart() {

        var data = google.visualization.arrayToDataTable([
          ['Fraktion', 'Gebiete'],
          <?php
				echo $output;
		  ?>
        ]);

        var options = {
          title: 'Gangwar-Gebiet Aufteilung',
		  width: 500,
		  height: 400,
		  slices: {
            0: { color: 'rgb(11,102,8)' },
            1: { color: 'rgb(96,96,96)' },
			2: { color: 'rgb(0,125,0)' },
            3: { color: 'rgb(187,0,0)' },
            4: { color: 'rgb(100,100,100)' },
            5: { color: 'rgb(140,20,0)' },
            6: { color: 'rgb(96,96,96)' },
            7: { color: 'rgb(96,96,96)' }

          }
        };

        var chart = new google.visualization.PieChart(document.getElementById('piechart'));

        chart.draw(data, options);
      }
    </script>
  </head>
  <body>
    <div id="piechart" style="width: 500px; height: 400px;"></div>
  </body>
</html>