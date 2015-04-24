/*
Navicat MySQL Data Transfer

Source Server         : vRP
Source Server Version : 50173
Source Host           : jusonex.net:3306
Source Database       : saonline

Target Server Type    : MYSQL
Target Server Version : 50173
File Encoding         : 65001

Date: 2015-04-24 18:13:29
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
  `EMail` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_account
-- ----------------------------
INSERT INTO `vrp_account` VALUES ('17', 'false', '7365D32189ECBDD8FC818EF537F79BA1', 'AF5A64ED5E8461D824B94F97F006854046A55F27D812BC0F0D452DA872F35DF6', '5', '368989309EB012227161093646E56843', '2015-04-22 17:29:58', null);
INSERT INTO `vrp_account` VALUES ('1', 'Jusonex', '79C501C2830570204C6915BFBDEA9B2E', 'EAAD8B87E27E8258E0D550F6F6816675C65A5748FCC72D880E0F68502E01FD2C', '5', 'C4586E3449E6ECC0FA1FD8B269E2A873', '2015-04-23 19:29:57', null);
INSERT INTO `vrp_account` VALUES ('2', 'Doneasty', '', '994FCB227681CFD6CA119F0A30553FCA590AECF5EA2617C9E4AF934198B85956', '4', '239A5FCD692C6C4D8ABD55F3C00E4D94', '2015-04-06 22:01:08', null);
INSERT INTO `vrp_account` VALUES ('3', 'StiviK', '', 'DAF9854A6D826EA2B31E2336ECD0875836E4EFAD6CA23349BE083E68FE34A05E', '5', '71B947A4FF2929B905F4EE55B9182F02', '2015-04-23 19:39:04', null);
INSERT INTO `vrp_account` VALUES ('18', 'Toxsi', '', '530AF54CE47C502654D30C74A6B4CAF5861DB3AF5D307187A8F99C150D4BCF4D', '2', '28D715400EC6C9F57DEB328D003ADA43', '2015-04-10 16:18:44', null);
INSERT INTO `vrp_account` VALUES ('19', 'sbx320', '', '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92', '5', null, null, null);
INSERT INTO `vrp_account` VALUES ('20', 'Johnny', '', 'C549ADDC80367E17FD46B5B6A094EE7F9958D5C92FBA35F519E64C5A4304DDE6', '2', 'F4274B79FE188EFA7C4680896AB9F282', '2015-04-06 21:58:03', null);
INSERT INTO `vrp_account` VALUES ('21', 'Gibaex', '', 'C549ADDC80367E17FD46B5B6A094EE7F9958D5C92FBA35F519E64C5A4304DDE6', '0', '3B8A80C51B9676FB85CD5BC30FD36544', '2015-03-16 19:57:40', null);
INSERT INTO `vrp_account` VALUES ('22', 'Sarcasm', '', '5994471ABB01112AFCC18159F6CC74B4F511B99806DA59B3CAF5A9C173CACFC5', '3', 'D43F3EA89CAFB26F6AA8EE0EDA339A53', '2015-04-07 18:53:11', null);
INSERT INTO `vrp_account` VALUES ('23', 'TestUser4', '79C501C2830570204C6915BFBDEA9B2E', 'EAAD8B87E27E8258E0D550F6F6816675C65A5748FCC72D880E0F68502E01FD2C', '0', '', null, 'jusonex@v-roleplay.net');
INSERT INTO `vrp_account` VALUES ('24', 'TestUser5', '5CC91EB66F1963FC8DBAC6D47935151F', '3286AFDBFBB08817A88C6CC58767E281199CBA11E17DF5E4C7D0369C57ED81E3', '0', 'C4586E3449E6ECC0FA1FD8B269E2A873', '2015-04-20 14:35:49', 'doneasty@web.de');

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
) ENGINE=MyISAM AUTO_INCREMENT=52 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_achievements
-- ----------------------------
INSERT INTO `vrp_achievements` VALUES ('1', 'Evil Geddow Kid', '\"Man wird zum ersten mal von gut auf böse gestuft\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('2', 'Good Guy', '\"Man wird zum ersten mal von böse auf gut gestuft\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('3', 'Developerschelle', 'Man wird von einem Admin mit dem Rang \"Developer\" getötet', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('4', 'Giving Air', '\"Man drückt einen Anruf weg\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('5', 'Wandervogel', '\"Man hat alle Jobs durch\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('6', 'Faust Gottes', 'Man wird von Doneasty geschlagen ;)', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('7', 'Boss aus dem Gettho', '\"Man gründet eine Gang\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('8', 'Kriminell und breit gebaut', '\"Man tritt einer Gang bei\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('9', 'Gutes blaues Männchen', 'Man wird Polizist', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('10', 'Traumland', '\"Man ist völlig bekifft\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('11', 'Harter Holzfäller', 'Man wird Holzfäller', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('12', 'Meister des Mülls', 'Man wird Müllfahrer', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('13', 'Mülllehrling', 'Man wird Straßenkehrer', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('14', 'Meister der Diebe', '\"Man hat einen Bankraub überstanden\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('15', 'Kleinkrimineller', '\"Man hat einen Laden überfallen\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('16', 'Vettel für Arme', '\"Man hat ein Straßenrennen gewonnen\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('17', 'Meiner ist 15 Meter lang', 'Man wird Busfahrer', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('18', 'Mülltonnen Kicker', '\"Man tritt eine Mülltonne\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('19', 'Süßigkeiten Dieb', 'Man raubt einen Automaten aus', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('20', 'Old McDonnald has a farm', 'Man wird Farmer', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('21', 'Millionär', 'Man hat 1.000.000$ an Geld', 'none', '250');
INSERT INTO `vrp_achievements` VALUES ('22', 'Freak Collector', '\"Man hat alle Freaks durch\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('23', 'Check my new outfit', '\"Man hat seinen Skin gewechselt\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('24', 'Tales of Johnny Walker', '\"Man telefoniert mit Johnny\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('25', 'Die macht mit dir ist, junger ..Name..', '\"Man hat Yoda im Kampf besiegt\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('26', 'Hartzer', '\"Man kündigt seinen Job\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('27', 'Wirtschaftsguru', '\"Man kauft eine Firma\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('28', 'Karrieremensch', '\"Man tritt einer Firma bei\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('29', 'Nicht den Kuchen klauen', '\"Man berührt den Kuchen auf dem Jusonexschen Platz\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('30', 'H4cks0r', '\"Man hat den Knast gehackt\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('31', 'Storys from the Block', 'Man landet im Knast', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('32', 'Blutsbrüder', '\"Man holt ein Gangmitglied aus dem Knast\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('33', 'Geschäftsmann', '\"Man handelt\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('34', 'Grundbesitzer', '\"Man besitzt ein Haus\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('35', 'Born to be wild', '\"Man besitzt ein Motorrad\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('36', 'Das ertse Auto', '\"Man besitzt ein Auto\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('37', 'Geboren um zu sterben', '\"Man stirbt\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('38', 'Like a Sir', '\"Man klickt Sarcasm an\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('39', 'Carsten Stahl', 'Man wird von Revelse verprügelt oder von seinem Jeep (Huntley) überfahren', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('40', 'Rich as fuck', 'Man besitzt 10.000.000 $', 'none', '1000');
INSERT INTO `vrp_achievements` VALUES ('41', 'Giving Air-sbx320 Edition', '\"Man wird von sbx320 weggedrückt\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('42', 'Get rich', '\"Man spielt Lotto\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('43', 'Baumtänzer', '\"Man führt die Animation \"dance 3\" in der Nähe eines Baums aus\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('44', 'Fuck the Police', '\"Man tötet einen Polizisten\"', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('45', 'Paragraph 31', 'Man bekommt ein Wanted', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('46', 'Interpol.com', 'Man hat 6 Wanteds', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('47', 'Lausbubenjäger', 'Man knastet jemanden unter 4 Sterne ein', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('48', 'Sondereinheit', 'Man knastet jemanden mit über 4 Sternen ein', 'none', '5');
INSERT INTO `vrp_achievements` VALUES ('49', 'Le Easteregg', 'Such Text. So Easteregg. Wow.', 'none', '25');

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
INSERT INTO `vrp_bank_statements` VALUES ('2', '4', '2200', '2015-03-14 19:05:57');
INSERT INTO `vrp_bank_statements` VALUES ('2', '3', '11000', '2015-03-15 00:13:38');
INSERT INTO `vrp_bank_statements` VALUES ('2', '4', '3000', '2015-03-15 11:46:37');
INSERT INTO `vrp_bank_statements` VALUES ('2', '3', '100000', '2015-03-15 11:50:33');
INSERT INTO `vrp_bank_statements` VALUES ('2', '4', '70000', '2015-03-15 13:08:45');
INSERT INTO `vrp_bank_statements` VALUES ('2', '4', '5000', '2015-03-15 18:30:40');
INSERT INTO `vrp_bank_statements` VALUES ('2', '3', '20000', '2015-03-15 18:31:16');
INSERT INTO `vrp_bank_statements` VALUES ('2', '4', '20000', '2015-03-15 20:25:46');
INSERT INTO `vrp_bank_statements` VALUES ('2', '4', '1942386', '2015-03-16 19:44:20');
INSERT INTO `vrp_bank_statements` VALUES ('3', '4', '31224525', '2015-03-16 19:44:31');
INSERT INTO `vrp_bank_statements` VALUES ('20', '4', '17000', '2015-03-17 18:26:57');
INSERT INTO `vrp_bank_statements` VALUES ('20', '1', '300000', '2015-03-17 18:58:46');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '300000', '2015-03-17 18:58:46');
INSERT INTO `vrp_bank_statements` VALUES ('2', '3', '120000', '2015-03-17 18:58:56');
INSERT INTO `vrp_bank_statements` VALUES ('20', '3', '300000', '2015-03-17 19:01:14');
INSERT INTO `vrp_bank_statements` VALUES ('20', '1', '400000', '2015-03-17 19:14:14');
INSERT INTO `vrp_bank_statements` VALUES ('2', '2', '400000', '2015-03-17 19:14:14');
INSERT INTO `vrp_bank_statements` VALUES ('20', '3', '300000', '2015-03-17 19:14:52');
INSERT INTO `vrp_bank_statements` VALUES ('2', '3', '250000', '2015-03-17 19:21:42');
INSERT INTO `vrp_bank_statements` VALUES ('22', '3', '5000', '2015-04-01 16:50:13');
INSERT INTO `vrp_bank_statements` VALUES ('18', '4', '150500', '2015-04-03 18:57:26');
INSERT INTO `vrp_bank_statements` VALUES ('3', '4', '1865875', '2015-04-22 12:08:35');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-04-22 12:08:41');
INSERT INTO `vrp_bank_statements` VALUES ('3', '2', '1', '2015-04-22 12:08:41');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-04-22 12:08:43');
INSERT INTO `vrp_bank_statements` VALUES ('3', '2', '1', '2015-04-22 12:08:43');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-04-22 12:08:43');
INSERT INTO `vrp_bank_statements` VALUES ('3', '2', '1', '2015-04-22 12:08:43');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-04-22 12:08:44');
INSERT INTO `vrp_bank_statements` VALUES ('3', '2', '1', '2015-04-22 12:08:44');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-04-22 12:08:44');
INSERT INTO `vrp_bank_statements` VALUES ('3', '2', '1', '2015-04-22 12:08:44');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-04-22 12:08:44');
INSERT INTO `vrp_bank_statements` VALUES ('3', '2', '1', '2015-04-22 12:08:44');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-04-22 12:08:44');
INSERT INTO `vrp_bank_statements` VALUES ('3', '2', '1', '2015-04-22 12:08:44');
INSERT INTO `vrp_bank_statements` VALUES ('3', '1', '1', '2015-04-22 12:08:44');
INSERT INTO `vrp_bank_statements` VALUES ('3', '2', '1', '2015-04-22 12:08:45');
INSERT INTO `vrp_bank_statements` VALUES ('3', '3', '1865875', '2015-04-23 17:10:48');
INSERT INTO `vrp_bank_statements` VALUES ('3', '4', '9999999', '2015-04-23 17:11:11');
INSERT INTO `vrp_bank_statements` VALUES ('3', '4', '1', '2015-04-23 17:11:19');
INSERT INTO `vrp_bank_statements` VALUES ('3', '4', '1', '2015-04-23 17:11:57');
INSERT INTO `vrp_bank_statements` VALUES ('3', '3', '1', '2015-04-23 17:12:39');
INSERT INTO `vrp_bank_statements` VALUES ('3', '4', '1', '2015-04-23 17:12:47');
INSERT INTO `vrp_bank_statements` VALUES ('3', '3', '1', '2015-04-23 17:14:07');
INSERT INTO `vrp_bank_statements` VALUES ('3', '4', '1', '2015-04-23 17:14:09');
INSERT INTO `vrp_bank_statements` VALUES ('3', '3', '1', '2015-04-23 17:14:41');
INSERT INTO `vrp_bank_statements` VALUES ('3', '4', '1', '2015-04-23 17:14:44');
INSERT INTO `vrp_bank_statements` VALUES ('3', '3', '10000000', '2015-04-23 17:28:32');
INSERT INTO `vrp_bank_statements` VALUES ('3', '3', '1', '2015-04-23 17:28:40');
INSERT INTO `vrp_bank_statements` VALUES ('3', '4', '100000', '2015-04-23 17:28:46');
INSERT INTO `vrp_bank_statements` VALUES ('3', '3', '100000', '2015-04-23 17:29:09');
INSERT INTO `vrp_bank_statements` VALUES ('3', '4', '1000000', '2015-04-23 17:29:16');
INSERT INTO `vrp_bank_statements` VALUES ('3', '3', '10000', '2015-04-23 17:29:47');
INSERT INTO `vrp_bank_statements` VALUES ('3', '3', '990000', '2015-04-23 17:29:52');
INSERT INTO `vrp_bank_statements` VALUES ('3', '4', '1000000', '2015-04-23 17:29:59');
INSERT INTO `vrp_bank_statements` VALUES ('3', '4', '9000000', '2015-04-23 17:30:10');
INSERT INTO `vrp_bank_statements` VALUES ('3', '3', '3001', '2015-04-23 17:35:15');
INSERT INTO `vrp_bank_statements` VALUES ('3', '4', '6002', '2015-04-23 17:35:21');

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
INSERT INTO `vrp_character` VALUES ('17', '2147.11', '-1263.11', '23.9943', '0', '0', '95', '0', '0', '0', '0', '276', '0', '0', '3', '5', '0', '0', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ] ] ]', '1', '1', '0', '0', '[ [ ] ]', '0', '0', '0', '20', '1', '', '[ { \"0\": false } ]', '4397');
INSERT INTO `vrp_character` VALUES ('21', '1568.78', '-1167.39', '24.0781', '0', '0', '100', '0', '216.992', '-10.1493', '0', '4000', '0', '0', '3', '6', '23', '2', '0', '0', '0', '0', '0', '0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0', '8', '1', '8', '0', '[ [ ] ]', '0', '0', '0', '2', '1', '', '[ { \"0\": false, \"3\": true, \"6\": true } ]', '18');
INSERT INTO `vrp_character` VALUES ('3', '649.22', '-1202.08', '18.1074', '0', '200', '72', '0', '4750.86', '93.7694', '14661', '2950', '10003001', '0', '3', '0', '26', '2', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ] ] ]', '2', '3', '12', '0', '[ { \"1\": \"1\", \"11\": \"1\" } ]', '8', '2', '7', '3', '1', '', '[ { \"0\": false, \"40\": true, \"47\": true, \"19\": true, \"46\": true, \"45\": true, \"31\": true, \"48\": true, \"49\": true, \"21\": true, \"17\": true, \"13\": true, \"12\": true, \"11\": true, \"9\": true } ]', '5087');
INSERT INTO `vrp_character` VALUES ('18', '1079.61', '4465.82', '-0.55', '0', '216', '46', '0', '42.4988', '-0.049875', '13', '500', '150500', '0', '3', '3', '27', '2', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ] ] ]', '3', '1', '8', '0', '[ { \"1\": \"1\", \"20\": \"1\" } ]', '2', '1', '1', '6', '1', '', '[ { \"1\": true, \"0\": false, \"3\": true, \"2\": true, \"6\": true } ]', '68');
INSERT INTO `vrp_character` VALUES ('19', '135.62', '1095.17', '13.6094', '0', '0', '100', '0', '0', '0', '0', '55', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0|1|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0', '4', '1', '0', '0', '[ [ ] ]', '0', '0', '0', '2', '1', '', '[ { \"0\": false } ]', '2');
INSERT INTO `vrp_character` VALUES ('20', '540', '-1739', '8.92467', '0', '248', '79', '0', '297.686', '-2.29982', '100', '512104', '117000', '0', '3', '1', '25', '2', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ], [ 31, 484 ] ] ]', '3', '3', '7', '0', '[ { \"1\": \"1\", \"4\": \"1\", \"3\": \"1\" } ]', '7', '5', '5', '5', '1', '', '[ { \"0\": false, \"3\": true, \"6\": true } ]', '1558');
INSERT INTO `vrp_character` VALUES ('1', '2023.31', '-1418.17', '16.9922', '0', '269', '100', '0', '1537.77', '-50.1244', '226', '90238', '0', '0', '3', '6', '0', '0', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ] ] ]', '1', '1', '10', '0', '[ { \"1\": \"1\", \"3\": \"1\", \"20\": \"1\" } ]', '1', '1', '1', '3', '1', '', '[ { \"1\": true, \"0\": false, \"3\": true, \"2\": true, \"6\": true } ]', '4231');
INSERT INTO `vrp_character` VALUES ('22', '3449.95', '-2142.65', '16.8162', '0', '163', '23', '0', '218.783', '-29.9111', '0', '389426', '948039', '0', '3', '0', '25', '0', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ], [ 25, 7 ], [ 30, 12 ] ] ]', '5', '1', '3', '0', '[ { \"13\": \"1\", \"12\": \"1\", \"7\": \"1\", \"1\": \"1\" } ]', '7', '9', '3', '4', '0', '', '[ { \"3\": true, \"0\": false } ]', '998');
INSERT INTO `vrp_character` VALUES ('2', '495.06', '-1730.17', '11.3011', '0', '264', '45', '0', '19.6718', '-10', '117', '203877', '953039', '0', '3', '6', '25', '0', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ], [ 30, 810 ], [ 41, 776 ] ] ]', '4', '3', '8', '0', '[ { \"13\": \"1\", \"12\": \"1\", \"7\": \"1\", \"1\": \"1\" } ]', '4', '4', '2', '4', '1', '', '[ { \"3\": true, \"0\": false } ]', '994');
INSERT INTO `vrp_character` VALUES ('24', '141.554', '-77.1562', '1.57812', '0', '0', '100', '0', '0', '0', '0', '0', '0', '0', '3', '0', '0', null, '0', '0', '0', '0', '0', '[ [ [ 0, 1 ] ] ]', '8', '1', '0', '0', null, '0', '0', '0', '0', '0', '', '[ { \"0\": false } ]', '42');
INSERT INTO `vrp_character` VALUES ('23', '131.378', '-67.6865', '1.57812', '0', '0', '100', '0', '0', '0', '0', '0', '0', '0', '3', '0', '0', null, '0', '0', '0', '0', '0', '[ [ [ 0, 1 ] ] ]', '7', '1', '0', '0', null, '0', '0', '0', '0', '0', '', '[ { \"0\": false } ]', '3');
INSERT INTO `vrp_character` VALUES ('25', '136.336', '-73.1523', '1.42969', '0', '0', '100', '0', '0', '0', '0', '0', '0', '0', '3', '0', '0', null, '0', '0', '0', '0', '0', '[ [ [ 0, 1 ] ] ]', '9', '1', '0', '0', null, '0', '0', '0', '0', '0', '', '[ { \"0\": false } ]', '2');
INSERT INTO `vrp_character` VALUES ('26', '132', '-67.291', '1.57812', '0', '0', '100', '100', '0', '0', '0', '0', '0', '0', '3', '0', '0', null, '0', '0', '0', '0', '0', '[ [ [ 0, 1 ] ] ]', '10', '1', '0', '0', null, '0', '0', '0', '0', '0', '', '[ { \"0\": false } ]', '1');

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
INSERT INTO `vrp_cheatlog` VALUES ('1', 'Sent invalid mileage', '2');
INSERT INTO `vrp_cheatlog` VALUES ('1', 'Sent invalid mileage', '2');
INSERT INTO `vrp_cheatlog` VALUES ('1', 'Sent invalid mileage', '2');
INSERT INTO `vrp_cheatlog` VALUES ('1', 'Sent invalid mileage', '2');
INSERT INTO `vrp_cheatlog` VALUES ('1', 'Sent invalid mileage', '2');
INSERT INTO `vrp_cheatlog` VALUES ('1', 'Sent invalid mileage', '2');
INSERT INTO `vrp_cheatlog` VALUES ('1', 'Sent invalid mileage', '2');

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
INSERT INTO `vrp_gangareas` VALUES ('1', '25', null);
INSERT INTO `vrp_gangareas` VALUES ('2', '25', null);
INSERT INTO `vrp_gangareas` VALUES ('3', '25', null);
INSERT INTO `vrp_gangareas` VALUES ('7', '25', null);
INSERT INTO `vrp_gangareas` VALUES ('6', '25', null);
INSERT INTO `vrp_gangareas` VALUES ('14', '25', null);
INSERT INTO `vrp_gangareas` VALUES ('17', '27', null);
INSERT INTO `vrp_gangareas` VALUES ('12', '25', null);
INSERT INTO `vrp_gangareas` VALUES ('18', '26', null);
INSERT INTO `vrp_gangareas` VALUES ('16', '25', null);
INSERT INTO `vrp_gangareas` VALUES ('15', '25', null);
INSERT INTO `vrp_gangareas` VALUES ('5', '25', null);
INSERT INTO `vrp_gangareas` VALUES ('9', '27', null);

-- ----------------------------
-- Table structure for `vrp_groups`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_groups`;
CREATE TABLE `vrp_groups` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) DEFAULT NULL,
  `Money` int(10) unsigned DEFAULT '0',
  `Karma` int(10) DEFAULT '0',
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM AUTO_INCREMENT=193 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_groups
-- ----------------------------
INSERT INTO `vrp_groups` VALUES ('23', 'Wehrmacht denn sowas', '0', '0');
INSERT INTO `vrp_groups` VALUES ('26', '5edth', '4294967295', '131');
INSERT INTO `vrp_groups` VALUES ('25', '1% Hells Virgins MC', '9492000', '0');
INSERT INTO `vrp_groups` VALUES ('27', 'Kanal-Arbeiter', '158817', '0');

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
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_houses
-- ----------------------------
INSERT INTO `vrp_houses` VALUES ('1', '2091.676757812500000000000000000000', '-1278.489257812500000000000000000000', '26.179687500000000000000000000000', '1', '[ [ ] ]', '1', '25000', '0', '25', '[ [ ] ]');
INSERT INTO `vrp_houses` VALUES ('2', '2111.196289062500000000000000000000', '-1279.395507812500000000000000000000', '25.687500000000000000000000000000', '1', '[ [ ] ]', '0', '35000', '0', '25', '[ [ ] ]');
INSERT INTO `vrp_houses` VALUES ('3', '2100.969726562500000000000000000000', '-1321.155273437500000000000000000000', '25.953125000000000000000000000000', '2', '[ [ ] ]', '0', '15000', '0', '25', '[ [ ] ]');
INSERT INTO `vrp_houses` VALUES ('4', '2126.564453125000000000000000000000', '-1320.563476562500000000000000000000', '26.623929977416992187500000000000', '1', '[ [ ] ]', '0', '150000', '0', '25', '[ [ ] ]');
INSERT INTO `vrp_houses` VALUES ('5', '2132.632812500000000000000000000000', '-1280.931640625000000000000000000000', '25.890625000000000000000000000000', '2', '[ [ ] ]', '0', '75000', '0', '25', '[ [ ] ]');
INSERT INTO `vrp_houses` VALUES ('6', '2150.021484375000000000000000000000', '-1285.411132812500000000000000000000', '24.196470260620117187500000000000', '2', '[ [ ] ]', '0', '60000', '0', '25', '[ [ ] ]');

-- ----------------------------
-- Table structure for `vrp_inventory`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_inventory`;
CREATE TABLE `vrp_inventory` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Items` text NOT NULL,
  `Data` text NOT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_inventory
-- ----------------------------
INSERT INTO `vrp_inventory` VALUES ('1', '[ [ [ 12, 1 ] ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('2', '[ [ [ 4, 99 ], [ 3, 98 ], [ 2, 99 ], [ 1, 99 ], [ 6, 100 ], [ 7, 1 ], [ 10, 100 ], [ 11, 97 ] ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('3', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('4', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('5', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('6', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('7', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('8', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('9', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('10', '[ [ ] ]', '');

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
  `Tunings` text,
  `Mileage` bigint(20) unsigned DEFAULT '0',
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM AUTO_INCREMENT=45 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_vehicles
-- ----------------------------
INSERT INTO `vrp_vehicles` VALUES ('1', '522', '1', '1599.81', '965.6', '10.4226', '270', '4285343799', '1000', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('9', '438', '3', '1598.6', '1084', '10.8005', '326', '4291586057', '998', '[ [ 3 ] ]', '1', '[ [ 1010, 1087, 1085 ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('17', '560', '3', '-4545.12', '-2384.09', '-0.444292', '234', '4292174848', '1000', '[ [ ] ]', '0', '[ [ 1015, 1030, 1033, 1010, 1087, 1080, 1029 ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('13', '560', '1', '1604.3', '974.798', '10.5694', '180', '4285730330', '1000', '[ [ 2 ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('16', '561', '21', '1599.8', '965.6', '10.6686', '270', '4281154101', '1000', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('23', '463', '20', '2734.24', '-2845.04', '11.4367', '144', '4288650644', '1000', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('19', '572', '3', '1606', '1083.29', '10.4385', '326', '4284426027', '994', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('20', '581', '2', '1599.93', '1083.21', '10.4297', '326', '4280231227', '1000', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('21', '560', '2', '1606.11', '1083.15', '12.5582', '326', '4281154101', '782', '[ [ 20, 20 ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('22', '600', '2', '1615.26', '1081.77', '10.5188', '341', '4284836473', '997', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('24', '463', '1', '1609', '961.301', '10.4043', '300', '4288650644', '1000', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('25', '522', '20', '1606.02', '1083.31', '10.5591', '326', '4290625222', '997', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('26', '521', '1', '1817.35', '-1173.45', '23.1418', '198', '4288916934', '1000', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('27', '521', '20', '1613.22', '1079.38', '10.5442', '12', '4280295468', '998', '[ [ 2 ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('28', '463', '2', '1830.69', '-1501.65', '4.33414', '91', '4279640648', '1000', '[ [ 18 ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('29', '518', '20', '1619.4', '1082.15', '10.5404', '0', '4285301909', '991', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('31', '462', '3', '1613.41', '1083.02', '10.4466', '326', '4294967295', '996', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('32', '441', '3', '1619.4', '1083.4', '9.9612', '0', '4294967295', '1000', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('33', '574', '3', '1624.21', '1081.11', '10.5557', '226', '4294967295', '845', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('34', '416', '3', '1598.65', '1095.95', '11.014', '218', '4294967295', '1000', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('35', '568', '3', '1606.6', '1095.5', '10.7227', '218', '4294967295', '1000', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('42', '522', '3', '1614.02', '1094.98', '10.4016', '218', '4278190080', '1000', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('43', '567', '22', '368.081', '-1723.11', '21.5115', '1', '4285301909', '1000', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('40', '527', '20', '1623.9', '1083.6', '10.5191', '0', '4281604638', '1000', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('41', '567', '20', '1597.9', '1095.8', '10.6071', '219', '4289704369', '874', '[ [ ] ]', '1', '[ [ ] ]', '0');
INSERT INTO `vrp_vehicles` VALUES ('44', '561', '18', '1858.95', '-2066.65', '14.7868', '316', '4281154101', '1000', '[ [ ] ]', '1', '[ [ ] ]', '0');
