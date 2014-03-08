<?php
/* Todo List for the API Interface */
/* 
* Limit calls (We don't want anyone to DoS internal services)
* Limit different activation calls (Avoid spamming innocent users)
* Disable sending activations to activated users
* Actually store activations
* Enable Gameserver Limitation
*/
require_once("constants.php");
require_once("utils.php");
require_once("api_wbb.php");

class APIHandler
{
	public static function IsGameserver()
	{
		return true || $_SERVER['REMOTE_ADDR'] == MTA_IP || $_SERVER['REMOTE_ADDR'] == "127.0.0.1";
	}

	public static function CreateAccount()
	{
		if(!APIHandler::IsGameserver()) die();
		if(!isset($_GET["username"]) || !isset($_GET["password"])) die();
		return API::CreateAccount($_GET["username"], $_GET["password"]);
	}
	
	public static function SendActivation()
	{
		if(!isset($_GET["nick"]) || !isset($_COOKIE["wcf_userID"])) die();
		return API::SendActivation($_COOKIE["wcf_userID"], $_GET["nick"]);
	}

	public static function CheckActivation()
	{
		if(!isset($_GET["key"]) || !isset($_COOKIE["wcf_userID"])) die();
		return API::CheckActivation($_COOKIE["wcf_userID"], $_GET["key"]);
	}
}
if(!isset($_GET["action"])) die();

// is this safe?
echo call_user_func("APIHandler::" . $_GET["action"]);
?>