Migration_20230707_2320_game_db = {}

Migration_20230707_2320_game_db.Database = MigrationManager.DATABASES.GAME;

Migration_20230707_2320_game_db.Up = function()
    return [[
      CREATE TABLE IF NOT EXISTS `phone_sms_head` (
        `ID` int(11) NOT NULL AUTO_INCREMENT,
        `PlayerId` int(11) DEFAULT 0,
        `Player` varchar(255) DEFAULT '',
        `TargetId` int(11) DEFAULT 0,
        `Empfaenger` varchar(255) DEFAULT '',
        `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
        `lastMessage` datetime(6) NOT NULL DEFAULT current_timestamp(),
        `hiddenForPlayer` int(255) NOT NULL DEFAULT 0,
        `hiddenForTarget` int(255) NOT NULL DEFAULT 0,
        PRIMARY KEY (`ID`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `phone_sms_msg` (
        `ID` int(11) NOT NULL AUTO_INCREMENT,
        `SMS_ID` int(11) DEFAULT NULL,
        `Player` varchar(255) DEFAULT '',
        `PlayerId` int(11) DEFAULT NULL,
        `Nachricht` varchar(255) NOT NULL,
        `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
        `gelesen` int(1) DEFAULT 0,
        `hiddenFor` varchar(255) DEFAULT NULL,
        PRIMARY KEY (`ID`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE `view_accountgroups` (
        `Id` INT(10) UNSIGNED NOT NULL,
        `ForumID` INT(10) NOT NULL,
        `FactionId` INT(11) NOT NULL,
        `FactionRank` INT(11) NOT NULL,
        `CompanyId` INT(11) NOT NULL,
        `CompanyRank` INT(11) NOT NULL,
        `premium_bis` INT(11) NOT NULL
      ) ENGINE=MyISAM;
      
      CREATE TABLE IF NOT EXISTS `vrp_account` (
        `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,
        `ForumID` int(10) NOT NULL,
        `Name` varchar(50) DEFAULT NULL,
        `EMail` varchar(50) DEFAULT NULL,
        `Rank` tinyint(3) DEFAULT NULL,
        `Salt` varchar(32) DEFAULT NULL,
        `Password` varchar(64) DEFAULT NULL,
        `LastSerial` varchar(32) DEFAULT NULL,
        `LastIP` varchar(15) DEFAULT NULL,
        `LastLogin` datetime DEFAULT NULL,
        `RegisterDate` datetime DEFAULT NULL,
        `migrated` int(1) NOT NULL DEFAULT 0,
        `InvitationId` int(11) NOT NULL DEFAULT 0,
        `TeamspeakId` varchar(255) DEFAULT NULL,
        `TeamspeakActivationCode` varchar(255) DEFAULT NULL,
        `AutologinToken` varchar(65) DEFAULT '',
        `RememberToken` varchar(100) DEFAULT NULL,
        `ApiToken` varchar(255) DEFAULT NULL,
        `TicketDisplay` tinyint(1) NOT NULL DEFAULT 0,
        PRIMARY KEY (`Id`) USING BTREE,
        KEY `pk_Id` (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      CREATE TABLE IF NOT EXISTS `vrp_account_activity` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Date` date NOT NULL,
        `UserId` int(11) NOT NULL,
        `SessionStart` bigint(20) DEFAULT NULL,
        `Duration` int(11) DEFAULT NULL COMMENT 'Duration in Minutes',
        `DurationDuty` int(11) DEFAULT NULL,
        `DurationAFK` int(11) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE,
        KEY `Date_UserID` (`Date`,`UserId`) USING BTREE,
        KEY `UserID_Date` (`UserId`,`Date`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_account_activity_group` (
        `Date` date NOT NULL,
        `UserId` int(11) NOT NULL,
        `ElementId` int(11) NOT NULL,
        `ElementType` tinyint(4) NOT NULL,
        `Duration` int(11) DEFAULT NULL COMMENT 'Duration in Minutes',
        `DurationDuty` int(11) DEFAULT NULL COMMENT 'DurationDuty in Minutes',
        PRIMARY KEY (`Date`,`ElementType`,`ElementId`,`UserId`) USING BTREE,
        KEY `Date_UserID` (`Date`,`UserId`) USING BTREE,
        KEY `UserID_Date` (`UserId`,`Date`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_account_activity_hourly` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Date` date DEFAULT NULL,
        `ActivityHour` int(11) DEFAULT NULL,
        `UserId` int(11) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_account_anticheat_whitelist` (
        `PlayerId` int(10) NOT NULL,
        `Bypass` text NOT NULL DEFAULT '[ [ ] ]',
        PRIMARY KEY (`PlayerId`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_account_mods` (
        `Serial` varchar(32) NOT NULL,
        `SHA256` varchar(64) NOT NULL,
        `Model` int(11) NOT NULL,
        `Name` varchar(255) NOT NULL,
        `MD5` varchar(32) NOT NULL,
        `MD5Padded` varchar(32) NOT NULL,
        `SHA256Padded` varchar(64) NOT NULL,
        `SizeX` double DEFAULT NULL,
        `SizeY` double DEFAULT NULL,
        `SizeZ` double DEFAULT NULL,
        `CreatedAt` datetime NOT NULL,
        `LastSeenAt` datetime NOT NULL,
        PRIMARY KEY (`Serial`,`SHA256`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_account_mod_bans` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `UserId` int(11) NOT NULL,
        `AdminId` int(11) NOT NULL,
        `CreatedAt` datetime NOT NULL,
        `ValidUntil` datetime DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_account_multiaccount` (
        `ID` int(11) NOT NULL AUTO_INCREMENT,
        `Serial` varchar(255) NOT NULL,
        `LinkedTo` text NOT NULL,
        `allowCreate` int(1) DEFAULT NULL,
        `Admin` int(11) DEFAULT NULL,
        `Timestamp` int(11) DEFAULT NULL,
        PRIMARY KEY (`ID`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_account_screenshot` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `AdminId` int(11) DEFAULT NULL,
        `UserId` int(11) DEFAULT NULL,
        `Tag` varchar(256) NOT NULL,
        `Status` varchar(16) NOT NULL,
        `Image` varchar(256) DEFAULT NULL,
        `CreatedAt` datetime DEFAULT NULL,
        `UpdatedAt` datetime DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_account_to_serial` (
        `ID` int(11) NOT NULL AUTO_INCREMENT,
        `PlayerId` int(11) NOT NULL,
        `Serial` varchar(255) NOT NULL,
        PRIMARY KEY (`ID`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_achievements` (
        `id` int(255) NOT NULL AUTO_INCREMENT,
        `name` varchar(255) DEFAULT NULL,
        `desc` varchar(255) DEFAULT NULL,
        `img` varchar(255) DEFAULT NULL,
        `exp` int(11) DEFAULT NULL,
        `neededProgress` int(11) NOT NULL,
        `enabled` int(1) DEFAULT 1,
        `hidden` int(1) DEFAULT 0,
        PRIMARY KEY (`id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_bank_accounts` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `OwnerType` int(11) NOT NULL,
        `OwnerId` int(11) NOT NULL,
        `Money` bigint(20) NOT NULL,
        `CreationTime` varchar(1000) NOT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      

      CREATE TABLE IF NOT EXISTS `vrp_bans` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `serial` varchar(32) CHARACTER SET latin1 DEFAULT NULL,
        `author` int(10) unsigned DEFAULT NULL,
        `reason` text DEFAULT NULL,
        `expires` int(10) unsigned DEFAULT NULL,
        `player_id` int(11) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE,
        UNIQUE KEY `Id` (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_binds` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Func` varchar(255) DEFAULT NULL,
        `Message` varchar(255) DEFAULT NULL,
        `OwnerType` varchar(255) DEFAULT NULL,
        `Owner` int(11) DEFAULT NULL,
        `Creator` int(11) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_blackjack_tables` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `X` float NOT NULL DEFAULT 0,
        `Y` float NOT NULL DEFAULT 0,
        `Z` float NOT NULL DEFAULT 0,
        `Rz` float NOT NULL DEFAULT 0,
        `Interior` int(11) NOT NULL DEFAULT 0,
        `Dimension` int(11) NOT NULL DEFAULT 0,
        `Bets` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
        `Date` datetime NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      

      CREATE TABLE IF NOT EXISTS `vrp_casino_wheels` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `X` float NOT NULL DEFAULT 0,
        `Y` float NOT NULL DEFAULT 0,
        `Z` float NOT NULL DEFAULT 0,
        `Rz` float NOT NULL DEFAULT 0,
        `TurnTime` int(11) DEFAULT NULL,
        `MaximumBet` float DEFAULT NULL,
        `Interior` int(11) NOT NULL DEFAULT 0,
        `Dimension` int(11) NOT NULL DEFAULT 0,
        `Date` datetime NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      

      CREATE TABLE IF NOT EXISTS `vrp_character` (
        `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,
        `PosX` float DEFAULT 0,
        `PosY` float DEFAULT 0,
        `PosZ` float DEFAULT 0,
        `Interior` tinyint(3) unsigned DEFAULT 0,
        `Dimension` int(11) NOT NULL DEFAULT 0,
        `UniqueInterior` smallint(5) unsigned DEFAULT 0,
        `Skin` smallint(5) unsigned DEFAULT 0,
        `Health` tinyint(3) unsigned DEFAULT 100,
        `Armor` tinyint(3) unsigned DEFAULT 0,
        `XP` float DEFAULT 0,
        `Karma` int(11) DEFAULT 0,
        `Points` int(11) DEFAULT 0,
        `Money` int(10) unsigned DEFAULT 0,
        `BankAccount` int(10) NOT NULL DEFAULT 0,
        `WantedLevel` tinyint(3) unsigned DEFAULT 0,
        `TutorialStage` tinyint(3) unsigned DEFAULT 0,
        `Job` tinyint(3) unsigned DEFAULT 0,
        `GroupId` int(10) unsigned DEFAULT 0,
        `GroupRank` tinyint(3) unsigned DEFAULT NULL,
        `GroupLoanEnabled` tinyint(1) NOT NULL DEFAULT 1,
        `GroupPermissions` text NOT NULL DEFAULT '[ [ ] ]',
        `DrivingSkill` tinyint(3) unsigned DEFAULT 0,
        `GunSkill` tinyint(4) DEFAULT 0,
        `FlyingSkill` tinyint(3) unsigned DEFAULT 0,
        `SneakingSkill` tinyint(3) unsigned DEFAULT 0,
        `EnduranceSkill` tinyint(3) unsigned DEFAULT 0,
        `Weapons` text DEFAULT NULL,
        `InventoryId` int(10) unsigned DEFAULT 0,
        `GarageType` tinyint(3) unsigned DEFAULT 0,
        `HangarType` int(11) NOT NULL DEFAULT 0,
        `LastGarageEntrance` tinyint(3) unsigned DEFAULT 0,
        `LastHangarEntrance` int(11) NOT NULL DEFAULT 0,
        `SpawnLocation` tinyint(3) unsigned DEFAULT 0,
        `SpawnLocationProperty` varchar(255) NOT NULL DEFAULT '',
        `Collectables` text DEFAULT NULL,
        `WeaponLevel` int(10) DEFAULT 0,
        `VehicleLevel` int(10) DEFAULT 0,
        `SkinLevel` int(10) DEFAULT 0,
        `JobLevel` int(10) DEFAULT 0,
        `HasPilotsLicense` tinyint(1) unsigned DEFAULT 0,
        `HasTheory` tinyint(1) unsigned NOT NULL DEFAULT 0,
        `HasDrivingLicense` tinyint(1) unsigned NOT NULL DEFAULT 0,
        `HasBikeLicense` tinyint(1) unsigned NOT NULL DEFAULT 0,
        `HasTruckLicense` tinyint(1) unsigned NOT NULL DEFAULT 0,
        `PaNote` int(3) NOT NULL DEFAULT 0,
        `Ladder` text DEFAULT NULL,
        `Achievements` text DEFAULT NULL,
        `PlayTime` int(10) unsigned DEFAULT 0,
        `CompanyId` int(11) NOT NULL DEFAULT 0,
        `CompanyRank` int(11) NOT NULL DEFAULT 0,
        `CompanyLoanEnabled` tinyint(1) NOT NULL DEFAULT 1,
        `CompanyPermissions` text NOT NULL DEFAULT '[ [ ] ]',
        `CompanyTraining` tinyint(1) NOT NULL DEFAULT 0,
        `FactionId` int(11) NOT NULL DEFAULT 0,
        `FactionRank` int(11) NOT NULL DEFAULT 0,
        `FactionLoanEnabled` tinyint(1) NOT NULL DEFAULT 1,
        `FactionWeaponEnabled` tinyint(1) NOT NULL DEFAULT 1,
        `FactionPermissions` text NOT NULL DEFAULT '[ [ ] ]',
        `FactionWeaponPermissions` text NOT NULL DEFAULT '[ [ ] ]',
        `FactionActionPermissions` text NOT NULL DEFAULT '[ [ ] ]',
        `FactionTraining` tinyint(1) NOT NULL DEFAULT 0,
        `PhoneNumber` int(11) NOT NULL DEFAULT 0,
        `PrisonTime` int(11) NOT NULL DEFAULT 0,
        `Tour` text DEFAULT NULL,
        `GunBox` text DEFAULT NULL,
        `Bail` int(11) NOT NULL DEFAULT 0,
        `JailTime` int(11) NOT NULL DEFAULT 0,
        `SpawnWithFacSkin` int(11) NOT NULL DEFAULT 1,
        `AltSkin` int(11) NOT NULL DEFAULT 78,
        `IsDead` int(11) NOT NULL DEFAULT 0,
        `TourStep` int(11) NOT NULL DEFAULT 1,
        `AlcoholLevel` float(5,2) NOT NULL DEFAULT 0.00,
        `CJClothes` text NOT NULL DEFAULT '',
        `BetaPlayer` int(1) NOT NULL DEFAULT 0,
        `STVO` varchar(50) DEFAULT '[{"Driving":0,"Bike":0,"Truck":0,"Pilot":0}]',
        `FishingSkill` int(11) DEFAULT NULL,
        `FishingLevel` tinyint(3) DEFAULT NULL,
        `FishSpeciesCaught` text CHARACTER SET koi8r DEFAULT NULL,
        `DeathInJail` int(11) NOT NULL DEFAULT 0,
        `TakeWeaponsOnLogin` int(1) NOT NULL DEFAULT 0,
        `WalkingStyle` int(4) NOT NULL DEFAULT 0,
        `RadioCommunication` text DEFAULT NULL,
        `Injury` text DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE,
        KEY `CompanyId` (`CompanyId`) USING BTREE,
        KEY `GroupId` (`GroupId`) USING BTREE,
        KEY `FactionId` (`FactionId`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      

      CREATE TABLE IF NOT EXISTS `vrp_cheatlog` (
        `UserId` int(10) unsigned NOT NULL,
        `Name` varchar(128) NOT NULL,
        `Severity` tinyint(1) unsigned NOT NULL,
        `Date` datetime DEFAULT NULL ON UPDATE current_timestamp(),
        KEY `UserId` (`UserId`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_client_statistics` (
        `UserId` int(11) NOT NULL,
        `Serial` varchar(32) NOT NULL,
        `GPU` varchar(128) DEFAULT NULL,
        `VRAM` int(11) DEFAULT NULL,
        `Resolution` varchar(16) DEFAULT NULL,
        `Window` tinyint(1) DEFAULT NULL,
        `AllowScreenUpload` tinyint(1) DEFAULT NULL,
        `FPS` int(11) DEFAULT NULL,
        `FreeVRAM` int(11) DEFAULT NULL,
        PRIMARY KEY (`UserId`,`Serial`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_collectables` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `PosX` float DEFAULT NULL,
        `PosY` float DEFAULT NULL,
        `PosZ` float DEFAULT NULL,
        `CollectCount` int(11) DEFAULT 0,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
      
 
      
      CREATE TABLE IF NOT EXISTS `vrp_companies` (
        `Id` int(10) NOT NULL AUTO_INCREMENT,
        `Name_Shorter` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '' COMMENT 'Its even shorter than short',
        `Name_Short` varchar(10) DEFAULT NULL,
        `Name` varchar(50) NOT NULL,
        `Creator` varchar(50) NOT NULL,
        `BankAccount` int(10) DEFAULT NULL,
        `lastNameChange` int(10) NOT NULL,
        `Level` int(10) NOT NULL,
        `Settings` mediumtext NOT NULL,
        `RankLoans` text NOT NULL,
        `RankSkins` text NOT NULL,
        `RankPermissions` text NOT NULL,
        `PhoneNumber` int(11) NOT NULL,
        `Description` text DEFAULT NULL,
        `News` text DEFAULT NULL,
        `ServiceSync` text DEFAULT NULL,
        `ForumGroups` text DEFAULT NULL,
        `Permissions` text DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      

      CREATE TABLE IF NOT EXISTS `vrp_cookie_clicker` (
        `UserId` int(32) NOT NULL,
        `Cookies` bigint(32) NOT NULL DEFAULT 0,
        `Upgrades` longtext NOT NULL DEFAULT '[ { "6": 0, "2": 0, "3": 0, "1": 0, "4": 0, "5": 0 } ]',
        `BanReason` varchar(50) DEFAULT NULL,
        PRIMARY KEY (`UserId`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_deleted_account` (
        `Serial` varchar(32) NOT NULL,
        PRIMARY KEY (`Serial`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_depot` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `OwnerType` varchar(255) DEFAULT NULL,
        `Weapons` text DEFAULT NULL,
        `Items` text DEFAULT NULL,
        `Equipments` text DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_drawcontest` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `UserId` int(11) DEFAULT NULL,
        `DrawData` longtext DEFAULT NULL,
        `VoteData` text DEFAULT NULL,
        `Datetime` datetime DEFAULT NULL,
        `Contest` varchar(255) DEFAULT NULL,
        `Hidden` int(1) NOT NULL DEFAULT 1,
        `Accepted` int(1) DEFAULT NULL,
        `ImageUrl` varchar(255) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_drawcontest_votes` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `DrawId` int(11) DEFAULT NULL,
        `UserId` int(11) DEFAULT NULL,
        `Vote` int(1) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_easter_rabbit_data` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `UserId` int(11) DEFAULT 0,
        `RabbitsFound` int(11) NOT NULL DEFAULT 0,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_factions` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Name_Shorter` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '' COMMENT 'Its even shorter than short',
        `Name_Short` varchar(10) DEFAULT NULL,
        `Name` varchar(255) DEFAULT NULL,
        `Type` varchar(255) DEFAULT NULL,
        `BankAccount` int(11) DEFAULT NULL,
        `Depot` int(11) DEFAULT NULL,
        `RankLoans` text NOT NULL,
        `RankSkins` text NOT NULL,
        `RankWeapons` text NOT NULL,
        `RankPermissions` text NOT NULL,
        `RankActions` text NOT NULL,
        `PhoneNumber` int(11) NOT NULL,
        `active` int(1) NOT NULL,
        `Description` text DEFAULT NULL,
        `News` text DEFAULT NULL,
        `Diplomacy` text DEFAULT NULL,
        `ServiceSync` text DEFAULT NULL,
        `ForumGroups` text DEFAULT NULL,
        `Permissions` text DEFAULT NULL,
        `ChristmasPresents` text DEFAULT '[ [ ] ]' COMMENT 'only for christmas event',
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      

      CREATE TABLE IF NOT EXISTS `vrp_faction_history` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `UserId` int(11) DEFAULT NULL,
        `Faction` int(11) DEFAULT NULL,
        `JoinDate` date DEFAULT NULL,
        `LeaveDate` date DEFAULT NULL,
        `InternalReason` varchar(128) DEFAULT NULL,
        `ExternalReason` varchar(128) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_fires` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Enabled` tinyint(1) NOT NULL DEFAULT 0,
        `Creator` varchar(255) NOT NULL,
        `Name` varchar(255) NOT NULL,
        `Message` varchar(255) NOT NULL DEFAULT '',
        `PosX` float(11,4) NOT NULL DEFAULT 0.0000,
        `PosY` float(11,4) NOT NULL DEFAULT 0.0000,
        `PosZ` float(11,4) NOT NULL DEFAULT 4.0000,
        `Width` int(11) NOT NULL DEFAULT 10,
        `Height` int(11) NOT NULL DEFAULT 10,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
       CREATE TABLE IF NOT EXISTS `vrp_fish_data` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Name_EN` varchar(255) DEFAULT NULL,
        `Name_DE` varchar(255) DEFAULT NULL,
        `Location` varchar(255) DEFAULT NULL,
        `MinLevel` tinyint(3) DEFAULT NULL,
        `Difficulty` int(3) DEFAULT NULL,
        `Behavior` varchar(255) DEFAULT NULL,
        `Season` varchar(255) DEFAULT NULL,
        `Weather` tinyint(1) DEFAULT NULL,
        `Times` varchar(255) DEFAULT NULL,
        `NeedEquipments` varchar(255) DEFAULT NULL,
        `Size` varchar(255) DEFAULT NULL,
        `DefaultPrice` decimal(10,2) DEFAULT NULL,
        `Event` tinyint(3) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
       
      CREATE TABLE IF NOT EXISTS `vrp_fish_statistics` (
        `FishId` int(11) NOT NULL,
        `CaughtCount` int(11) DEFAULT 0,
        `SoldCount` int(11) DEFAULT 0,
        PRIMARY KEY (`FishId`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
 
      
      CREATE TABLE IF NOT EXISTS `vrp_gangwar` (
        `ID` int(11) NOT NULL AUTO_INCREMENT,
        `Name` text NOT NULL,
        `Besitzer` text NOT NULL,
        `x` int(11) NOT NULL,
        `y` int(11) NOT NULL,
        `z` int(11) NOT NULL,
        `cX` int(11) NOT NULL,
        `cY` int(11) NOT NULL,
        `cX2` int(11) NOT NULL,
        `cY2` int(11) NOT NULL,
        `lastAttack` int(11) NOT NULL,
        `Autos` int(1) DEFAULT 4,
        UNIQUE KEY `ID` (`ID`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      

      CREATE TABLE IF NOT EXISTS `vrp_garage` (
        `Id` int(10) NOT NULL AUTO_INCREMENT,
        `HouseId` int(11) DEFAULT NULL,
        `GarageId` int(11) DEFAULT NULL,
        `PosX` float DEFAULT NULL,
        `PosY` float DEFAULT NULL,
        `PosZ` float DEFAULT NULL,
        `RotX` float DEFAULT NULL,
        `RotY` float DEFAULT NULL,
        `RotZ` float DEFAULT NULL,
        PRIMARY KEY (`Id`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
      

      CREATE TABLE IF NOT EXISTS `vrp_ghostdriver` (
        `ID` int(11) NOT NULL AUTO_INCREMENT,
        `MapID` int(11) NOT NULL,
        `PlayerID` int(11) NOT NULL,
        `Data` longtext NOT NULL,
        PRIMARY KEY (`ID`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_groups` (
        `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,
        `Name` varchar(24) DEFAULT NULL,
        `Tag` varchar(5) DEFAULT NULL,
        `Money` int(10) DEFAULT 0,
        `Karma` int(10) DEFAULT 0,
        `lastNameChange` int(10) DEFAULT 0,
        `Type` int(1) NOT NULL DEFAULT 0,
        `RankLoans` mediumtext DEFAULT NULL,
        `RankNames` mediumtext DEFAULT NULL,
        `RankPermissions` text DEFAULT NULL,
        `PhoneNumber` int(11) DEFAULT 0,
        `Level` int(10) NOT NULL DEFAULT 0,
        `VehicleTuning` int(1) NOT NULL DEFAULT 0,
        `News` mediumtext DEFAULT NULL,
        `Description` mediumtext DEFAULT NULL,
        `PlayTime` int(10) DEFAULT 0,
        `Deleted` datetime DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_group_property` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Name` varchar(255) DEFAULT NULL,
        `GroupId` int(11) DEFAULT NULL,
        `Type` int(1) DEFAULT NULL,
        `Price` int(8) DEFAULT NULL,
        `Cam` varchar(255) DEFAULT NULL,
        `Pickup` varchar(255) DEFAULT NULL,
        `InteriorId` int(3) DEFAULT NULL,
        `InteriorSpawn` varchar(255) DEFAULT NULL,
        `open` int(1) NOT NULL,
        `Message` text NOT NULL,
        `DepotId` int(11) DEFAULT NULL,
        `ElevatorData` text DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
       
      CREATE TABLE IF NOT EXISTS `vrp_group_propKeys` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Owner` int(11) NOT NULL,
        `PropId` int(11) NOT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_halloween_quest` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `UserId` int(11) NOT NULL DEFAULT 0,
        `Quest` int(11) NOT NULL DEFAULT 0,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_highscores` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Name` text NOT NULL,
        `Daily` longtext NOT NULL,
        `Weekly` longtext NOT NULL,
        `Monthly` longtext NOT NULL,
        `Yearly` longtext NOT NULL,
        `Global` longtext NOT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_horse_bets` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `UserId` int(11) DEFAULT NULL,
        `Bet` int(11) DEFAULT NULL,
        `Horse` int(1) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_houses` (
        `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,
        `x` float(255,4) DEFAULT NULL,
        `y` float(255,4) DEFAULT NULL,
        `z` float(255,4) DEFAULT NULL,
        `interiorID` tinyint(10) unsigned DEFAULT NULL,
        `keys` text DEFAULT NULL,
        `owner` int(10) unsigned NOT NULL,
        `price` int(10) unsigned DEFAULT NULL,
        `buyPrice` int(10) DEFAULT 0,
        `lockStatus` tinyint(1) unsigned NOT NULL,
        `rentPrice` int(100) unsigned DEFAULT NULL,
        `elements` text DEFAULT NULL,
        `money` int(11) NOT NULL DEFAULT 0,
        `skyscraperID` int(10) NOT NULL DEFAULT 0,
        `salePrice` varchar(50) NOT NULL DEFAULT '[ { "Price": 0 } ]',
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_inventory_items` (
        `ID` int(11) NOT NULL AUTO_INCREMENT,
        `Objektname` varchar(64) NOT NULL,
        `Tasche` varchar(12) DEFAULT NULL,
        `stack_max` int(11) NOT NULL DEFAULT 0,
        `max_items` int(15) NOT NULL DEFAULT 1,
        `Info` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
        `wegwerfen` int(1) DEFAULT 0,
        `Handel` int(1) DEFAULT 0,
        `Icon` varchar(255) DEFAULT NULL,
        `verbraucht` int(1) DEFAULT 0,
        `ModelID` int(6) NOT NULL,
        `MaxWear` int(11) DEFAULT NULL,
        PRIMARY KEY (`ID`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
       
      CREATE TABLE IF NOT EXISTS `vrp_inventory_slots` (
        `id` mediumint(9) NOT NULL AUTO_INCREMENT,
        `PlayerId` int(11) NOT NULL,
        `Objekt` varchar(24) NOT NULL,
        `Platz` int(3) NOT NULL,
        `Menge` int(18) NOT NULL,
        `Tasche` varchar(8) NOT NULL,
        `Value` text NOT NULL,
        `WearLevel` int(11) DEFAULT NULL,
        PRIMARY KEY (`id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_leader_bans` (
        `Id` int(10) NOT NULL AUTO_INCREMENT,
        `PlayerId` int(10) NOT NULL DEFAULT 0,
        `AdminId` int(10) NOT NULL DEFAULT 0,
        `Admins` varchar(255) DEFAULT NULL,
        `CreatedAt` int(11) DEFAULT NULL,
        `ValidUntil` int(11) DEFAULT NULL,
        `Reason` varchar(550) DEFAULT NULL,
        PRIMARY KEY (`Id`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_map_editor_maps` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Name` text DEFAULT NULL,
        `Creator` int(11) DEFAULT NULL,
        `SaveObjects` int(11) DEFAULT NULL,
        `Activated` int(11) DEFAULT NULL,
        `Deactivatable` int(11) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_map_editor_objects` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Type` int(11) DEFAULT NULL,
        `Model` int(11) DEFAULT NULL,
        `PosX` float DEFAULT NULL,
        `PosY` float DEFAULT NULL,
        `PosZ` float DEFAULT NULL,
        `RotX` float DEFAULT NULL,
        `RotY` float DEFAULT NULL,
        `RotZ` float DEFAULT NULL,
        `ScaleX` float DEFAULT NULL,
        `ScaleY` float DEFAULT NULL,
        `ScaleZ` float DEFAULT NULL,
        `Interior` int(11) DEFAULT NULL,
        `Dimension` int(11) DEFAULT NULL,
        `MapId` int(11) DEFAULT NULL,
        `Breakable` int(1) DEFAULT NULL,
        `Collision` int(1) DEFAULT NULL,
        `Doublesided` int(11) DEFAULT NULL,
        `Textures` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
        `LodEnabled` int(11) DEFAULT NULL,
        `Radius` int(11) DEFAULT NULL,
        `Creator` int(11) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_mod_blacklist` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `SHA256` varchar(64) DEFAULT NULL,
        `MD5` varchar(32) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_npc` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `PosX` float NOT NULL,
        `PosY` float NOT NULL,
        `PosZ` float NOT NULL,
        `Rot` float DEFAULT NULL,
        `Names` text DEFAULT NULL,
        `Roles` text DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_offlinemessage` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `PlayerId` int(11) NOT NULL,
        `Text` text NOT NULL,
        `Typ` int(11) NOT NULL,
        `Time` int(11) NOT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_phone_numbers` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Number` int(11) NOT NULL,
        `OwnerType` int(1) NOT NULL,
        `OwnerId` int(11) NOT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
       CREATE TABLE IF NOT EXISTS `vrp_plants` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Type` varchar(255) DEFAULT NULL,
        `Owner` int(11) DEFAULT NULL,
        `PosX` float DEFAULT NULL,
        `PosY` float DEFAULT NULL,
        `PosZ` float DEFAULT NULL,
        `Size` float DEFAULT NULL,
        `planted` int(11) DEFAULT NULL,
        `last_grown` int(11) DEFAULT NULL,
        `last_watered` int(11) DEFAULT NULL,
        `times_earned` int(11) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_player_history` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `UserId` int(11) DEFAULT NULL,
        `InviterId` int(11) DEFAULT 0,
        `UninviterId` int(11) DEFAULT 0,
        `ElementType` varchar(12) DEFAULT NULL,
        `ElementId` int(11) DEFAULT NULL,
        `InternalReason` varchar(128) DEFAULT NULL,
        `ExternalReason` varchar(128) DEFAULT NULL,
        `HighestRank` int(1) DEFAULT 0,
        `UninviteRank` int(1) DEFAULT 0,
        `JoinDate` datetime DEFAULT NULL,
        `LeaveDate` datetime DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_pricepools` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Name` text DEFAULT NULL,
        `EntryPrice` varchar(50) DEFAULT NULL,
        `Prices` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
        `RaffleDate` int(11) DEFAULT NULL,
        `Active` int(11) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_pricepool_entries` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `PoolId` int(11) DEFAULT NULL,
        `UserId` int(11) DEFAULT NULL,
        `Entries` int(11) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE,
        UNIQUE KEY `Identifier` (`PoolId`,`UserId`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_quest` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `UserId` int(11) DEFAULT NULL,
        `QuestId` int(11) DEFAULT NULL,
        `Date` datetime DEFAULT NULL ON UPDATE current_timestamp(),
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_roulette_limits` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `UserId` int(11) NOT NULL DEFAULT 0,
        `Limit` int(11) NOT NULL DEFAULT 0,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_server_bank_accounts` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Name` varchar(32) DEFAULT NULL,
        `BankAccount` int(11) DEFAULT NULL,
        `Description` varchar(255) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE,
        UNIQUE KEY `vrp_server_bank_accounts_Id_uindex` (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_settings` (
        `Id` int(11) NOT NULL,
        `Index` varchar(255) DEFAULT NULL,
        `Value` varchar(255) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      CREATE TABLE IF NOT EXISTS `vrp_shops` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Name` varchar(255) DEFAULT NULL,
        `Type` int(1) NOT NULL,
        `PosX` varchar(255) DEFAULT NULL,
        `PosY` varchar(255) DEFAULT NULL,
        `PosZ` varchar(255) DEFAULT NULL,
        `Rot` int(3) NOT NULL,
        `Dimension` int(11) NOT NULL,
        `RobAble` int(1) NOT NULL,
        `Money` int(11) DEFAULT NULL,
        `LastRob` int(11) DEFAULT NULL,
        `Price` int(11) NOT NULL,
        `Owner` int(11) NOT NULL,
        `Blip` varchar(255) DEFAULT NULL,
        `OwnerType` int(1) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_skribble` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Word` varchar(255) DEFAULT NULL,
        `WordType` tinyint(4) DEFAULT 0,
        `Admin` int(11) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
   
      
      CREATE TABLE IF NOT EXISTS `vrp_skyscrapers` (
        `Id` int(10) NOT NULL AUTO_INCREMENT,
        `PosX` float DEFAULT NULL,
        `PosY` float DEFAULT NULL,
        `PosZ` float DEFAULT NULL,
        `HouseOrder` text DEFAULT NULL,
        PRIMARY KEY (`Id`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_state_evidence` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Type` text NOT NULL,
        `Object` text NOT NULL,
        `Amount` int(11) NOT NULL,
        `UserId` int(11) NOT NULL,
        `Timestamp` int(11) NOT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_static_world_items` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Typ` varchar(255) DEFAULT NULL,
        `PosX` float(10,4) DEFAULT NULL,
        `PosY` float(10,4) DEFAULT NULL,
        `PosZ` float(10,4) DEFAULT NULL,
        `RotationZ` int(11) NOT NULL,
        `Interior` int(11) NOT NULL DEFAULT 0,
        `Dimension` int(11) NOT NULL DEFAULT 0,
        `Value` text DEFAULT NULL,
        `ZoneName` varchar(255) DEFAULT NULL,
        `Admin` int(11) DEFAULT NULL,
        `Date` datetime DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
       
      CREATE TABLE IF NOT EXISTS `vrp_stats` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Kills` int(255) NOT NULL DEFAULT 0,
        `Deaths` int(255) NOT NULL DEFAULT 0,
        `AFK` bigint(20) NOT NULL DEFAULT 0,
        `Driven` int(255) NOT NULL DEFAULT 0,
        `FishCaught` int(255) NOT NULL DEFAULT 0,
        `FishLost` int(255) NOT NULL DEFAULT 0,
        `FishBadCatch` int(255) NOT NULL DEFAULT 0,
        `LegendaryFishCaught` int(255) NOT NULL DEFAULT 0,
        `BoxerLevel` int(255) NOT NULL DEFAULT 0,
        `ThrownObject` int(11) DEFAULT 0,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
       
      CREATE TABLE IF NOT EXISTS `vrp_textureshop` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `UserId` int(11) DEFAULT NULL,
        `Name` varchar(255) DEFAULT NULL,
        `Image` varchar(511) DEFAULT NULL,
        `Model` int(3) DEFAULT NULL,
        `Status` int(11) NOT NULL DEFAULT 0,
        `Public` int(11) NOT NULL,
        `Admin` int(11) NOT NULL DEFAULT 0,
        `Date` datetime DEFAULT NULL,
        `Earnings` int(11) NOT NULL DEFAULT 0,
        `OldImage` varchar(255) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_toptimes` (
        `ID` int(11) NOT NULL AUTO_INCREMENT,
        `Name` text NOT NULL,
        `Times` longtext NOT NULL,
        PRIMARY KEY (`ID`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_tp_locations` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Name` varchar(32) DEFAULT NULL,
        `PosX` float DEFAULT NULL,
        `PosY` float DEFAULT NULL,
        `PosZ` float DEFAULT NULL,
        `Interior` int(10) DEFAULT NULL,
        `Dimension` int(11) DEFAULT NULL,
        `Type` varchar(32) DEFAULT NULL,
        PRIMARY KEY (`Id`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
      
       
      CREATE TABLE IF NOT EXISTS `vrp_turtle_bets` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `UserId` int(11) DEFAULT NULL,
        `Bet` int(11) DEFAULT NULL,
        `TurtleId` int(1) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_user_group_settings` (
        `Id` int(11) unsigned NOT NULL AUTO_INCREMENT,
        `GroupType` int(11) unsigned NOT NULL,
        `GroupId` int(11) unsigned NOT NULL,
        `Category` varchar(255) NOT NULL,
        `Key` varchar(255) NOT NULL,
        `Value` varchar(255) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_vehicles` (
        `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,
        `CreationTime` datetime DEFAULT current_timestamp(),
        `Model` smallint(5) unsigned NOT NULL,
        `OwnerId` int(10) unsigned NOT NULL,
        `OwnerType` tinyint(3) unsigned NOT NULL,
        `PosX` float DEFAULT 0,
        `PosY` float DEFAULT 0,
        `PosZ` float DEFAULT 0,
        `RotX` float DEFAULT 0,
        `RotY` float DEFAULT 0,
        `RotZ` float DEFAULT 0,
        `Interior` int(11) DEFAULT 0,
        `Dimension` int(11) DEFAULT 0,
        `Health` smallint(5) unsigned NOT NULL DEFAULT 1000,
        `Keys` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
        `PositionType` tinyint(3) unsigned NOT NULL DEFAULT 0,
        `Fuel` tinyint(4) NOT NULL DEFAULT 100,
        `Mileage` bigint(20) unsigned NOT NULL DEFAULT 0,
        `Premium` int(10) unsigned NOT NULL DEFAULT 0,
        `TrunkId` int(11) NOT NULL DEFAULT 0,
        `Tunings` varchar(1024) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
        `LastUsed` datetime DEFAULT current_timestamp(),
        `LastDriver` int(10) NOT NULL DEFAULT 0,
        `SalePrice` int(11) NOT NULL DEFAULT 0,
        `RentPrice` int(11) NOT NULL DEFAULT 0,
        `Handling` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
        `ELSPreset` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT '',
        `Deleted` datetime DEFAULT NULL,
        `BuyPrice` int(11) DEFAULT -1,
        `ShopIndex` int(11) DEFAULT -1,
        `TemplateId` int(11) DEFAULT 0,
        `Unregistered` bigint(20) NOT NULL DEFAULT 0,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
       
      CREATE TABLE IF NOT EXISTS `vrp_vehicle_category_data` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Name` text NOT NULL,
        `Tax` int(11) NOT NULL DEFAULT 0,
        `FuelType` text DEFAULT NULL,
        `FuelTankSize` int(11) DEFAULT 100,
        `FuelConsumptionMultiplicator` float(11,1) DEFAULT 1.0,
        `VehicleType` smallint(6) DEFAULT 0,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      

      
      CREATE TABLE IF NOT EXISTS `vrp_vehicle_model_data` (
        `Model` int(11) NOT NULL,
        `Name` text NOT NULL,
        `Category` int(11) DEFAULT NULL,
        `BaseHeight` float DEFAULT NULL,
        `VmaxShopLabel` int(11) NOT NULL DEFAULT 0,
        PRIMARY KEY (`Model`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
      
 
      
      CREATE TABLE IF NOT EXISTS `vrp_vehicle_performance_templates` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Name` text DEFAULT '\'0\'',
        `Model` int(11) DEFAULT 0,
        `Data` text DEFAULT '\'0\'',
        `Creator` int(11) DEFAULT 0,
        `Date` int(20) DEFAULT 0,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_vehicle_shops` (
        `Id` int(3) NOT NULL AUTO_INCREMENT,
        `Name` varchar(50) NOT NULL,
        `Marker` varchar(255) NOT NULL,
        `NPC` varchar(255) NOT NULL,
        `Spawn` varchar(255) DEFAULT NULL,
        `Rect` varchar(255) DEFAULT NULL,
        `Image` varchar(255) DEFAULT NULL,
        `Owner` int(11) NOT NULL,
        `Price` int(11) NOT NULL,
        `Money` int(11) NOT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      

      CREATE TABLE IF NOT EXISTS `vrp_vehicle_shop_veh` (
        `Id` int(5) NOT NULL AUTO_INCREMENT,
        `ShopId` int(50) NOT NULL,
        `Model` int(50) NOT NULL,
        `Name` varchar(999) NOT NULL DEFAULT '',
        `Category` varchar(50) NOT NULL,
        `Level` int(2) NOT NULL,
        `Price` int(11) NOT NULL,
        `X` double NOT NULL,
        `Y` double NOT NULL,
        `Z` double NOT NULL,
        `RX` double NOT NULL,
        `RY` double NOT NULL,
        `RZ` double NOT NULL,
        `TemplateId` int(11) NOT NULL DEFAULT 0,
        `CurrentStock` tinyint(4) NOT NULL DEFAULT 5,
        `MaxStock` tinyint(4) NOT NULL DEFAULT 5,
        PRIMARY KEY (`Id`) USING BTREE,
        KEY `Model` (`Model`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      CREATE TABLE IF NOT EXISTS `vrp_vehicle_trunks` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `ItemSlot1` varchar(255) DEFAULT NULL,
        `ItemSlot2` varchar(255) DEFAULT NULL,
        `ItemSlot3` varchar(255) DEFAULT NULL,
        `ItemSlot4` varchar(255) DEFAULT NULL,
        `WeaponSlot1` varchar(255) DEFAULT NULL,
        `WeaponSlot2` varchar(255) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_warns` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `userId` int(11) DEFAULT NULL,
        `reason` varchar(255) DEFAULT NULL,
        `adminId` int(11) DEFAULT NULL,
        `created` int(11) DEFAULT NULL,
        `expires` int(11) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
      
      
      CREATE TABLE IF NOT EXISTS `vrp_WorldItems` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `Item` text NOT NULL,
        `Model` int(11) NOT NULL,
        `Owner` int(11) NOT NULL,
        `PosX` float NOT NULL,
        `PosY` float NOT NULL,
        `PosZ` float NOT NULL,
        `Rotation` float NOT NULL,
        `Interior` int(11) NOT NULL,
        `Dimension` float NOT NULL,
        `Value` text NOT NULL,
        `Breakable` int(11) NOT NULL,
        `Locked` int(11) NOT NULL,
        `Date` datetime NOT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
      
       CREATE TABLE IF NOT EXISTS `web_highscores` (
        `Id` int(11) NOT NULL AUTO_INCREMENT,
        `UserId` int(11) DEFAULT NULL,
        `Game` varchar(255) DEFAULT NULL,
        `Score` int(11) DEFAULT NULL,
        PRIMARY KEY (`Id`) USING BTREE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
    ]]
end
