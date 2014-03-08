<?php
require("../../../../../global.php");
use wcf\acp\form\UserAddForm;
use wcf\data\user\avatar\Gravatar;
use wcf\data\user\avatar\UserAvatarAction;
use wcf\data\user\group\UserGroup;
use wcf\data\user\User;
use wcf\data\user\UserAction;
use wcf\data\user\UserEditor;
use wcf\data\user\UserProfile;
use wcf\data\user\UserProfileAction;
use wcf\system\exception\NamedUserException;
use wcf\system\exception\PermissionDeniedException;
use wcf\system\exception\UserInputException;
use wcf\system\language\LanguageFactory;
use wcf\system\mail\Mail;
use wcf\system\recaptcha\RecaptchaHandler;
use wcf\system\request\LinkHandler;
use wcf\system\user\authentication\UserAuthenticationFactory;
use wcf\system\Regex;
use wcf\system\WCF;
use wcf\util\HeaderUtil;
use wcf\util\StringUtil;
use wcf\util\UserRegistrationUtil;
use wcf\util\UserUtil;
use wcf\data\vrp\TS3;

class API
{
	public static function CreateAccount($username, $password)
	{
		// check for forbidden chars (e.g. the ",")
		if (!UserUtil::isValidUsername($username)) {
			return "0";
		}
		
		// Check if username exists already.
		if (!UserUtil::isAvailableUsername($username)) {
			return "0";
		}
		
		// create user
		$data = array(
			'data' => array(
				'username' => $username,
				'password' => $password,
			),
			'groups' => UserGroup::getGroupIDsByType(array(UserGroup::EVERYONE, UserGroup::GUESTS)),
			'addDefaultGroups' => true
		);
		$objectAction = new UserAction(array(), 'create', $data);
		$result = $objectAction->executeAction();
		$user = $result['returnValues'];
		$userEditor = new UserEditor($user);
		$action = new UserProfileAction(array($userEditor), 'updateUserRank');
		$action->executeAction();
		
		return $user->userID;
	}
	
	public static function SendActivation($boardId, $ts3nick)
	{
		$sql = new mysqli(MYSQL_HOST, MYSQL_USER, MYSQL_PW, MYSQL_DB);
		$data = dbQueryFetchSingle($sql, "SELECT boardId, authKey FROM forum_ts3auth WHERE boardId = ?;", "i", $boardId);
		
		$client = TS3::singleton()->getClientFromName($ts3nick);
		if($client == null)
			return "Nutzer nicht mit dem Teamspeak 3 Server verbunden.";
					
		if($data)
			$key = $data["authKey"];
		else
		{
			$key = generateRandomString(5);
			dbExec($sql, "INSERT INTO forum_ts3auth(boardId, authKey, ts3uid) VALUES(?, ?, ?);", "iss", $boardId, $key, $client->getInfo()["client_unique_identifier"]);
		}
		$sql->close();
		
			
		$client->message("Dein Aktivierungskey lautet " . $key);
		$client->message("Bitte gib diesen Schlüssel unter http://forum.v-roleplay.net/Userpanel/TS3 ein.");

		return true;
	}
	
	public static function CheckActivation($boardId, $key)
	{
		$sql = new mysqli(MYSQL_HOST, MYSQL_USER, MYSQL_PW, MYSQL_DB);
		$data = dbQueryFetchSingle($sql, "SELECT ts3uid FROM forum_ts3auth WHERE boardId = ? AND authKey = ?;", "is", $boardId, $key);
		$sql->close();
		if($data)
		{
			$action = new UserAction(array(WCF::getUser()), 'update', 
				array(
					'options' => array(User::getUserOptionID('ts3uid') => $data["ts3uid"]),
					'removeGroups' => array(VRP_FORUM_GROUP_TS3_UNVERIFIED)
				)
			);
			$action->executeAction();
			$action = new UserAction(array(new UserEditor(WCF::getUser())), 'addToGroups', array(
				'groups' => array(VRP_FORUM_GROUP_TS3_VERIFIED),
				'addDefaultGroups' => false,
				'deleteOldGroups' => false
			));
			$action->executeAction();
			return true; 
		}
		else
			return "Ungültiger Schlüssel";
	}
	
	
}