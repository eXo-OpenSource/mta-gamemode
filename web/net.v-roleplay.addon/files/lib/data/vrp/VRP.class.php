<?php
namespace wcf\data\vrp;
use wcf\system\WCF;
use wcf\data\vrp\TS3;
use wcf\data\vrp\MTA;
use wcf\data\user\User;
use wcf\data\user\UserAction;
use wcf\data\user\UserEditor;
use wcf\data\user\group\UserGroup;

class VRP
{
	public static function OnUserCreate($user)
	{
		$action = new UserAction(array(new UserEditor($user)), 'addToGroups', array(
			'groups' => array(VRP_FORUM_GROUP_TS3_UNVERIFIED),
			'addDefaultGroups' => false,
			'deleteOldGroups' => false
		));
		$action->executeAction();
	}
	
	public static function OnUserGroupRemove($user, $groupList)
	{
		// TS3
		$uid = $user->ts3uid;
		if ($uid == "") return;
		
		foreach($groupList as $group)
		{
			TS3::singleton()->setUidClientGroup($uid, $group["groupID"], false);
		}
	}
	
	public static function OnUserGroupAdd($user, $groupList)
	{
		// TS3
		$uid = $user->ts3uid;
		if ($uid == "") return;
		
		foreach($groupList as $group)
		{
			TS3::singleton()->setUidClientGroup($uid, $group["groupID"], true);
		}	
	}
	
	public static function OnUserGroupChange($user)
	{
		// TS3
		$uid = $user->ts3uid;
		if ($uid == "") return;
		$userGroups = $user->getGroupIDs();
		foreach(UserGroup::getGroupsByType() as $group)
		{
			TS3::singleton()->setUidClientGroup($uid, $group->groupID, in_array($group->groupID, $userGroups));
		}
	}
	
	public static function OnUserDelete($user)
	{
		// TS3
		$uid = $user->ts3uid;
		if ($uid == "") return;
		
		$groups = UserGroup::getGroupsByType();
		foreach($groups as $group)
		{
			TS3::singleton()->setUidClientGroup($uid, $group->groupID, false);
		}
	}
	
	public static function OnUserTS3IdentityChange($user, $oldidentity, $newidentity)
	{
		VRP::OnUserDelete($user);
		$editor = new UserEditor($user);
		$editor->updateUserOptions(array(User::getUserOptionID("ts3uid") => $newidentity));
		VRP::OnUserGroupChange($user);
	}
}