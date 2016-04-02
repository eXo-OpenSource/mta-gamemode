<style>
	body{
		overflow:hidden;
	}
</style>
<center>
<?php 
	if (isset($_GET["skin"])){
		echo '<img style="height:90%;" src="../../images/skins/Skin'.$_GET["skin"].'.jpg" />';
	}
?>
</center>