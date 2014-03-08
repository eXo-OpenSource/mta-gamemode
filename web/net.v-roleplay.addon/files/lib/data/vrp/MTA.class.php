<?php
namespace wcf\data\vrp;
use wcf\system\WCF;
use wcf\system\exception\SystemException;

class MTA
{
	private static $instance;
	
	public static function singleton()
	{
		if(!isset(self::$instance))
			self::$instance = new MTA;
			
		return self::$instance;
	}
	
	public function __construct()
	{
	}
	
	public function __destruct()
	{
		
	}
}