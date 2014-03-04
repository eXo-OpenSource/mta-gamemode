<?php
require("../global.php");
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

class API
{
	public static function MTA_CreateAccount($username, $password)
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
}