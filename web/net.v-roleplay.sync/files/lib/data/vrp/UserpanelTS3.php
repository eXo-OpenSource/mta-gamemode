<?php
namespace wcf\page;
use wcf\system\WCF;

?>
<div id="ts3_box">
<div id="infotext">
Hier kannst du deine Teamspeak 3 Identität mit deinem Forenaccount verknüpfen, wodurch deine Identität auf dem Teamspeak Server verifiziert wird.

Betrete zuerst unseren Teamspeak 3 Server
Gebe deinen Nicknamen auf dem Teamspeak 3 Server in folgende Box ein
</div>
<br/><br/>
<div id="stage1">
<input id="nick" type="text"/>
<input id="submit" type="submit" value="Absenden"/>
<br/>
<div id="error"></div>
<div id="success">Gebe nun hier den auf dem Teamspeak Server erhaltenen Code ein.</div>
</div>
<br/>
<div id="stage2">
<input id="key" type="text"/>
<input id="submit" type="submit" value="Absenden"/>
<br/>
<div id="error"></div>
<div id="success">Teamspeak Identität erfolgreich autentifiziert.</div>
</div>
</div>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js" type="text/javascript"></script>
<script>
$(document).ready(
function()
{
	var parent = $("#ts3_box");
	var stage1 = $("#stage1", parent);
	var stage2 = $("#stage2", parent);
	
	$("#submit", stage1).click(function(){
		var nick = $("#nick", stage1).val();
		var qry = $.get( "http://www.v-roleplay.net/forum/wcf/lib/data/vrp/api.php?action=SendActivation&nick="+nick,
		function(data)
		{	
			if(data != "1")
			{
				$("#error", stage1).html("<br/><b>Fehler: </b>"+data);
				return false;
			}
			
			$("#success", stage1).show();
			$("#error", stage1).hide();
			$("#stage2", parent).show();
		},
		"text");
	})	
	
	$("#submit", stage2).click(function(){
		var key = $("#key", stage2).val();
		var qry = $.get( "http://www.v-roleplay.net/forum/wcf/lib/data/vrp/api.php?action=CheckActivation&key="+key,
		function(data)
		{	
			alert(data);
			if(data != "1")
			{
				$("#error", stage2).html("<br/><b>Fehler: </b>"+data);
				return false;
			}
			
			$("#success", stage2).show();
			$("#error", stage2).hide();
		},
		"text");
	})
	
	$("#success", stage1).hide();

	$("#stage2", parent).hide();
	$("#success", stage2).hide();
}
);
</script>