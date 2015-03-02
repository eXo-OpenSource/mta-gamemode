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
});

function addCrime(playerName, crimeName) {
	$("#crime tr:last").after("<tr><td>" + playerName + "</td><td>" + crimeName + "</td>"+ "</tr>");
}

// Register MTA event handler
mtatools.registerEvent("addCrimeToList", addCrime);
