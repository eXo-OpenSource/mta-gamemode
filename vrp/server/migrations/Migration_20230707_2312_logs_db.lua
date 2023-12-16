Migration_20230707_2312_logs_db = {}

Migration_20230707_2312_logs_db.Database = MigrationManager.DATABASES.LOGS;

Migration_20230707_2312_logs_db.Up = function()
    return [[
        CREATE TABLE `vrpLogs_Actions` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `Action` varchar(255) DEFAULT NULL,
            `UserId` int(11) DEFAULT NULL,
            `GroupId` int(11) DEFAULT NULL,
            `GroupType` varchar(255) DEFAULT NULL,
            `Type` varchar(5) DEFAULT NULL,
            `Date` datetime DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_AdminActionChat` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` text NOT NULL,
            `Type` text NOT NULL,
            `Arg` text NOT NULL,
            `Date` datetime NOT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_AdminActionOther` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` text NOT NULL,
            `Type` text NOT NULL,
            `Arg` text NOT NULL,
            `Date` datetime NOT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_AdminActionPort` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` text NOT NULL,
            `Type` text NOT NULL,
            `Arg` text NOT NULL,
            `Date` datetime NOT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_AdminActionSpect` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` text NOT NULL,
            `Type` text NOT NULL,
            `Arg` text NOT NULL,
            `Date` datetime NOT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_AdminActionVehicle` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) NOT NULL,
            `VehicleId` int(11) NOT NULL,
            `Type` text NOT NULL,
            `Arg` text DEFAULT NULL,
            `Date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE current_timestamp(),
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_AdminDrun` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `Date` datetime DEFAULT NULL,
            `Command` varchar(256) DEFAULT NULL,
            `UserId` int(11) DEFAULT NULL,
            `TargetId` int(11) DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_Advert` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) NOT NULL,
            `Text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
            `Date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_Ammunation` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) DEFAULT NULL,
            `Type` varchar(255) DEFAULT NULL,
            `Weapons` text DEFAULT NULL,
            `Costs` int(11) DEFAULT NULL,
            `Position` varchar(255) DEFAULT NULL,
            `Date` datetime DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE,
            KEY `Type_Date` (`Type`,`Date`) USING BTREE,
            KEY `Date` (`Date`) USING BTREE,
            KEY `Type` (`Type`) USING BTREE,
            KEY `Date_Type` (`Date`,`Type`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_AntiCheatKicks` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) DEFAULT NULL,
            `Serial` varchar(32) NOT NULL,
            `Ip` varchar(64) NOT NULL,
            `Reason` varchar(512) NOT NULL,
            `Date` datetime NOT NULL,
            PRIMARY KEY (`Id`)
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_Arrest` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) DEFAULT NULL,
            `Wanteds` int(1) DEFAULT NULL,
            `Duration` int(11) DEFAULT NULL,
            `PoliceId` int(11) DEFAULT NULL,
            `Bail` int(11) DEFAULT NULL,
            `Date` datetime DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_Casino` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) NOT NULL,
            `WinType` text NOT NULL,
            `Prize` int(11) NOT NULL,
            `Date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_Chat` (
            `ID` int(11) NOT NULL AUTO_INCREMENT,
            `Type` varchar(20) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
            `UserId` int(11) DEFAULT NULL,
            `Text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
            `Heared` text CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
            `Position` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
            `PosX` float DEFAULT NULL,
            `Date` datetime DEFAULT NULL,
            `PosY` float DEFAULT NULL,
            PRIMARY KEY (`ID`) USING BTREE,
            KEY `UserId Index` (`UserId`) USING BTREE,
            KEY `User & Date Index` (`UserId`,`Date`) USING BTREE,
            KEY `Id` (`ID`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_ChatReceivers` (
            `MessageId` int(11) NOT NULL,
            `Receiver` int(11) NOT NULL,
            PRIMARY KEY (`MessageId`,`Receiver`) USING BTREE,
            KEY `vrpLogs_ChatReceivers_vrpLogs_Chat_ID_fk` (`MessageId`) USING BTREE,
            KEY `Receiver` (`Receiver`) USING BTREE,
            CONSTRAINT `vrpLogs_ChatReceivers_vrpLogs_Chat_ID_fk` FOREIGN KEY (`MessageId`) REFERENCES `vrpLogs_Chat` (`ID`)
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_Cinema` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) DEFAULT NULL,
            `HostId` int(11) DEFAULT NULL,
            `LobbyName` varchar(50) DEFAULT NULL,
            `Action` varchar(50) DEFAULT NULL,
            `VideoId` varchar(11) DEFAULT NULL,
            `Date` datetime DEFAULT NULL,
            PRIMARY KEY (`Id`)
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
          
          CREATE TABLE `vrpLogs_ColorCars` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) DEFAULT NULL,
            `LobbyName` varchar(50) DEFAULT NULL,
            `Password` varchar(50) DEFAULT NULL,
            `MaxPlayers` int(2) DEFAULT NULL,
            `Date` datetime DEFAULT NULL,
            PRIMARY KEY (`Id`)
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
          
          CREATE TABLE `vrpLogs_CpAudits` (
            `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
            `user_type` varchar(255) DEFAULT NULL,
            `user_id` bigint(20) unsigned DEFAULT NULL,
            `event` varchar(255) NOT NULL,
            `auditable_type` varchar(255) NOT NULL,
            `auditable_id` bigint(20) unsigned NOT NULL,
            `old_values` text DEFAULT NULL,
            `new_values` text DEFAULT NULL,
            `url` text DEFAULT NULL,
            `ip_address` varchar(45) DEFAULT NULL,
            `user_agent` varchar(1023) DEFAULT NULL,
            `tags` varchar(255) DEFAULT NULL,
            `created_at` timestamp NULL DEFAULT NULL,
            `updated_at` timestamp NULL DEFAULT NULL,
            PRIMARY KEY (`id`) USING BTREE,
            KEY `vrplogs_cpaudits_auditable_type_auditable_id_index` (`auditable_type`,`auditable_id`) USING BTREE,
            KEY `vrplogs_cpaudits_user_id_user_type_index` (`user_id`,`user_type`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
          
          CREATE TABLE `vrpLogs_Damage` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) DEFAULT NULL,
            `TargetId` int(11) DEFAULT NULL,
            `Position` varchar(255) DEFAULT NULL,
            `Weapon` int(3) DEFAULT NULL,
            `Bodypart` int(3) DEFAULT NULL,
            `Damage` float(7,2) DEFAULT NULL,
            `Hits` int(11) NOT NULL,
            `StartTime` text NOT NULL,
            `Date` datetime DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_DrugHarvest` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) NOT NULL,
            `OwnerId` int(11) NOT NULL,
            `Amount` int(11) NOT NULL,
            `Type` varchar(255) NOT NULL,
            `State` int(1) NOT NULL,
            `Date` datetime NOT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_DrugPlants` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) NOT NULL,
            `Type` text NOT NULL,
            `Date` datetime NOT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_DrugUse` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) NOT NULL,
            `Type` text NOT NULL,
            `Date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_Errors` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `Message` varchar(255) DEFAULT NULL,
            `Level` int(1) DEFAULT NULL,
            `File` varchar(255) DEFAULT NULL,
            `Line` int(11) DEFAULT NULL,
            `Date` datetime DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_EventHalloween` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) DEFAULT NULL,
            `Bonus` varchar(255) DEFAULT NULL,
            `Pumpkins` int(11) DEFAULT NULL,
            `Sweets` int(11) DEFAULT NULL,
            `Date` datetime DEFAULT NULL ON UPDATE current_timestamp(),
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_FireManager` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `FireId` int(11) DEFAULT NULL,
            `Duration` int(11) DEFAULT NULL,
            `Players` varchar(255) DEFAULT NULL,
            `MoneyForFaction` int(11) DEFAULT NULL,
            `Success` tinyint(1) DEFAULT NULL,
            `Date` datetime DEFAULT NULL ON UPDATE current_timestamp(),
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_GameStats` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `Game` varchar(255) DEFAULT NULL,
            `Incoming` bigint(255) DEFAULT NULL,
            `Outgoing` bigint(255) DEFAULT NULL,
            `Played` int(11) DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_Gangwar` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `Gebiet` text NOT NULL,
            `Angreifer` text NOT NULL,
            `Besitzer` text NOT NULL,
            `StartZeit` int(11) NOT NULL,
            `EndZeit` int(11) NOT NULL,
            `Gewinner` text NOT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_GangwarDebugLog` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `Warning` text NOT NULL,
            `Name` text NOT NULL,
            `Date` datetime NOT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_GangwarStatistics` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) NOT NULL,
            `Type` text NOT NULL,
            `Amount` int(11) NOT NULL,
            `Date` datetime NOT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Diese Tabelle beinhaltet Damage und Kills und MVPs in einzelnen Datensätzen. Nützlich um den Verlauf des Damages zu sehen.';
          
          CREATE TABLE `vrpLogs_GangwarTopList` (
            `UserId` int(11) NOT NULL,
            `Name` text NOT NULL,
            `Damage` int(11) NOT NULL,
            `Kills` int(11) NOT NULL,
            `MVP` int(11) NOT NULL,
            PRIMARY KEY (`UserId`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Diese Tabelle sammelt den Damage und die Kills in _EINEM_ Datensatz (dient zur besseren Darstellung bei Top-Listen)';
          
          CREATE TABLE `vrpLogs_GroupImmo` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `Aktion` text NOT NULL,
            `GroupId` int(11) NOT NULL,
            `ImmoId` int(11) NOT NULL,
            `Date` datetime NOT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_Groups` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) DEFAULT NULL,
            `GroupType` varchar(255) DEFAULT NULL,
            `GroupId` int(11) DEFAULT NULL,
            `Category` varchar(255) DEFAULT NULL,
            `Description` varchar(255) DEFAULT NULL,
            `Timestamp` int(11) DEFAULT NULL,
            `Date` datetime DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE,
            KEY `GroupType_GroupId` (`GroupType`,`GroupId`) USING BTREE,
            KEY `Timestamp` (`Timestamp`) USING BTREE,
            KEY `Date` (`Date`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_Heal` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) DEFAULT NULL,
            `Heal` int(4) DEFAULT NULL,
            `Reason` varchar(255) DEFAULT NULL,
            `Position` varchar(255) DEFAULT NULL,
            `Date` datetime DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_House` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) NOT NULL,
            `Aktion` text NOT NULL,
            `HouseId` int(11) NOT NULL,
            `Date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_HousesFreed` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `Date` datetime DEFAULT NULL,
            `UserID` int(11) DEFAULT NULL,
            `HouseID` int(11) DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_ItemDepot` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) DEFAULT NULL,
            `DepotId` int(11) DEFAULT NULL,
            `Item` varchar(255) DEFAULT NULL,
            `Amount` int(11) DEFAULT NULL,
            `Date` datetime DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_ItemPlace` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `PlayerId` int(11) NOT NULL,
            `Item` text NOT NULL,
            `Pos` text NOT NULL,
            `Date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_ItemTrade` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `GivingId` int(11) NOT NULL,
            `ReceivingId` int(11) NOT NULL,
            `Item` text NOT NULL,
            `Price` int(11) NOT NULL,
            `Amount` int(11) DEFAULT NULL,
            `Date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_Job` (
            `ID` int(11) NOT NULL AUTO_INCREMENT,
            `UserID` int(11) DEFAULT NULL,
            `Job` varchar(45) DEFAULT NULL,
            `Duration` int(11) DEFAULT NULL,
            `Earned` int(11) NOT NULL DEFAULT 0,
            `Bonus` int(11) NOT NULL DEFAULT 0,
            `Vehicle` int(11) NOT NULL,
            `Distance` int(11) NOT NULL,
            `Points` int(11) NOT NULL,
            `Amount` int(11) NOT NULL,
            `Date` datetime DEFAULT NULL,
            PRIMARY KEY (`ID`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_Kills` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) DEFAULT NULL,
            `TargetId` int(11) DEFAULT NULL,
            `Position` varchar(255) DEFAULT NULL,
            `Weapon` int(3) DEFAULT NULL,
            `RangeBetween` float(5,2) DEFAULT NULL,
            `Date` datetime DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE,
            KEY `UserId` (`UserId`) USING BTREE,
            KEY `TargetId` (`TargetId`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_Login` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) NOT NULL DEFAULT 0,
            `Name` varchar(64) NOT NULL DEFAULT '',
            `Type` varchar(64) NOT NULL DEFAULT '',
            `Ip` varchar(64) NOT NULL DEFAULT '',
            `Serial` varchar(32) NOT NULL DEFAULT '',
            `Date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`Id`) USING BTREE,
            KEY `Ip` (`Ip`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_MagicButton` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) NOT NULL,
            `UpdatedAt` datetime NOT NULL,
            `CreatedAt` datetime NOT NULL,
            PRIMARY KEY (`Id`)
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_Money` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `ElementType` varchar(100) DEFAULT NULL,
            `ElementId` int(11) DEFAULT NULL,
            `Money` int(11) DEFAULT NULL,
            `Reason` varchar(255) DEFAULT NULL,
            `BankAccount` int(1) DEFAULT NULL,
            `Date` datetime DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
          
          CREATE TABLE `vrpLogs_MoneyNew` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `FromId` int(11) DEFAULT NULL,
            `FromType` int(11) DEFAULT NULL,
            `FromBank` int(11) DEFAULT NULL,
            `ToId` int(11) DEFAULT NULL,
            `ToType` int(11) DEFAULT NULL,
            `ToBank` int(11) DEFAULT NULL,
            `Amount` bigint(20) DEFAULT NULL,
            `Reason` varchar(255) DEFAULT NULL,
            `Category` varchar(32) DEFAULT NULL,
            `Subcategory` varchar(32) DEFAULT NULL,
            `Date` datetime DEFAULT NULL ON UPDATE current_timestamp(),
            `DateFormatted` date GENERATED ALWAYS AS (cast(`Date` as date)) STORED,
            PRIMARY KEY (`Id`) USING BTREE,
            KEY `toType_toId` (`ToType`,`ToId`) USING BTREE,
            KEY `fromType_fromId` (`FromType`,`FromId`) USING BTREE,
            KEY `Date` (`Date`) USING BTREE,
            KEY `ToId` (`ToId`) USING BTREE,
            KEY `FromId` (`FromId`) USING BTREE,
            KEY `ToBank` (`ToBank`) USING BTREE,
            KEY `FromBank` (`FromBank`) USING BTREE,
            KEY `ToBank_2` (`ToBank`,`DateFormatted`),
            KEY `FromBank_2` (`FromBank`,`DateFormatted`),
            KEY `FromType_ToType` (`FromType`,`ToType`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_PlayhousePlayers` (
            `UserId` int(11) NOT NULL,
            `Amount` int(11) DEFAULT NULL,
            PRIMARY KEY (`UserId`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_PricePool` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `PricePoolId` int(11) DEFAULT NULL,
            `UserId` int(11) DEFAULT NULL,
            `Entries` int(11) DEFAULT NULL,
            `EntryPrice` varchar(50) DEFAULT NULL,
            `Price` varchar(50) DEFAULT NULL,
            `Date` datetime DEFAULT NULL,
            PRIMARY KEY (`Id`)
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_Punish` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) DEFAULT NULL,
            `AdminId` int(11) DEFAULT NULL,
            `Type` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
            `Reason` varchar(255) DEFAULT NULL,
            `InternalMessage` text CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
            `Duration` int(255) DEFAULT NULL,
            `Date` datetime DEFAULT NULL,
            `DeletedAt` datetime DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
          
          CREATE TABLE `vrpLogs_PunishLog` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `PunishId` int(11) NOT NULL,
            `AdminId` int(11) NOT NULL,
            `InternalMessage` text DEFAULT NULL,
            `Duration` int(11) DEFAULT NULL,
            `Reason` text DEFAULT NULL,
            `DeletedAt` datetime DEFAULT NULL,
            `InternalMessagePrev` text DEFAULT NULL,
            `DurationPrev` int(11) DEFAULT NULL,
            `ReasonPrev` text DEFAULT NULL,
            `DeletedAtPrev` datetime DEFAULT NULL,
            `Date` datetime DEFAULT NULL,
            PRIMARY KEY (`Id`)
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_Raid` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `Attacker` int(255) DEFAULT NULL,
            `Target` int(255) DEFAULT NULL,
            `Money` varchar(255) DEFAULT NULL,
            `Success` int(1) NOT NULL,
            `Faction` int(11) DEFAULT NULL,
            `Position` varchar(255) DEFAULT NULL,
            `Date` datetime DEFAULT NULL ON UPDATE current_timestamp(),
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_RentedVehicles` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `GroupId` int(11) NOT NULL,
            `UserId` int(11) NOT NULL,
            `VehicleId` int(11) NOT NULL,
            `Rental` int(11) NOT NULL,
            `Duration` int(11) NOT NULL,
            `Date` datetime NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`Id`)
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
          
          CREATE TABLE `vrpLogs_Roulette` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) NOT NULL,
            `Bet` int(11) NOT NULL,
            `Bets` text NOT NULL,
            `WinningNumber` int(11) NOT NULL,
            `WonAmount` int(11) NOT NULL,
            `HighStake` tinyint(1) NOT NULL DEFAULT 0,
            `Date` datetime NOT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_VehicleDeletion` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) DEFAULT NULL,
            `Model` int(3) DEFAULT NULL,
            `Admin` int(255) DEFAULT NULL,
            `Position` varchar(255) DEFAULT NULL,
            `Reason` varchar(255) DEFAULT NULL,
            `Date` datetime DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_VehicleTow` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `PlayerId` int(11) NOT NULL,
            `OwnerId` int(11) NOT NULL,
            `VehicleId` int(11) NOT NULL,
            `Date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_VehicleTrade` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `SellerId` int(11) DEFAULT NULL,
            `BuyerId` int(11) DEFAULT NULL,
            `VehicleId` int(11) DEFAULT NULL,
            `Trunk` text DEFAULT NULL,
            `Price` int(10) DEFAULT NULL,
            `Date` datetime DEFAULT NULL ON UPDATE current_timestamp(),
            `TradeType` varchar(255) DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_VehicleTrunk` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `UserId` int(11) DEFAULT NULL,
            `Trunk` int(11) DEFAULT NULL,
            `Action` varchar(32) DEFAULT NULL,
            `ItemType` varchar(32) DEFAULT NULL,
            `Item` varchar(255) DEFAULT NULL,
            `Amount` int(11) DEFAULT NULL,
            `Slot` int(11) DEFAULT NULL,
            `Date` datetime DEFAULT current_timestamp(),
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_Vehicles` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `Date` datetime DEFAULT NULL,
            `UserId` int(11) DEFAULT NULL,
            `ElementId` int(11) DEFAULT NULL,
            `OwnerId` int(11) DEFAULT NULL,
            `OwnerType` varchar(32) DEFAULT NULL,
            `Model` int(11) DEFAULT NULL,
            `Action` varchar(64) DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_WorldItemLog` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `Action` text NOT NULL,
            `UserId` int(11) NOT NULL,
            `ItemId` int(11) NOT NULL,
            `Date` datetime NOT NULL,
            `Type` varchar(32) DEFAULT NULL,
            `Zone1` varchar(64) DEFAULT NULL,
            `Zone2` varchar(64) DEFAULT NULL,
            `OwnerId` int(11) DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
          
          CREATE TABLE `vrpLogs_fishCaught` (
            `ID` int(11) NOT NULL AUTO_INCREMENT,
            `PlayerId` int(11) DEFAULT NULL,
            `FishName` varchar(255) DEFAULT NULL,
            `FishSize` smallint(6) DEFAULT NULL,
            `Location` varchar(255) DEFAULT NULL,
            `Date` datetime DEFAULT NULL,
            `FishId` int(11) DEFAULT NULL,
            PRIMARY KEY (`ID`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_fishTrade` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `PlayerId` int(11) DEFAULT NULL,
            `ReceivingId` int(11) DEFAULT NULL,
            `FishName` varchar(255) DEFAULT NULL,
            `FishSize` int(11) DEFAULT NULL,
            `Price` int(11) DEFAULT NULL,
            `RareMultiplicator` int(11) DEFAULT NULL,
            `Date` datetime DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          
          CREATE TABLE `vrpLogs_propertiesfreed` (
            `Id` int(11) NOT NULL AUTO_INCREMENT,
            `GroupId` int(11) DEFAULT 0,
            `PropertyId` int(11) DEFAULT 0,
            `Date` date DEFAULT NULL,
            PRIMARY KEY (`Id`) USING BTREE
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
    ]]
end
