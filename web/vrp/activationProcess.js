function ActivationProcess(divname, sendaction, checkaction)
{
	var parent = $("#"+divname);
	var stage1 = $("#stage1", parent);
	var stage2 = $("#stage2", parent);
	
	$("#submit", stage1).click(function(){
		var nick = $("#nick", stage1).val();
		var qry = $.get( "http://127.0.0.1/wbb/api.php?action="+sendaction+"&nick="+nick,
		function(data)
		{	
			if(data != "1")
			{
				$("#error", stage1).html("Fehler: "+data);
				return false;
			}
			
			$("#success", stage1).show();
			$("#stage2", parent).show();
		},
		"text");
	})	
	
	$("#submit", stage2).click(function(){
		var key = $("#key", stage2).val();
		var qry = $.get( "http://127.0.0.1/wbb/api.php?action="+checkaction+"&key="+key,
		function(data)
		{	
			alert(data);
			if(data != "1")
			{
				$("#error", stage2).html("Fehler: "+data);
				return false;
			}
			
			$("#success", stage2).show();
		},
		"text");
	})
	
	$("#success", stage1).hide();

	$("#stage2", parent).hide();
	$("#success", stage2).hide();
}
