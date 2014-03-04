<?php
require_once("settings.php");
require_once("utils.php");

class API
{
	const TS3_RIGHT_ACTIVATED = 1;
	const TS3_RIGHT_ADMINISTRATOR = 2;
	
	public static function TS3_SendActivation($boardId, $ts3nick)
	{
		$sql = new mysqli(MYSQL_HOST, MYSQL_USER, MYSQL_PW, MYSQL_DB);
		$data = dbQueryFetchSingle($sql, "SELECT boardId, authKey FROM ts3_auth WHERE boardId = ?;", "i", $boardId);
		try
		{
			$ts3 = TeamSpeak3::factory(TS3_FACTORY);	
		}
		catch(Exception $e)
		{
			return "Konnte nicht mit dem Teamspeak 3 Server verbinden.";
		}

		try
		{
			$client = $ts3->clientGetByName($ts3nick);
		}
		catch(Exception $e)
		{
			return "Nutzer nicht mit dem Teamspeak 3 Server verbunden.";
		}
			
		if($data)
			$key = $data["authKey"];
		else
		{
			$key = generateRandomString(5);
			dbExec($sql, "INSERT INTO ts3_auth(boardId, authKey, ts3uid) VALUES(?, ?, ?);", "iss", $boardId, $key, $client->getInfo()["client_unique_identifier"]);
		}
		$sql->close();
		
			
		$client->message("Dein Aktivierungskey lautet " . $key);
		$client->message("Bitte gib diesen Schlüssel unter http://forum.v-roleplay.net/Userpanel/TS3 ein.");

		return true;
	}
	
	public static function TS3_CheckActivation($boardId, $key)
	{
		$sql = new mysqli(MYSQL_HOST, MYSQL_USER, MYSQL_PW, MYSQL_DB);
		$data = dbQueryFetchSingle($sql, "SELECT boardId FROM ts3_auth WHERE boardId = ? AND authKey = ?;", "is", $boardId, $key);
		$sql->close();
		if($data)
			return true;
		else
			return "Ungültiger Schlüssel";
	}
	
};
?>