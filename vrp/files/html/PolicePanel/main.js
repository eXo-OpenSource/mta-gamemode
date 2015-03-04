$(function(){
	$("#main-menu ul li a").click(function(){
		var open = $(this).attr("rel");
		$("#main-menu").hide(function() {
			$(this).attr("class", "hidden");
		});
		$("#"+open).attr("class", "menu");
		$("#"+open).show();
		$("#top #back").show();
		return false;
	});

	$("#top #back").click(function(){
		$("#main-menu").show(function() {
			$(this).removeAttr("class");
		});
		$(".menu").attr("class", "menu hidden");
		$(".menu").hide();
		$("#top #back").hide();
		return false;
	});

	$("#recordSearchButton").click(function() {
		// Clear list
		$("#recordList").empty();

		if (!crimeData)
			return;

		var playerName = $("#recordPlayerName").val();

		for (playerInfo of crimeData) {
			if (playerInfo.player == playerName) {

				// Add crimes to the list
				for (crime of playerInfo.crimes) {
					$("#recordList").append("<li>" + crime + "</li>");
				}

				// Exit func
				return;
			}
		}

		// Add default entry
		$("#recordList").append("<li>Keine Einträge vorhanden</li>");
	});

	// Trigger click when the player presses enter
	$("#recordPlayerName").keyup(function(event) {
		if (event.keyCode == 13)
			$("#recordSearchButton").click();
	});
});

var crimeData = null;

function setCrimes(info) {
	crimeData = info;

	// Add crimes to current crime list
	for (playerInfo of info) {
		for (crime of playerInfo.crimes) {
			// Add to table
			$("#crime").append("<tr><td>" + playerInfo.player + "</td><td>" + crime + "</td>"+ "</tr>");
		}
	}

	// Sort array
	info.sort(function(a, b) { return a.wanted < b.wanted; });

	// Add players to most-wanted list
	for (playerInfo of info) {
		$("#most-wanted-list").append("<tr><td>" + playerInfo.player + "</td><td>" + playerInfo.wanted + "</td>"+ "</tr>");
	}
}

// Register MTA event handler
mtatools.registerEvent("setCrimes", setCrimes);




/*$(document).ready(function() {
	setCrimes([
		{
			player: "PlayerName",
			wanted: 6,
			crimes: ["Bla1", "Bla2"]
		},
		{
			player: "player2",
			wanted: 5,
			crimes: ["Bl21", "Bl22"]
		}
	]);
});*/
