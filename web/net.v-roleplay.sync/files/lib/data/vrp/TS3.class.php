<?php
namespace wcf\data\vrp;
use wcf\system\WCF;
use wcf\system\exception\SystemException;

require_once("libraries/TeamSpeak3/TeamSpeak3.php");

class TS3
{
	private static $instance;
	private $ts3 = null;
	
	public static function singleton()
	{
		if(!isset(self::$instance))
			self::$instance = new TS3;
			
		return self::$instance;
	}
	
	public function __construct()
	{
		$factory = "serverquery://".VRP_TS3_QUERY_USERNAME.":".VRP_TS3_QUERY_PASSWORD."@".VRP_TS3_SERVERIP.":".VRP_TS3_QUERYPORT."/?server_port=".VRP_TS3_SERVERPORT."&nickname=System";
	
		$this->ts3 = \TeamSpeak3::factory($factory);
	}
	
	public function __destruct()
	{
		
	}

	public function getClientFromName($name)
	{
		try
		{
			return $this->ts3->clientGetByName($name);
		}
		catch(\Exception $e)
		{
			return null;
		}
	}
	
	public function getClientFromUid($uid)
	{
		try
		{
			return $this->ts3->clientGetByUid($uid);
		}
		catch(\Exception $e)
		{
			return null;
		}	
	}
	
	public function setUidClientGroup($uid, $group, $isMember)
	{
		try { 
		$groupID = $this->getTS3GroupId($group);
		if($groupID == 0) 
			return;
	
		$cldbid = $this->ts3->clientFindDb($uid, true); 
		
		
		if($isMember)
			$this->ts3->serverGroupClientAdd($groupID, $cldbid);
		else
			$this->ts3->serverGroupClientDel($groupID, $cldbid);
			
		}
		catch(\Exception $e) { return null; }
	}
	
	public function getTS3GroupId($groupId)
	{
		switch($groupId)
		{
			case 7: return 15; // TS3 Verifiziert -> Verifiziert
		}
		return 0;
	}
}