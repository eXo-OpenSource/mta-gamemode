<?php
/* Todo List for the API Interface */
/* 
* Limit calls (We don't want anyone to DoS internal services)
* Limit different activation calls (Avoid spamming innocent users)
* Disable sending activations to activated users
* Actually store activations
*/
if(!isset($_GET["action"])) die("Invalid");

if($_GET["action"] == "TS3SendActivation")
{
	if(!isset($_GET["nick"])) die("Invalid");
	if(!isset($_COOKIE["wcf_userID"])) die("Invalid");
	
	require_once("ts3.php");
	echo API::TS3_SendActivation($_COOKIE["wcf_userID"], $_GET["nick"]);
}

if($_GET["action"] == "TS3CheckActivation")
{
	if(!isset($_GET["key"])) die("Invalid");
	if(!isset($_COOKIE["wcf_userID"])) die("Invalid");
	
	require_once("ts3.php");
	echo API::TS3_CheckActivation($_COOKIE["wcf_userID"], $_GET["key"]);
}

// MTA Actions can only be made from the MTA Server
//if($_SERVER['REMOTE_ADDR'] == MTA_IP || $_SERVER['REMOTE_ADDR'] == "127.0.0.1")
//{
	if($_GET["action"] == "CreateAccount")
	{
		if(!isset($_GET["username"])) die("Invalid");
		if(!isset($_GET["password"])) die("Invalid");
		
		require_once("wbb.php");
		echo API::WBB_CreateAccount($_GET["username"], $_GET["password"]);
	}
//}
?>