Migration_20230707_2258_premium_db = {}

Migration_20230707_2258_premium_db.Database = MigrationManager.DATABASES.PREMIUM;

Migration_20230707_2258_premium_db.Up = function()
    return [[
      CREATE TABLE IF NOT EXISTS `premium_veh` (
        `ID` int(11) NOT NULL AUTO_INCREMENT,
        `Model` int(3) NOT NULL,
        `abgeholt` int(1) NOT NULL,
        `Timestamp_buy` int(11) NOT NULL,
        `Timestamp_abgeholt` int(11) NOT NULL,
        `Preis` int(4) NOT NULL,
        `Soundvan` int(1) DEFAULT 0,
        `UserId` int(4) NOT NULL,
        `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
        `updated_at` timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY (`ID`) USING BTREE
      ) ENGINE=MyISAM DEFAULT CHARSET=latin1;
      
      CREATE TABLE IF NOT EXISTS `user` (
        `ID` int(6) NOT NULL AUTO_INCREMENT,
        `game_id` int(6) NOT NULL,
        `UserId` int(6) NOT NULL,
        `Name` varchar(255) NOT NULL DEFAULT '',
        `Miami_Dollar` float(8,2) NOT NULL DEFAULT 0.00,
        `Spenden_Gesamt` float(10,2) NOT NULL DEFAULT 0.00,
        `premium_easter` int(11) NOT NULL DEFAULT 0,
        `premium` int(1) NOT NULL DEFAULT 0,
        `premium_bis` int(11) NOT NULL DEFAULT 0,
        `premium_car` int(11) NOT NULL DEFAULT 0,
        `BillingId` int(11) NOT NULL DEFAULT 0,
        `Firstname` varchar(255) DEFAULT NULL,
        `Lastname` varchar(255) DEFAULT NULL,
        `EMail` varchar(255) DEFAULT NULL,
        `Adress` varchar(255) DEFAULT NULL,
        `PLZ` varchar(5) DEFAULT NULL,
        `City` varchar(255) DEFAULT NULL,
        `Country` varchar(2) DEFAULT NULL,
        `updated_at` datetime DEFAULT NULL,
        `got_it` int(1) DEFAULT 0,
        PRIMARY KEY (`ID`) USING BTREE
      ) ENGINE=MyISAM DEFAULT CHARSET=latin1;      
    ]]
end
