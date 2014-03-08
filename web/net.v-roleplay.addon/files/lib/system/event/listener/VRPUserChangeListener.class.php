<?php
namespace wcf\system\event\listener;
use wcf\system\event\IEventListener;
use wcf\data\vrp\VRP;
use wcf\util\StringStack;
use wcf\util\HeaderUtil;
use wcf\data\user\group\UserGroup;
use wcf\data\user\User;
use wcf\data\user\UserEditor;

class VRPUserChangeListener implements IEventListener
{
	public $groupList = array();
	public static $insideCreation = false;
	
	public function execute($eventObj, $className, $eventName)
	{
		$parameter = $eventObj->getParameters();
		
		if($eventObj->getActionName() == "update" && $eventName == "initializeAction")
		{	
			foreach($users as $userid)
			{
				$user = User($userid);
				if(isset($parameter["removeGroups"]))
					VRP::OnUserGroupRemove($user, $parameter["removeGroups"]);
				
				if(isset($parameter["options"][User::getUserOptionID("ts3uid")]))
				{
					VRP::OnUserTSIdentityChange($user, 
						$userObj->getUserOption("ts3uid"),
						$parameter["options"][User::getUserOptionID("ts3uid")]);
				}
			}
		}
		if($eventName == "finalizeAction")
		{
			// Called when a user is added to groups
			if($eventObj->getActionName() == "addToGroups")
			{
				if (VRPUserChangeListener::$insideCreation) return;
				$users = $eventObj->getObjectIDs();
				
				foreach($users as $userid)
				{
					$user = User($userid);
					VRP::OnUserGroupAdd($user, $parameter["groups"]);
				}
			}
			
			// Called when a user is created
			if($eventObj->getActionName() == "create")
			{
				$user = $eventObj->getReturnValues()["returnValues"];
				VRPUserChangeListener::$insideCreation = true;
				VRP::OnUserCreate($user);
				VRPUserChangeListener::$insideCreation = false;
			}
			
			// Called when a user is deleted
			if($eventObj->getActionName() == "delete")
			{
				$users = $eventObj->getObjectIDs();
				
				foreach($users as $userid)
				{
					$user = User($userid);
					VRP::OnUserDelete($user);
				}
			}
		}
	}
}
?>