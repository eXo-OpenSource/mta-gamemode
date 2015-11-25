-- phpMyAdmin SQL Dump
-- version 4.4.12
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Erstellungszeit: 25. Nov 2015 um 17:40
-- Server-Version: 5.6.25
-- PHP-Version: 5.6.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `vrp_local`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `forum_ts3auth`
--

CREATE TABLE IF NOT EXISTS `forum_ts3auth` (
  `boardId` int(10) unsigned NOT NULL,
  `authKey` varchar(6) NOT NULL,
  `ts3uid` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vrp_account`
--

CREATE TABLE IF NOT EXISTS `vrp_account` (
  `Id` int(10) unsigned NOT NULL,
  `Name` varchar(50) DEFAULT NULL,
  `Salt` varchar(32) DEFAULT NULL,
  `Password` varchar(64) DEFAULT NULL,
  `Rank` tinyint(3) DEFAULT NULL,
  `LastSerial` varchar(32) DEFAULT NULL,
  `LastLogin` datetime DEFAULT NULL,
  `EMail` varchar(50) DEFAULT NULL
) ENGINE=MyISAM AUTO_INCREMENT=30 DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `vrp_account`
--

INSERT INTO `vrp_account` (`Id`, `Name`, `Salt`, `Password`, `Rank`, `LastSerial`, `LastLogin`, `EMail`) VALUES
(17, 'false', '7365D32189ECBDD8FC818EF537F79BA1', 'AF5A64ED5E8461D824B94F97F006854046A55F27D812BC0F0D452DA872F35DF6', 5, '368989309EB012227161093646E56843', '2015-06-06 13:23:11', NULL),
(1, 'Jusonex', '79C501C2830570204C6915BFBDEA9B2E', 'EAAD8B87E27E8258E0D550F6F6816675C65A5748FCC72D880E0F68502E01FD2C', 5, 'C4586E3449E6ECC0FA1FD8B269E2A873', '2015-06-06 13:10:27', NULL),
(2, 'Doneasty', '', '994FCB227681CFD6CA119F0A30553FCA590AECF5EA2617C9E4AF934198B85956', 4, '239A5FCD692C6C4D8ABD55F3C00E4D94', '2015-06-06 13:24:04', NULL),
(3, 'StiviK', '', 'DAF9854A6D826EA2B31E2336ECD0875836E4EFAD6CA23349BE083E68FE34A05E', 5, '71B947A4FF2929B905F4EE55B9182F02', '2015-11-25 17:39:16', 'stivik@v-roleplay.net'),
(18, 'Toxsi', '', '530AF54CE47C502654D30C74A6B4CAF5861DB3AF5D307187A8F99C150D4BCF4D', 2, '28D715400EC6C9F57DEB328D003ADA43', '2015-05-19 14:37:28', NULL),
(19, 'sbx320', '', '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92', 5, NULL, NULL, NULL),
(20, 'Johnny', '', 'C549ADDC80367E17FD46B5B6A094EE7F9958D5C92FBA35F519E64C5A4304DDE6', 2, 'F4274B79FE188EFA7C4680896AB9F282', '2015-06-06 00:58:39', NULL),
(21, 'Gibaex', '', 'C549ADDC80367E17FD46B5B6A094EE7F9958D5C92FBA35F519E64C5A4304DDE6', 0, 'F4274B79FE188EFA7C4680896AB9F282', '2015-06-05 20:06:02', NULL),
(22, 'Sarcasm', '', '5994471ABB01112AFCC18159F6CC74B4F511B99806DA59B3CAF5A9C173CACFC5', 3, 'D43F3EA89CAFB26F6AA8EE0EDA339A53', '2015-04-07 18:53:11', NULL),
(23, 'TestUser4', '79C501C2830570204C6915BFBDEA9B2E', 'EAAD8B87E27E8258E0D550F6F6816675C65A5748FCC72D880E0F68502E01FD2C', 0, '', NULL, 'jusonex@v-roleplay.net'),
(24, 'TestUser5', '5CC91EB66F1963FC8DBAC6D47935151F', '3286AFDBFBB08817A88C6CC58767E281199CBA11E17DF5E4C7D0369C57ED81E3', 0, 'C4586E3449E6ECC0FA1FD8B269E2A873', '2015-04-20 14:35:49', 'doneasty@web.de'),
(25, 'Poof', 'EAAB5A103F24EA75A8AD87251652F167', '4CB0045D6E15D2376A9EAFB85CC4D861961CD0076EC244F28B884944779C2262', 0, 'F885F6BBB6A49FA4BD3D7EBC6C78CB84', '2015-05-18 21:21:31', 'poof@sbx320.net'),
(26, 'Yetii', '8CD338D51246B23F935A36E76EFDDB12', '5C49A89AD8F6AD54929308DB3A2947EAD9E48A20A526742FC223DC9FFFE0E4FB', 0, 'C8631CD688CD35A3192BA7F5243BAD62', '2015-06-06 12:39:51', 'yetistone12@gmx.de'),
(27, 'HEXASHOT', '3FE6FB34111C2DC08B17EB9DA9A85313', 'AD09CBECB7166C4C071987A86BD3183A1C17A3CDFE5DD0B29EB3D1BBD4D4DE3E', 0, 'A93331720EDD7DED935B4516E79F0284', '2015-06-06 12:46:21', 'hexashot@web.de'),
(28, 'Simpsons183', '27B2D0A6CBD72146E97C376F68BADD23', '5FB5EFE66EC63D0807C45A5EA55B51868BE905D1394DD52E2D127ABF985B2FE6', 0, '5C61D77DDB092AF8FAE6A7FA7AA55C02', '2015-06-06 12:30:30', 'albandietze1999@gmx.de'),
(29, 'Harrikan', 'DC186DB031FDF13683B3509108392A29', 'AFF556A2CE7979F5DBA736B93B5876AB56182896A0B9EC95B77377C48AFF81E8', 0, '1488BCD6D847073EA7D6D45435ED4E42', '2015-06-06 10:57:34', 'harrikan@web.de');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vrp_achievements`
--

CREATE TABLE IF NOT EXISTS `vrp_achievements` (
  `id` int(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `desc` varchar(255) DEFAULT NULL,
  `img` varchar(255) DEFAULT NULL,
  `exp` int(11) DEFAULT NULL
) ENGINE=MyISAM AUTO_INCREMENT=52 DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `vrp_achievements`
--

INSERT INTO `vrp_achievements` (`id`, `name`, `desc`, `img`, `exp`) VALUES
(1, 'Evil Geddow Kid', '"Man wird zum ersten mal von gut auf böse gestuft"', 'none', 5),
(2, 'Good Guy', '"Man wird zum ersten mal von böse auf gut gestuft"', 'none', 5),
(3, 'Developerschelle', 'Man wird von einem Admin mit dem Rang "Developer" getötet', 'none', 5),
(4, 'Giving Air', '"Man drückt einen Anruf weg"', 'none', 5),
(5, 'Wandervogel', '"Man hat alle Jobs durch"', 'none', 5),
(6, 'Faust Gottes', 'Man wird von Doneasty geschlagen ;)', 'none', 5),
(7, 'Boss aus dem Gettho', '"Man gründet eine Gang"', 'none', 5),
(8, 'Kriminell und breit gebaut', '"Man tritt einer Gang bei"', 'none', 5),
(9, 'Gutes blaues Männchen', 'Man wird Polizist', 'none', 5),
(10, 'Traumland', '"Man ist völlig bekifft"', 'none', 5),
(11, 'Harter Holzfäller', 'Man wird Holzfäller', 'none', 5),
(12, 'Meister des Mülls', 'Man wird Müllfahrer', 'none', 5),
(13, 'Mülllehrling', 'Man wird Straßenkehrer', 'none', 5),
(14, 'Meister der Diebe', '"Man hat einen Bankraub überstanden"', 'none', 5),
(15, 'Kleinkrimineller', '"Man hat einen Laden überfallen"', 'none', 5),
(16, 'Vettel für Arme', '"Man hat ein Straßenrennen gewonnen"', 'none', 5),
(17, 'Meiner ist 15 Meter lang', 'Man wird Busfahrer', 'none', 5),
(18, 'Mülltonnen Kicker', '"Man tritt eine Mülltonne"', 'none', 5),
(19, 'Süßigkeiten Dieb', 'Man raubt einen Automaten aus', 'none', 5),
(20, 'Old McDonnald has a farm', 'Man wird Farmer', 'none', 5),
(21, 'Millionär', 'Man hat 1.000.000$ an Geld', 'none', 250),
(22, 'Freak Collector', '"Man hat alle Freaks durch"', 'none', 5),
(23, 'Check my new outfit', '"Man hat seinen Skin gewechselt"', 'none', 5),
(24, 'Tales of Johnny Walker', '"Man telefoniert mit Johnny"', 'none', 5),
(25, 'Die macht mit dir ist, junger ..Name..', '"Man hat Yoda im Kampf besiegt"', 'none', 5),
(26, 'Hartzer', '"Man kündigt seinen Job"', 'none', 5),
(27, 'Wirtschaftsguru', '"Man kauft eine Firma"', 'none', 5),
(28, 'Karrieremensch', '"Man tritt einer Firma bei"', 'none', 5),
(29, 'Nicht den Kuchen klauen', '"Man berührt den Kuchen auf dem Jusonexschen Platz"', 'none', 5),
(30, 'H4cks0r', '"Man hat den Knast gehackt"', 'none', 5),
(31, 'Storys from the Block', 'Man landet im Knast', 'none', 5),
(32, 'Blutsbrüder', '"Man holt ein Gangmitglied aus dem Knast"', 'none', 5),
(33, 'Geschäftsmann', '"Man handelt"', 'none', 5),
(34, 'Grundbesitzer', '"Man besitzt ein Haus"', 'none', 5),
(35, 'Born to be wild', '"Man besitzt ein Motorrad"', 'none', 5),
(36, 'Das ertse Auto', '"Man besitzt ein Auto"', 'none', 5),
(37, 'Geboren um zu sterben', '"Man stirbt"', 'none', 5),
(38, 'Like a Sir', '"Man klickt Sarcasm an"', 'none', 5),
(39, 'Carsten Stahl', 'Man wird von Revelse verprügelt oder von seinem Jeep (Huntley) überfahren', 'none', 5),
(40, 'Rich as fuck', 'Man besitzt 10.000.000 $', 'none', 1000),
(41, 'Giving Air-sbx320 Edition', '"Man wird von sbx320 weggedrückt"', 'none', 5),
(42, 'Get rich', '"Man spielt Lotto"', 'none', 5),
(43, 'Baumtänzer', '"Man führt die Animation "dance 3" in der Nähe eines Baums aus"', 'none', 5),
(44, 'Fuck the Police', '"Man tötet einen Polizisten"', 'none', 5),
(45, 'Paragraph 31', 'Man bekommt ein Wanted', 'none', 5),
(46, 'Interpol.com', 'Man hat 6 Wanteds', 'none', 5),
(47, 'Lausbubenjäger', 'Man knastet jemanden unter 4 Sterne ein', 'none', 5),
(48, 'Sondereinheit', 'Man knastet jemanden mit über 4 Sternen ein', 'none', 5),
(49, 'Le Easteregg', 'Such Text. So Easteregg. Wow.', 'none', 25);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vrp_bank_statements`
--

CREATE TABLE IF NOT EXISTS `vrp_bank_statements` (
  `UserId` int(10) DEFAULT NULL,
  `Type` tinyint(4) DEFAULT NULL,
  `Amount` int(11) DEFAULT NULL,
  `Date` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `vrp_bank_statements`
--

INSERT INTO `vrp_bank_statements` (`UserId`, `Type`, `Amount`, `Date`) VALUES
(3, 4, 5245, '2015-02-03 18:01:09'),
(3, 3, 5245, '2015-02-03 18:01:15'),
(3, 4, 7468, '2015-02-05 16:10:38'),
(3, 4, 38521, '2015-02-07 14:25:33'),
(3, 4, 93213, '2015-02-07 14:25:45'),
(3, 3, 139202, '2015-02-07 14:25:49'),
(3, 4, 30455, '2015-02-07 14:25:53'),
(2, 4, 12, '2015-02-21 21:42:00'),
(3, 1, 1, '2015-02-21 21:42:02'),
(2, 2, 1, '2015-02-21 21:42:02'),
(3, 1, 1, '2015-02-21 21:42:04'),
(2, 2, 1, '2015-02-21 21:42:04'),
(3, 1, 1, '2015-02-21 21:42:04'),
(2, 2, 1, '2015-02-21 21:42:04'),
(3, 1, 1, '2015-02-21 21:42:04'),
(2, 2, 1, '2015-02-21 21:42:04'),
(3, 1, 1, '2015-02-21 21:42:04'),
(2, 2, 1, '2015-02-21 21:42:04'),
(3, 1, 1, '2015-02-21 21:42:05'),
(2, 2, 1, '2015-02-21 21:42:05'),
(3, 1, 1, '2015-02-21 21:42:05'),
(2, 2, 1, '2015-02-21 21:42:05'),
(3, 1, 1, '2015-02-21 21:42:05'),
(2, 2, 1, '2015-02-21 21:42:05'),
(3, 1, 1, '2015-02-21 21:42:05'),
(2, 2, 1, '2015-02-21 21:42:05'),
(3, 1, 1, '2015-02-21 21:42:05'),
(2, 2, 1, '2015-02-21 21:42:05'),
(3, 1, 1, '2015-02-21 21:42:06'),
(2, 2, 1, '2015-02-21 21:42:06'),
(2, 4, 111572, '2015-02-21 22:24:04'),
(3, 1, 12, '2015-02-22 11:35:41'),
(2, 2, 12, '2015-02-22 11:35:41'),
(3, 1, 12, '2015-02-22 11:35:42'),
(2, 2, 12, '2015-02-22 11:35:42'),
(3, 1, 12, '2015-02-22 11:35:42'),
(2, 2, 12, '2015-02-22 11:35:42'),
(3, 1, 12, '2015-02-22 11:35:42'),
(2, 2, 12, '2015-02-22 11:35:42'),
(3, 1, 12, '2015-02-22 11:35:42'),
(2, 2, 12, '2015-02-22 11:35:42'),
(3, 1, 12, '2015-02-22 11:35:43'),
(2, 2, 12, '2015-02-22 11:35:43'),
(3, 1, 12, '2015-02-22 11:35:43'),
(2, 2, 12, '2015-02-22 11:35:43'),
(3, 1, 12, '2015-02-22 11:35:43'),
(2, 2, 12, '2015-02-22 11:35:43'),
(3, 1, 12, '2015-02-22 11:35:43'),
(2, 2, 12, '2015-02-22 11:35:43'),
(3, 1, 12, '2015-02-22 11:35:43'),
(2, 2, 12, '2015-02-22 11:35:43'),
(2, 4, 2200, '2015-03-14 19:05:57'),
(2, 3, 11000, '2015-03-15 00:13:38'),
(2, 4, 3000, '2015-03-15 11:46:37'),
(2, 3, 100000, '2015-03-15 11:50:33'),
(2, 4, 70000, '2015-03-15 13:08:45'),
(2, 4, 5000, '2015-03-15 18:30:40'),
(2, 3, 20000, '2015-03-15 18:31:16'),
(2, 4, 20000, '2015-03-15 20:25:46'),
(2, 4, 1942386, '2015-03-16 19:44:20'),
(3, 4, 31224525, '2015-03-16 19:44:31'),
(20, 4, 17000, '2015-03-17 18:26:57'),
(20, 1, 300000, '2015-03-17 18:58:46'),
(2, 2, 300000, '2015-03-17 18:58:46'),
(2, 3, 120000, '2015-03-17 18:58:56'),
(20, 3, 300000, '2015-03-17 19:01:14'),
(20, 1, 400000, '2015-03-17 19:14:14'),
(2, 2, 400000, '2015-03-17 19:14:14'),
(20, 3, 300000, '2015-03-17 19:14:52'),
(2, 3, 250000, '2015-03-17 19:21:42'),
(22, 3, 5000, '2015-04-01 16:50:13'),
(18, 4, 150500, '2015-04-03 18:57:26'),
(3, 4, 1865875, '2015-04-22 12:08:35'),
(3, 1, 1, '2015-04-22 12:08:41'),
(3, 2, 1, '2015-04-22 12:08:41'),
(3, 1, 1, '2015-04-22 12:08:43'),
(3, 2, 1, '2015-04-22 12:08:43'),
(3, 1, 1, '2015-04-22 12:08:43'),
(3, 2, 1, '2015-04-22 12:08:43'),
(3, 1, 1, '2015-04-22 12:08:44'),
(3, 2, 1, '2015-04-22 12:08:44'),
(3, 1, 1, '2015-04-22 12:08:44'),
(3, 2, 1, '2015-04-22 12:08:44'),
(3, 1, 1, '2015-04-22 12:08:44'),
(3, 2, 1, '2015-04-22 12:08:44'),
(3, 1, 1, '2015-04-22 12:08:44'),
(3, 2, 1, '2015-04-22 12:08:44'),
(3, 1, 1, '2015-04-22 12:08:44'),
(3, 2, 1, '2015-04-22 12:08:45'),
(3, 3, 1865875, '2015-04-23 17:10:48'),
(3, 4, 9999999, '2015-04-23 17:11:11'),
(3, 4, 1, '2015-04-23 17:11:19'),
(3, 4, 1, '2015-04-23 17:11:57'),
(3, 3, 1, '2015-04-23 17:12:39'),
(3, 4, 1, '2015-04-23 17:12:47'),
(3, 3, 1, '2015-04-23 17:14:07'),
(3, 4, 1, '2015-04-23 17:14:09'),
(3, 3, 1, '2015-04-23 17:14:41'),
(3, 4, 1, '2015-04-23 17:14:44'),
(3, 3, 10000000, '2015-04-23 17:28:32'),
(3, 3, 1, '2015-04-23 17:28:40'),
(3, 4, 100000, '2015-04-23 17:28:46'),
(3, 3, 100000, '2015-04-23 17:29:09'),
(3, 4, 1000000, '2015-04-23 17:29:16'),
(3, 3, 10000, '2015-04-23 17:29:47'),
(3, 3, 990000, '2015-04-23 17:29:52'),
(3, 4, 1000000, '2015-04-23 17:29:59'),
(3, 4, 9000000, '2015-04-23 17:30:10'),
(3, 3, 3001, '2015-04-23 17:35:15'),
(3, 4, 6002, '2015-04-23 17:35:21'),
(1, 4, 5000, '2015-05-14 00:05:04'),
(1, 4, 10000, '2015-05-14 00:05:11'),
(2, 4, 100000, '2015-05-25 14:59:02'),
(2, 3, 1000000, '2015-06-05 20:01:31'),
(26, 4, 758, '2015-06-05 20:48:51'),
(27, 4, 322, '2015-06-05 20:48:53'),
(28, 4, 947, '2015-06-05 20:48:59'),
(26, 4, 66909, '2015-06-05 21:20:33'),
(26, 3, 10000, '2015-06-05 21:50:27'),
(2, 4, 2900, '2015-06-06 10:56:56'),
(27, 4, 5148, '2015-06-06 13:11:23');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vrp_bans`
--

CREATE TABLE IF NOT EXISTS `vrp_bans` (
  `serial` varchar(32) DEFAULT NULL,
  `author` int(10) unsigned DEFAULT NULL,
  `reason` text,
  `expires` int(10) unsigned DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vrp_character`
--

CREATE TABLE IF NOT EXISTS `vrp_character` (
  `Id` int(10) unsigned NOT NULL DEFAULT '0',
  `PosX` float DEFAULT '0',
  `PosY` float DEFAULT '0',
  `PosZ` float DEFAULT '0',
  `Interior` tinyint(3) unsigned DEFAULT '0',
  `UniqueInterior` smallint(5) unsigned DEFAULT '0',
  `Skin` smallint(5) unsigned DEFAULT '0',
  `Health` tinyint(3) unsigned DEFAULT '100',
  `Armor` tinyint(3) unsigned DEFAULT '0',
  `XP` float DEFAULT '0',
  `Karma` float DEFAULT '0',
  `Points` int(11) DEFAULT '0',
  `Money` int(10) unsigned DEFAULT '0',
  `BankMoney` int(10) unsigned DEFAULT '0',
  `WantedLevel` tinyint(3) unsigned DEFAULT '0',
  `TutorialStage` tinyint(3) unsigned DEFAULT '0',
  `Job` tinyint(3) unsigned DEFAULT '0',
  `GroupId` int(10) unsigned DEFAULT '0',
  `GroupRank` tinyint(3) unsigned DEFAULT NULL,
  `DrivingSkill` tinyint(3) unsigned DEFAULT '0',
  `GunSkill` tinyint(4) DEFAULT '0',
  `FlyingSkill` tinyint(3) unsigned DEFAULT '0',
  `SneakingSkill` tinyint(3) unsigned DEFAULT '0',
  `EnduranceSkill` tinyint(3) unsigned DEFAULT '0',
  `Weapons` text,
  `InventoryId` int(10) unsigned DEFAULT '0',
  `GarageType` tinyint(3) unsigned DEFAULT '0',
  `HangarType` int(11) NOT NULL DEFAULT '0',
  `LastGarageEntrance` tinyint(3) unsigned DEFAULT '0',
  `LastHangarEntrance` int(11) NOT NULL DEFAULT '0',
  `SpawnLocation` tinyint(3) unsigned DEFAULT '0',
  `Collectables` text,
  `WeaponLevel` int(10) DEFAULT '0',
  `VehicleLevel` int(10) DEFAULT '0',
  `SkinLevel` int(10) DEFAULT '0',
  `JobLevel` int(10) DEFAULT '0',
  `HasPilotsLicense` tinyint(1) unsigned DEFAULT '0',
  `Ladder` text,
  `Achievements` text,
  `PlayTime` int(10) unsigned DEFAULT '0',
  `CompanyId` int(11) NOT NULL DEFAULT '0',
  `CompanyRank` int(11) NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `vrp_character`
--

INSERT INTO `vrp_character` (`Id`, `PosX`, `PosY`, `PosZ`, `Interior`, `UniqueInterior`, `Skin`, `Health`, `Armor`, `XP`, `Karma`, `Points`, `Money`, `BankMoney`, `WantedLevel`, `TutorialStage`, `Job`, `GroupId`, `GroupRank`, `DrivingSkill`, `GunSkill`, `FlyingSkill`, `SneakingSkill`, `EnduranceSkill`, `Weapons`, `InventoryId`, `GarageType`, `HangarType`, `LastGarageEntrance`, `LastHangarEntrance`, `SpawnLocation`, `Collectables`, `WeaponLevel`, `VehicleLevel`, `SkinLevel`, `JobLevel`, `HasPilotsLicense`, `Ladder`, `Achievements`, `PlayTime`, `CompanyId`, `CompanyRank`) VALUES
(17, 706.309, -481.976, 16.1875, 0, 0, 0, 70, 0, 1.5, -0.15, 5, 24, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, '[ [ [ 0, 1 ] ] ]', 1, 0, 0, 0, 0, 0, '[ [ ] ]', 0, 0, 0, 0, 1, '', '[ { "20": true, "0": false, "6": true } ]', 4558, 0, 0),
(21, 2666.12, -1843.64, 11.4632, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, '[ [ [ 0, 1 ] ] ]', 8, 0, 0, 8, 0, 0, '[ [ ] ]', 0, 0, 2, 0, 1, '', '[ { "9": true, "0": false, "3": true, "17": true, "19": true, "49": true, "45": true, "6": true } ]', 102, 0, 0),
(3, 915.105, -1211.29, 16.9832, 0, 0, 200, 95, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, '[[[0,1]]]', 2, 0, 0, 2, 0, 0, '[["1"]]', 0, 0, 7, 0, 1, NULL, '[{"9":true,"0":false,"40":true,"13":true,"19":true,"46":true,"45":true,"6":true,"48":true,"49":true,"12":true,"17":true,"31":true,"21":true,"11":true,"47":true}]', 6676, 0, 0),
(18, 1219.24, -212.25, 34.587, 0, 0, 216, 100, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, '[ [ [ 0, 1 ] ] ]', 3, 0, 0, 8, 0, 0, '[ { "1": "1", "20": "1" } ]', 0, 0, 1, 0, 1, '', '[ { "1": true, "0": false, "3": true, "2": true, "11": true, "6": true } ]', 81, 0, 0),
(19, 135.62, 1095.17, 13.6094, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0|1|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0', 4, 0, 0, 0, 0, 0, '[ [ ] ]', 0, 0, 0, 0, 1, '', '[ { "0": false } ]', 2, 0, 0),
(20, 1100.28, -1406.92, 13.4516, 0, 0, 248, 80, 0, 0, 0, 33, 788, 0, 0, 3, 1, 0, 0, 0, 0, 0, 0, 0, '[ [ [ 0, 1 ] ] ]', 3, 0, 0, 1, 0, 0, '[ { "1": "1", "4": "1", "3": "1" } ]', 0, 0, 5, 1, 1, '', '[ { "0": false, "3": true, "46": true, "45": true, "6": true, "49": true, "17": true, "13": true, "12": true, "11": true } ]', 1852, 0, 0),
(1, 1228.62, -1720.12, 13.5469, 0, 0, 289, 12, 0, 0, 0, 41, 1509, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, '[ [ ] ]', 1, 0, 0, 1, 0, 0, '[ { "1": "1", "3": "1", "20": "1" } ]', 1, 0, 3, 1, 1, '', '[ { "1": true, "0": false, "3": true, "2": true, "19": true, "45": true, "6": true, "9": true, "49": true, "17": true, "13": true, "12": true, "11": true, "20": true } ]', 6393, 0, 0),
(22, 3449.95, -2142.65, 16.8162, 0, 0, 163, 100, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, '[ [ [ 0, 1 ], [ 25, 7 ], [ 30, 12 ] ] ]', 5, 0, 0, 3, 0, 0, '[ { "13": "1", "12": "1", "7": "1", "1": "1" } ]', 0, 0, 3, 0, 0, '', '[ { "3": true, "0": false } ]', 998, 0, 0),
(2, 706.997, -488.387, 16.1875, 0, 0, 241, 100, 0, 10.4999, -1.04999, 35, 581, 2900, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, '[ [ [ 0, 1 ], [ 30, 214 ] ] ]', 4, 0, 0, 1, 0, 0, '[ { "13": "1", "12": "1", "7": "1", "1": "1" } ]', 2, 1, 3, 4, 1, '', '[ { "0": false, "3": true, "45": true, "49": true, "21": true, "17": true, "20": true, "12": true, "11": true, "13": true } ]', 1943, 0, 0),
(24, 141.554, -77.1562, 1.57812, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, '[ [ [ 0, 1 ] ] ]', 8, 0, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 0, '', '[ { "0": false } ]', 42, 0, 0),
(23, 131.378, -67.6865, 1.57812, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, '[ [ [ 0, 1 ] ] ]', 7, 0, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 0, '', '[ { "0": false } ]', 3, 0, 0),
(25, 2011.37, -1416.38, 16.9922, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, '[ [ [ 0, 1 ] ] ]', 9, 0, 0, 2, 0, 0, NULL, 0, 0, 0, 0, 1, '', '[ { "0": false, "3": true, "17": true, "13": true, "12": true, "11": true, "6": true } ]', 113, 0, 0),
(26, 2243.62, -1656.31, 15.2881, 0, 0, 164, 65, 0, 20, 2, 12, 12357, 0, 0, 3, 6, 0, 0, 0, 0, 0, 0, 0, '[ [ [ 0, 1 ], [ 29, 264 ] ] ]', 10, 0, 0, 1, 0, 0, NULL, 6, 0, 1, 4, 0, '', '[ { "0": false, "45": true, "6": true, "49": true, "31": true, "17": true, "13": true, "12": true, "11": true, "20": true } ]', 257, 0, 0),
(27, 2006.46, -1452.69, 13.5547, 0, 0, 185, 63, 0, 3, -0.3, 146, 0, 5148, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, '[ [ [ 0, 1 ] ] ]', 14, 0, 0, 1, 0, 0, NULL, 0, 1, 0, 1, 0, '', '[ { "0": false, "3": true, "6": true, "9": true, "49": true, "17": true, "13": true, "12": true, "11": true, "20": true } ]', 201, 0, 0),
(28, 1914.69, -1453.18, 13.5469, 0, 0, 163, 95, 0, 30, 3, 254, 23153, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, '[ [ [ 0, 1 ] ] ]', 16, 0, 0, 1, 0, 0, '[ { "4": "1" } ]', 2, 4, 2, 5, 0, '', '[ { "0": false, "3": true, "45": true, "6": true, "49": true, "17": true, "13": true, "12": true, "11": true, "20": true } ]', 351, 0, 0),
(29, 1312.41, -1568.69, 12.8948, 0, 0, 195, 100, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, '[ [ [ 0, 1 ] ] ]', 18, 0, 0, 1, 0, 0, NULL, 0, 0, 0, 0, 0, '', '[ { "0": false, "3": true, "47": true, "9": true, "49": true, "17": true, "20": true, "12": true, "11": true, "13": true } ]', 109, 0, 0);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vrp_cheatlog`
--

CREATE TABLE IF NOT EXISTS `vrp_cheatlog` (
  `UserId` int(10) unsigned NOT NULL,
  `Name` varchar(25) NOT NULL,
  `Severity` tinyint(1) unsigned NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `vrp_cheatlog`
--

INSERT INTO `vrp_cheatlog` (`UserId`, `Name`, `Severity`) VALUES
(1, 'Sent invalid mileage', 2),
(1, 'Sent invalid mileage', 2),
(1, 'Sent invalid mileage', 2),
(1, 'Sent invalid mileage', 2),
(1, 'Sent invalid mileage', 2),
(1, 'Sent invalid mileage', 2),
(1, 'Sent invalid mileage', 2),
(2, 'Triggered collect event o', 2),
(2, 'Triggered collect event o', 2),
(20, 'Triggered collect event o', 2),
(20, 'Triggered collect event o', 2),
(20, 'Triggered collect event o', 2),
(20, 'Triggered collect event o', 2),
(20, 'Triggered collect event o', 2),
(1, 'Triggered collect event o', 2),
(1, 'Triggered collect event o', 2),
(1, 'Triggered collect event o', 2),
(1, 'Triggered collect event o', 2),
(1, 'Triggered collect event o', 2),
(20, 'Triggered collect event o', 2),
(20, 'Triggered collect event o', 2),
(20, 'Triggered collect event o', 2),
(20, 'Triggered collect event o', 2),
(2, 'Triggered collect event o', 2),
(1, 'Triggered collect event o', 2),
(20, 'Triggered collect event o', 2),
(20, 'Triggered collect event o', 2),
(20, 'Triggered collect event o', 2),
(20, 'Triggered collect event o', 2),
(20, 'Triggered collect event o', 2),
(26, 'Triggered collect event o', 2),
(1, 'Triggered collect event o', 2),
(27, 'Triggered collect event o', 2),
(27, 'Triggered collect event o', 2),
(27, 'Triggered collect event o', 2),
(27, 'Triggered collect event o', 2),
(29, 'Triggered collect event o', 2),
(29, 'Triggered collect event o', 2),
(29, 'Triggered collect event o', 2),
(29, 'Triggered collect event o', 2),
(29, 'Triggered collect event o', 2),
(29, 'Triggered collect event o', 2);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vrp_gangareas`
--

CREATE TABLE IF NOT EXISTS `vrp_gangareas` (
  `Id` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `Owner` int(10) unsigned DEFAULT NULL,
  `State` tinyint(3) unsigned DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vrp_groups`
--

CREATE TABLE IF NOT EXISTS `vrp_groups` (
  `Id` int(10) unsigned NOT NULL,
  `Name` varchar(20) DEFAULT NULL,
  `Tag` varchar(5) DEFAULT NULL,
  `Money` int(10) unsigned DEFAULT '0',
  `Karma` int(10) DEFAULT '0',
  `lastNameChange` int(10) DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vrp_houses`
--

CREATE TABLE IF NOT EXISTS `vrp_houses` (
  `Id` int(10) unsigned NOT NULL,
  `x` float(255,30) DEFAULT NULL,
  `y` float(255,30) DEFAULT NULL,
  `z` float(255,30) DEFAULT NULL,
  `interiorID` tinyint(10) unsigned DEFAULT NULL,
  `keys` text,
  `owner` int(10) unsigned DEFAULT NULL,
  `price` int(10) unsigned DEFAULT NULL,
  `lockStatus` tinyint(1) unsigned DEFAULT NULL,
  `rentPrice` int(100) unsigned DEFAULT NULL,
  `elements` text
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `vrp_houses`
--

INSERT INTO `vrp_houses` (`Id`, `x`, `y`, `z`, `interiorID`, `keys`, `owner`, `price`, `lockStatus`, `rentPrice`, `elements`) VALUES
(1, 2091.676757812500000000000000000000, -1278.489257812500000000000000000000, 26.179687500000000000000000000000, 1, '[ [ ] ]', 1, 25000, 0, 25, '[ [ ] ]'),
(2, 2111.196289062500000000000000000000, -1279.395507812500000000000000000000, 25.687500000000000000000000000000, 1, '[ [ ] ]', 3, 35000, 0, 25, '[ [ ] ]'),
(3, 2100.969726562500000000000000000000, -1321.155273437500000000000000000000, 25.953125000000000000000000000000, 2, '[ [ ] ]', 3, 15000, 0, 25, '[ [ ] ]'),
(4, 2126.564453125000000000000000000000, -1320.563476562500000000000000000000, 26.623929977416992000000000000000, 1, '[ [ ] ]', 3, 150000, 0, 25, '[ [ ] ]'),
(5, 2132.632812500000000000000000000000, -1280.931640625000000000000000000000, 25.890625000000000000000000000000, 2, '[ [ ] ]', 3, 75000, 0, 25, '[ [ ] ]'),
(6, 2150.021484375000000000000000000000, -1285.411132812500000000000000000000, 24.196470260620117000000000000000, 2, '[ [ ] ]', 3, 60000, 0, 25, '[ [ ] ]');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vrp_inventory`
--

CREATE TABLE IF NOT EXISTS `vrp_inventory` (
  `Id` int(10) unsigned NOT NULL,
  `Items` text NOT NULL,
  `Data` text NOT NULL
) ENGINE=MyISAM AUTO_INCREMENT=19 DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `vrp_inventory`
--

INSERT INTO `vrp_inventory` (`Id`, `Items`, `Data`) VALUES
(1, '[ [ ] ]', ''),
(2, '[ [ ] ]', ''),
(3, '[ [ ] ]', ''),
(4, '[ [ ] ]', ''),
(5, '[ [ ] ]', ''),
(6, '[ [ ] ]', ''),
(7, '[ [ ] ]', ''),
(8, '[ [ ] ]', ''),
(9, '[ [ ] ]', ''),
(10, '[ [ ] ]', ''),
(11, '[ [ ] ]', ''),
(12, '[ [ ] ]', ''),
(13, '[ [ ] ]', ''),
(14, '[ [ ] ]', ''),
(15, '[ [ ] ]', ''),
(16, '[ [ ] ]', ''),
(17, '[ [ ] ]', ''),
(18, '[ [ ] ]', '');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vrp_ladder`
--

CREATE TABLE IF NOT EXISTS `vrp_ladder` (
  `Id` int(10) NOT NULL DEFAULT '0',
  `Name` text,
  `Rating` int(11) DEFAULT NULL,
  `Type` text,
  `Members` text,
  `Founder` text
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `vrp_ladder`
--

INSERT INTO `vrp_ladder` (`Id`, `Name`, `Rating`, `Type`, `Members`, `Founder`) VALUES
(0, 'testTeam9814', 0, '2vs2', '[ [ 17 ] ]', '17');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vrp_paylog`
--

CREATE TABLE IF NOT EXISTS `vrp_paylog` (
  `id` int(10) unsigned NOT NULL,
  `userId` int(10) unsigned NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `newBankMoney` int(11) NOT NULL,
  `amount` int(10) NOT NULL,
  `date` datetime NOT NULL,
  `reason` text
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vrp_stats_money`
--

CREATE TABLE IF NOT EXISTS `vrp_stats_money` (
  `UserId` int(10) unsigned NOT NULL,
  `Amount` bigint(20) NOT NULL,
  `Description` text,
  `Date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vrp_vehicles`
--

CREATE TABLE IF NOT EXISTS `vrp_vehicles` (
  `Id` int(10) unsigned NOT NULL,
  `Model` smallint(5) unsigned DEFAULT NULL,
  `Owner` int(10) unsigned DEFAULT NULL,
  `PosX` float DEFAULT NULL,
  `PosY` float DEFAULT NULL,
  `PosZ` float DEFAULT NULL,
  `Rotation` smallint(5) unsigned DEFAULT NULL,
  `Color` int(10) unsigned DEFAULT NULL,
  `Health` smallint(5) unsigned DEFAULT NULL,
  `Keys` text,
  `PositionType` tinyint(3) unsigned DEFAULT '0',
  `Tunings` text,
  `Mileage` bigint(20) unsigned NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `vrp_account`
--
ALTER TABLE `vrp_account`
  ADD PRIMARY KEY (`Id`);

--
-- Indizes für die Tabelle `vrp_achievements`
--
ALTER TABLE `vrp_achievements`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `vrp_character`
--
ALTER TABLE `vrp_character`
  ADD PRIMARY KEY (`Id`);

--
-- Indizes für die Tabelle `vrp_cheatlog`
--
ALTER TABLE `vrp_cheatlog`
  ADD KEY `UserId` (`UserId`);

--
-- Indizes für die Tabelle `vrp_gangareas`
--
ALTER TABLE `vrp_gangareas`
  ADD PRIMARY KEY (`Id`);

--
-- Indizes für die Tabelle `vrp_groups`
--
ALTER TABLE `vrp_groups`
  ADD PRIMARY KEY (`Id`);

--
-- Indizes für die Tabelle `vrp_houses`
--
ALTER TABLE `vrp_houses`
  ADD PRIMARY KEY (`Id`);

--
-- Indizes für die Tabelle `vrp_inventory`
--
ALTER TABLE `vrp_inventory`
  ADD PRIMARY KEY (`Id`);

--
-- Indizes für die Tabelle `vrp_ladder`
--
ALTER TABLE `vrp_ladder`
  ADD PRIMARY KEY (`Id`);

--
-- Indizes für die Tabelle `vrp_paylog`
--
ALTER TABLE `vrp_paylog`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `vrp_vehicles`
--
ALTER TABLE `vrp_vehicles`
  ADD PRIMARY KEY (`Id`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `vrp_account`
--
ALTER TABLE `vrp_account`
  MODIFY `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=30;
--
-- AUTO_INCREMENT für Tabelle `vrp_achievements`
--
ALTER TABLE `vrp_achievements`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=52;
--
-- AUTO_INCREMENT für Tabelle `vrp_groups`
--
ALTER TABLE `vrp_groups`
  MODIFY `Id` int(10) unsigned NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT für Tabelle `vrp_houses`
--
ALTER TABLE `vrp_houses`
  MODIFY `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT für Tabelle `vrp_inventory`
--
ALTER TABLE `vrp_inventory`
  MODIFY `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=19;
--
-- AUTO_INCREMENT für Tabelle `vrp_paylog`
--
ALTER TABLE `vrp_paylog`
  MODIFY `id` int(10) unsigned NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT für Tabelle `vrp_vehicles`
--
ALTER TABLE `vrp_vehicles`
  MODIFY `Id` int(10) unsigned NOT NULL AUTO_INCREMENT;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
