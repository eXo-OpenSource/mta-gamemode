/*
Navicat MySQL Data Transfer

Source Server         : vRP
Source Server Version : 50173
Source Host           : jusonex.net:3306
Source Database       : saonline

Target Server Type    : MYSQL
Target Server Version : 50173
File Encoding         : 65001

Date: 2015-03-09 18:12:55
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `forum_ts3auth`
-- ----------------------------
DROP TABLE IF EXISTS `forum_ts3auth`;
CREATE TABLE `forum_ts3auth` (
  `boardId` int(10) unsigned NOT NULL,
  `authKey` varchar(6) NOT NULL,
  `ts3uid` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of forum_ts3auth
-- ----------------------------

-- ----------------------------
-- Table structure for `vrp_account`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_account`;
CREATE TABLE `vrp_account` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) DEFAULT NULL,
  `Salt` varchar(32) DEFAULT NULL,
  `Password` varchar(64) DEFAULT NULL,
  `Rank` tinyint(3) DEFAULT NULL,
  `LastSerial` varchar(32) DEFAULT NULL,
  `LastLogin` datetime DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM AUTO_INCREMENT=22 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_account
-- ----------------------------
INSERT INTO `vrp_account` VALUES ('17', 'false', '7365D32189ECBDD8FC818EF537F79BA1', 'AF5A64ED5E8461D824B94F97F006854046A55F27D812BC0F0D452DA872F35DF6', '5', '368989309EB012227161093646E56843', '2015-02-09 23:52:42');
INSERT INTO `vrp_account` VALUES ('1', 'Jusonex', '79C501C2830570204C6915BFBDEA9B2E', 'EAAD8B87E27E8258E0D550F6F6816675C65A5748FCC72D880E0F68502E01FD2C', '5', 'C4586E3449E6ECC0FA1FD8B269E2A873', '2015-03-09 13:18:18');
INSERT INTO `vrp_account` VALUES ('2', 'Doneasty', '', '994FCB227681CFD6CA119F0A30553FCA590AECF5EA2617C9E4AF934198B85956', '4', '239A5FCD692C6C4D8ABD55F3C00E4D94', '2015-03-04 20:51:24');
INSERT INTO `vrp_account` VALUES ('3', 'StiviK', '', 'DAF9854A6D826EA2B31E2336ECD0875836E4EFAD6CA23349BE083E68FE34A05E', '5', '71B947A4FF2929B905F4EE55B9182F02', '2015-03-09 17:13:38');
INSERT INTO `vrp_account` VALUES ('18', 'Toxsi', '', '530AF54CE47C502654D30C74A6B4CAF5861DB3AF5D307187A8F99C150D4BCF4D', '1', '28D715400EC6C9F57DEB328D003ADA43', '2015-02-27 12:47:28');
INSERT INTO `vrp_account` VALUES ('19', 'sbx320', '', '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92', '5', null, null);
INSERT INTO `vrp_account` VALUES ('20', 'Johnny', '', 'C549ADDC80367E17FD46B5B6A094EE7F9958D5C92FBA35F519E64C5A4304DDE6', '0', 'F4274B79FE188EFA7C4680896AB9F282', '2015-03-04 20:45:20');
INSERT INTO `vrp_account` VALUES ('21', 'Gibaex', '', 'B40EA7ED8ED4B021B47BE8CFA58442E7A5DEA697C325E78CABD20DF0C9215F71', '0', '3B8A80C51B9676FB85CD5BC30FD36544', '2015-02-21 23:04:45');

-- ----------------------------
-- Table structure for `vrp_achievements`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_achievements`;
CREATE TABLE `vrp_achievements` (
  `id` int(255) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `desc` varchar(255) DEFAULT NULL,
  `img` varchar(255) DEFAULT NULL,
  `exp` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=49 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_achievements
-- ----------------------------
INSERT INTO `vrp_achievements` VALUES ('1', 'Evil Geddow Kid', '\"Man wird zum ersten mal von gut auf böse gestuft\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('2', 'Good Guy', '\"Man wird zum ersten mal von böse auf gut gestuft\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('3', 'Developerschelle', '\"Man wird von einem Admin mit dem Rang \"Developer\" getötet\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('4', 'Giving Air', '\"Man drückt einen Anruf weg\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('5', 'Wandervogel', '\"Man hat alle Jobs durch\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('6', 'Faust Gottes', '\"Man wird von Doneasty geschlagen ;)\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('7', 'Boss aus dem Gettho', '\"Man gründet eine Gang\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('8', 'Kriminell und breit gebaut', '\"Man tritt einer Gang bei\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('9', 'Gutes blaues Männchen', '\"Man wird Polizist\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('10', 'Traumland', '\"Man ist völlig bekifft\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('11', 'Harter Holzfäller', '\"Man wird Holzfäller\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('12', 'Meister des Mülls', '\"Man wird Müllfahrer\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('13', 'Mülllehrling', '\"Man wird Straßenkehrer\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('14', 'Meister der Diebe', '\"Man hat einen Bankraub überstanden\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('15', 'Kleinkrimineller', '\"Man hat einen Laden überfallen\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('16', 'Vettel für Arme', '\"Man hat ein Straßenrennen gewonnen\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('17', 'Meiner ist 15 Meter lang', '\"Man wird Busfahrer\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('18', 'Mülltonnen Kicker', '\"Man tritt eine Mülltonne\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('19', 'Süßigkeiten Dieb', '\"Man raubt einen Automaten aus\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('20', 'Old McDonnald has a farm', '\"Man wird Farmer\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('21', 'Millionär', '\"Man hat 1.000.000$ an Geld\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('22', 'Freak Collector', '\"Man hat alle Freaks durch\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('23', 'Check my new outfit', '\"Man hat seinen Skin gewechselt\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('24', 'Tales of Johnny Walker', '\"Man telefoniert mit Johnny\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('25', 'Die macht mit dir ist, junger ..Name..', '\"Man hat Yoda im Kampf besiegt\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('26', 'Hartzer', '\"Man kündigt seinen Job\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('27', 'Wirtschaftsguru', '\"Man kauft eine Firma\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('28', 'Karrieremensch', '\"Man tritt einer Firma bei\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('29', 'Nicht den Kuchen klauen', '\"Man berührt den Kuchen auf dem Jusonexschen Platz\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('30', 'H4cks0r', '\"Man hat den Knast gehackt\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('31', 'Storys from the Block', '\"Man landet im Knast\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('32', 'Blutsbrüder', '\"Man holt ein Gangmitglied aus dem Knast\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('33', 'Geschäftsmann', '\"Man handelt\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('34', 'Grundbesitzer', '\"Man besitzt ein Haus\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('35', 'Born to be wild', '\"Man besitzt ein Motorrad\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('36', 'Das ertse Auto', '\"Man besitzt ein Auto\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('37', 'Geboren um zu sterben', '\"Man stirbt\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('38', 'Like a Sir', '\"Man klickt Sarcasm an\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('39', 'Carsten Stahl', '\"Man wird von Revelse verprügelt oder von seinem Jeep (Huntley) überfahren\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('40', 'Rich as fuck', '\"Man besitzt 10.000.000 $\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('41', 'Giving Air-sbx320 Edition', '\"Man wird von sbx320 weggedrückt\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('42', 'Get rich', '\"Man spielt Lotto\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('43', 'Baumtänzer', '\"Man führt die Animation \"dance 3\" in der Nähe eines Baums aus\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('44', 'Fuck the Police', '\"Man tötet einen Polizisten\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('45', 'Paragraph 31', '\"Man bekommt ein Wanted\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('46', 'Interpol.com', '\"Man hat 6 Wanteds\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('47', 'Lausbubenjäger', '\"Man knastet jemanden unter 4 Sterne ein\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('48', 'Sondereinheit', '\"Man knastet jemanden mit über 4 Sternen ein\"', 'none', '5');

-- ----------------------------
-- Table structure for `vrp_bank_statements`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_bank_statements`;
CREATE TABLE `vrp_bank_statements` (
  `UserId` int(10) DEFAULT NULL,
  `Type` tinyint(4) DEFAULT NULL,
  `Amount` int(11) DEFAULT NULL,
  `Date` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_bank_statements
-- ----------------------------
INSERT INTO `vrp_bank_statements` VALUES ('3', '4', '5245', '2015-02-03 18:01:09');
INSERT INTO `vrp_bank_statements` VALUES ('3', '3', '5245', '2015-02-03 18:01:15');
INSERT INTO `vrp_bank_statements` VALUES ('3', '4', '7468', '2015-02-05 16:10:38');
INSERT INTO `vrp_bank_statements` VALUES ('3', '4', '38521', '2015-02-07 14:25:33');
INSERT INTO `vrp_bank_statements` VALUES ('3', '4', '93213', '2015-02-07 14:25:45');
INSERT INTO `vrp_bank_statements` VALUES ('3', '3', '139202', '2015-02-07 14:25:49');
INSERT INTO `vrp_bank_statements` VALUES ('3', '4', '30455', '2015-02-07 14:25:53');
INSERT INTO `vrp_bank_statements` VALUES ('2', '4', '12', '2015-02-21 21:42:00');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-02-21 21:42:02');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '1', '2015-02-21 21:42:02');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-02-21 21:42:04');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '1', '2015-02-21 21:42:04');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-02-21 21:42:04');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '1', '2015-02-21 21:42:04');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-02-21 21:42:04');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '1', '2015-02-21 21:42:04');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-02-21 21:42:04');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '1', '2015-02-21 21:42:04');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-02-21 21:42:05');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '1', '2015-02-21 21:42:05');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-02-21 21:42:05');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '1', '2015-02-21 21:42:05');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-02-21 21:42:05');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '1', '2015-02-21 21:42:05');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-02-21 21:42:05');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '1', '2015-02-21 21:42:05');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-02-21 21:42:05');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '1', '2015-02-21 21:42:05');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-02-21 21:42:06');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '1', '2015-02-21 21:42:06');
INSERT INTO `vrp_bank_statements` VALUES ('2', '4', '111572', '2015-02-21 22:24:04');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '12', '2015-02-22 11:35:41');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '12', '2015-02-22 11:35:41');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '12', '2015-02-22 11:35:42');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '12', '2015-02-22 11:35:42');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '12', '2015-02-22 11:35:42');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '12', '2015-02-22 11:35:42');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '12', '2015-02-22 11:35:42');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '12', '2015-02-22 11:35:42');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '12', '2015-02-22 11:35:42');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '12', '2015-02-22 11:35:42');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '12', '2015-02-22 11:35:43');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '12', '2015-02-22 11:35:43');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '12', '2015-02-22 11:35:43');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '12', '2015-02-22 11:35:43');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '12', '2015-02-22 11:35:43');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '12', '2015-02-22 11:35:43');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '12', '2015-02-22 11:35:43');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '12', '2015-02-22 11:35:43');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '12', '2015-02-22 11:35:43');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '12', '2015-02-22 11:35:43');

-- ----------------------------
-- Table structure for `vrp_bans`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_bans`;
CREATE TABLE `vrp_bans` (
  `serial` varchar(32) DEFAULT NULL,
  `author` int(10) unsigned DEFAULT NULL,
  `reason` text,
  `expires` int(10) unsigned DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_bans
-- ----------------------------

-- ----------------------------
-- Table structure for `vrp_character`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_character`;
CREATE TABLE `vrp_character` (
  `Id` int(10) unsigned NOT NULL DEFAULT '0',
  `PosX` float DEFAULT '0',
  `PosY` float DEFAULT '0',
  `PosZ` float DEFAULT '0',
  `Interior` tinyint(3) unsigned DEFAULT '0',
  `Skin` smallint(5) unsigned DEFAULT '0',
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
  `GarageType` tinyint(3) unsigned DEFAULT '1',
  `LastGarageEntrance` tinyint(3) unsigned DEFAULT '0',
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
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_character
-- ----------------------------
INSERT INTO `vrp_character` VALUES ('17', '1818.79', '-1349.76', '15.0753', '0', null, '0', '0', '0', '28', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0|1|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0', '1', '1', '0', '0', '[ [ ] ]', '0', '0', '0', null, null, '', '[ { \"0\": false } ]', '500');
INSERT INTO `vrp_character` VALUES ('21', '1122.38', '-1151.8', '23.4703', '0', '0', '215.499', '-10', '0', '34000', '0', '0', '3', '6', '22', '0', '0', '0', '0', '0', '0', '0|1|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0', '3', '1', '8', '0', '[ [ ] ]', '0', '0', '0', '2', '1', '', '[ { \"0\": false, \"3\": true, \"6\": true } ]', '500');
INSERT INTO `vrp_character` VALUES ('3', '1389.04', '-1245.27', '13.3828', '0', '249', '27985.8', '68.321', '2891872', '8009', '30586', '0', '3', '7', '21', '2', '0', '0', '0', '0', '0', '0|1|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0', '2', '3', '1', '0', '[ { \"1\": \"1\", \"24\": \"1\", \"7\": \"1\", \"2\": \"1\" } ]', '10', '10', '10', '10', '1', '', '[ { \"25\": true, \"0\": false, \"3\": true, \"2\": true, \"8\": true, \"24\": true, \"6\": true } ]', '1739');
INSERT INTO `vrp_character` VALUES ('18', '2733.74', '-2768.5', '11.5172', '0', '216', '40.9988', '0.100125', '13', '817', '0', '0', '3', '2', '0', '0', '0', '0', '0', '0', '0', '0|1|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0', '2', '1', '4', '0', '[ { \"20\": \"1\" } ]', '2', '1', '1', '6', '1', '', '[ { \"1\": true, \"0\": false, \"3\": true, \"2\": true, \"6\": true } ]', '9');
INSERT INTO `vrp_character` VALUES ('19', '135.62', '1095.17', '13.6094', '0', null, '0', '0', '0', '55', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0|1|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0', '2', '1', '0', '0', '[ [ ] ]', '0', '0', '0', null, null, '', '[ { \"0\": false } ]', '500');
INSERT INTO `vrp_character` VALUES ('20', '2024', '-1401.68', '17.1979', '0', '254', '220.022', '29.8656', '0', '2690', '0', '0', '3', '4', '22', '1', '0', '0', '0', '0', '0', '0|1|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0', '3', '1', '1', '0', '[ { \"3\": \"1\" } ]', '0', '0', '0', '2', '1', '', '[ { \"0\": false, \"3\": true, \"6\": true } ]', '124');
INSERT INTO `vrp_character` VALUES ('1', '2665.72', '-1755.98', '11.3016', '0', '269', '1535.09', '29.4525', '154', '18544', '0', '0', '3', '4', '0', '0', '0', '0', '0', '0', '0', '0|1|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0', '2', '1', '6', '0', '[ { \"20\": \"1\", \"3\": \"1\" } ]', '1', '1', '1', '3', '1', '', '[ { \"1\": true, \"0\": false, \"3\": true, \"2\": true, \"6\": true } ]', '1051');
INSERT INTO `vrp_character` VALUES ('2', '2025.2', '-1402.35', '17.2093', '0', '0', '6.692', '30.0192', '33', '500', '111453', '0', '3', '4', '22', '2', '0', '0', '0', '0', '0', '0|1|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0', '2', '1', '8', '0', '[ [ ] ]', '0', '0', '0', '2', '1', '', '[ { \"3\": true, \"0\": false } ]', '42');

-- ----------------------------
-- Table structure for `vrp_cheatlog`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_cheatlog`;
CREATE TABLE `vrp_cheatlog` (
  `UserId` int(10) unsigned DEFAULT NULL,
  `Name` varchar(25) DEFAULT NULL,
  `Severity` tinyint(1) unsigned DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_cheatlog
-- ----------------------------

-- ----------------------------
-- Table structure for `vrp_gangareas`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_gangareas`;
CREATE TABLE `vrp_gangareas` (
  `Id` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `Owner` int(10) unsigned DEFAULT NULL,
  `State` tinyint(3) unsigned DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_gangareas
-- ----------------------------
INSERT INTO `vrp_gangareas` VALUES ('1', '21', null);

-- ----------------------------
-- Table structure for `vrp_groups`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_groups`;
CREATE TABLE `vrp_groups` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) DEFAULT NULL,
  `Money` int(10) unsigned DEFAULT '0',
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM AUTO_INCREMENT=23 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_groups
-- ----------------------------
INSERT INTO `vrp_groups` VALUES ('21', '5etdh', '762471');
INSERT INTO `vrp_groups` VALUES ('22', 'Swasi Mafia', '900');

-- ----------------------------
-- Table structure for `vrp_houses`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_houses`;
CREATE TABLE `vrp_houses` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `x` float(255,30) DEFAULT NULL,
  `y` float(255,30) DEFAULT NULL,
  `z` float(255,30) DEFAULT NULL,
  `interiorID` tinyint(10) unsigned DEFAULT NULL,
  `keys` text,
  `owner` int(10) unsigned DEFAULT NULL,
  `price` int(10) unsigned DEFAULT NULL,
  `lockStatus` tinyint(1) unsigned DEFAULT NULL,
  `rentPrice` int(100) unsigned DEFAULT NULL,
  `elements` text,
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_houses
-- ----------------------------

-- ----------------------------
-- Table structure for `vrp_inventory`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_inventory`;
CREATE TABLE `vrp_inventory` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Items` text NOT NULL,
  `Data` text NOT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_inventory
-- ----------------------------
INSERT INTO `vrp_inventory` VALUES ('1', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('2', '[ [ [ 7, 7 ], [ 7, 8 ] ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('3', '[ [ [ 7, 3 ] ] ]', '');

-- ----------------------------
-- Table structure for `vrp_ladder`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_ladder`;
CREATE TABLE `vrp_ladder` (
  `Id` int(10) NOT NULL DEFAULT '0',
  `Name` text,
  `Rating` int(11) DEFAULT NULL,
  `Type` text,
  `Members` text,
  `Founder` text,
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_ladder
-- ----------------------------
INSERT INTO `vrp_ladder` VALUES ('0', 'testTeam9814', '0', '2vs2', '[ [ 17 ] ]', '17');

-- ----------------------------
-- Table structure for `vrp_paylog`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_paylog`;
CREATE TABLE `vrp_paylog` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `userId` int(10) unsigned NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `newBankMoney` int(11) NOT NULL,
  `amount` int(10) NOT NULL,
  `date` datetime NOT NULL,
  `reason` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_paylog
-- ----------------------------

-- ----------------------------
-- Table structure for `vrp_vehicles`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_vehicles`;
CREATE TABLE `vrp_vehicles` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Model` smallint(5) unsigned DEFAULT NULL,
  `Owner` int(10) unsigned DEFAULT NULL,
  `PosX` float DEFAULT NULL,
  `PosY` float DEFAULT NULL,
  `PosZ` float DEFAULT NULL,
  `Rotation` smallint(5) unsigned DEFAULT NULL,
  `Color` int(10) unsigned DEFAULT NULL,
  `Health` smallint(5) unsigned DEFAULT NULL,
  `Keys` text,
  `IsInGarage` tinyint(3) unsigned DEFAULT '0',
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM AUTO_INCREMENT=20 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_vehicles
-- ----------------------------
INSERT INTO `vrp_vehicles` VALUES ('1', '522', '1', '1597.27', '966.276', '10.3687', '229', '4280624423', '0', '[ [ ] ]', '1');
INSERT INTO `vrp_vehicles` VALUES ('9', '438', '3', '1598.6', '1084', '10.8008', '326', '4286545791', '1000', '[ [ 3 ] ]', '1');
INSERT INTO `vrp_vehicles` VALUES ('17', '423', '3', '1605.99', '1083.29', '10.8822', '326', '4294967295', '1000', '[ [ ] ]', '1');
INSERT INTO `vrp_vehicles` VALUES ('13', '560', '1', '1604.3', '974.799', '10.5607', '180', '4285730330', '999', '[ [ 2 ] ]', '1');
INSERT INTO `vrp_vehicles` VALUES ('16', '561', '21', '1122.38', '-1151.8', '23.4703', '98', '4281154101', '1000', '[ [ ] ]', '1');
INSERT INTO `vrp_vehicles` VALUES ('15', '489', '18', '2471.99', '-1674.79', '13.408', '157', '4284051079', '0', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('19', '572', '3', '2217.08', '-2367.52', '13.1568', '83', '4284426027', '838', '[ [ 3, 3, 3, 3 ] ]', '0');
