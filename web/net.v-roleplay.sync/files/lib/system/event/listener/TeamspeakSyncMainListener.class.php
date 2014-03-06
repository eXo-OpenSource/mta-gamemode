<?php
namespace wcf\system\event\listener;
use wcf\system\event\IEventListener;
use wcf\data\vrp\TS3;
use wcf\util\StringStack;
use wcf\util\HeaderUtil;
use wcf\data\user\group\UserGroup;
use wcf\data\user\User;
use wcf\data\user\UserEditor;

 
class TeamspeakSyncMainListener implements IEventListener
{
	public $groupList = array();
	
	public function execute($eventObj, $className, $eventName)
	{
		$parameter = $eventObj->getParameters();
		
		if($eventObj->getActionName() == "update" && $eventName == "initializeAction")
		{	
			// Called when a user is edited (acp)
			$users = $eventObj->getObjectIDs();
			foreach($users as $user)
			{
				if(isset($parameter["removeGroups"]))
					$this->RemoveGroup($user, $parameter["removeGroups"]);
			
				if(!isset($parameter["options"][User::getUserOptionID("ts3uid")])) continue;
			
				$newValue = $parameter["options"][User::getUserOptionID("ts3uid")];
				$users = $eventObj->getObjectIDs();
				$userObj = new User($user);
				
				$oldValue = $userObj->getUserOption("ts3uid");
				if($newValue != $oldValue)
				{
					$this->DeleteGroups($user);
					$this->SetUserTSIdentity($userObj, $newValue);
					$this->UpdateGroups($user);
				}
			}
		}
		if($eventName == "finalizeAction")
		{
			// Called when a user is added to groups
			if($eventObj->getActionName() == "addToGroups")
			{
				$users = $eventObj->getObjectIDs();
				
				foreach($users as $user)
				{
					$this->UpdateGroups($user, $parameter["groups"]);
				}
			}
			
			// Called when a user is deleted
			if($eventObj->getActionName() == "delete")
			{
				$users = $eventObj->getObjectIDs();
				
				foreach($users as $user)
				{
					$this->DeleteGroups($user);
				}
			}
		}
	}
	
	public static function SetUserTSIdentity(User $userObject, $newValue)
	{
		$editor = new UserEditor($userObject);
		$editor->updateUserOptions(array(User::getUserOptionID("ts3uid") => $newValue));
	}
	
	private function DeleteGroups($userID)
	{		
		if(empty($this->groupList))
			$this->groupList = UserGroup::getGroupsByType();
			
		$userObj = new User($userID);
		
		$uid = $userObj->ts3uid;
			
		foreach($this->groupList as $groupData)
		{
			TS3::singleton()->setUidClientGroup($uid, $groupData->groupID, false);
		}
	}
	
	public static function UpdateGroups($userID, $userGroups = array())
	{
		$userObj = new User($userID);
		if(empty($userGroups))
			$userGroups = $userObj->getGroupIDs();
		
		$groupList = UserGroup::getGroupsByType();
		
		$uid = $userObj->ts3uid;
		
		foreach($groupList as $groupData)
		{
			TS3::singleton()->setUidClientGroup($uid, $groupData->groupID, in_array($groupData->groupID, $userGroups));
		}
	}
	
	private function RemoveGroup($userID, $userGroups)
	{
		$userObj = new User($userID);
		
		if(empty($this->groupList))
			$this->groupList = UserGroup::getGroupsByType();
		
		$uid = $userObj->ts3uid;
			
		foreach($this->groupList as $groupData)
		{
			if(in_array($groupData->groupID, $userGroups))
			{
				TS3::singleton()->setUidClientGroup($uid, $groupData->groupID, false);
			}
		}
	}
}
?>