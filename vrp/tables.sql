/*
Navicat MySQL Data Transfer

Source Server         : eXo
Source Server Version : 50544
Source Host           : 192.168.122.110:3306
Source Database       : vRP

Target Server Type    : MYSQL
Target Server Version : 50544
File Encoding         : 65001

Date: 2016-01-13 01:36:39
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
) ENGINE=MyISAM AUTO_INCREMENT=44 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_account
-- ----------------------------
INSERT INTO `vrp_account` VALUES ('17', 'false', '7365D32189ECBDD8FC818EF537F79BA1', 'AF5A64ED5E8461D824B94F97F006854046A55F27D812BC0F0D452DA872F35DF6', '5', '368989309EB012227161093646E56843', '2015-06-06 13:23:11', null);
INSERT INTO `vrp_account` VALUES ('1', 'Jusonex', '79C501C2830570204C6915BFBDEA9B2E', 'EAAD8B87E27E8258E0D550F6F6816675C65A5748FCC72D880E0F68502E01FD2C', '5', 'C4586E3449E6ECC0FA1FD8B269E2A873', '2016-01-12 20:20:35', null);
INSERT INTO `vrp_account` VALUES ('2', 'Doneasty', '', '994FCB227681CFD6CA119F0A30553FCA590AECF5EA2617C9E4AF934198B85956', '4', '239A5FCD692C6C4D8ABD55F3C00E4D94', '2016-01-12 18:49:12', null);
INSERT INTO `vrp_account` VALUES ('3', 'StiviK', '', 'DAF9854A6D826EA2B31E2336ECD0875836E4EFAD6CA23349BE083E68FE34A05E', '5', '71B947A4FF2929B905F4EE55B9182F02', '2016-01-12 22:50:28', 'stivik@v-roleplay.net');
INSERT INTO `vrp_account` VALUES ('18', 'Toxsi', '', '530AF54CE47C502654D30C74A6B4CAF5861DB3AF5D307187A8F99C150D4BCF4D', '2', '28D715400EC6C9F57DEB328D003ADA43', '2015-05-19 14:37:28', null);
INSERT INTO `vrp_account` VALUES ('19', 'sbx320', '', '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92', '5', null, null, null);
INSERT INTO `vrp_account` VALUES ('20', 'Johnny', '', 'C549ADDC80367E17FD46B5B6A094EE7F9958D5C92FBA35F519E64C5A4304DDE6', '2', 'F4274B79FE188EFA7C4680896AB9F282', '2015-06-06 00:58:39', null);
INSERT INTO `vrp_account` VALUES ('21', 'Gibaex', '', 'C549ADDC80367E17FD46B5B6A094EE7F9958D5C92FBA35F519E64C5A4304DDE6', '0', 'F4274B79FE188EFA7C4680896AB9F282', '2015-06-05 20:06:02', null);
INSERT INTO `vrp_account` VALUES ('22', 'Sarcasm', '', '5994471ABB01112AFCC18159F6CC74B4F511B99806DA59B3CAF5A9C173CACFC5', '3', 'D43F3EA89CAFB26F6AA8EE0EDA339A53', '2015-04-07 18:53:11', null);
INSERT INTO `vrp_account` VALUES ('23', 'TestUser4', '79C501C2830570204C6915BFBDEA9B2E', 'EAAD8B87E27E8258E0D550F6F6816675C65A5748FCC72D880E0F68502E01FD2C', '0', '', null, 'jusonex@v-roleplay.net');
INSERT INTO `vrp_account` VALUES ('24', 'TestUser5', '5CC91EB66F1963FC8DBAC6D47935151F', '3286AFDBFBB08817A88C6CC58767E281199CBA11E17DF5E4C7D0369C57ED81E3', '0', 'C4586E3449E6ECC0FA1FD8B269E2A873', '2015-04-20 14:35:49', 'doneasty@web.de');
INSERT INTO `vrp_account` VALUES ('25', 'Poof', 'EAAB5A103F24EA75A8AD87251652F167', '4CB0045D6E15D2376A9EAFB85CC4D861961CD0076EC244F28B884944779C2262', '0', 'F885F6BBB6A49FA4BD3D7EBC6C78CB84', '2015-05-18 21:21:31', 'poof@sbx320.net');
INSERT INTO `vrp_account` VALUES ('26', 'Yetii', '8CD338D51246B23F935A36E76EFDDB12', '5C49A89AD8F6AD54929308DB3A2947EAD9E48A20A526742FC223DC9FFFE0E4FB', '0', 'C8631CD688CD35A3192BA7F5243BAD62', '2015-06-06 12:39:51', 'yetistone12@gmx.de');
INSERT INTO `vrp_account` VALUES ('27', 'HEXASHOT', '3FE6FB34111C2DC08B17EB9DA9A85313', 'AD09CBECB7166C4C071987A86BD3183A1C17A3CDFE5DD0B29EB3D1BBD4D4DE3E', '0', 'A93331720EDD7DED935B4516E79F0284', '2015-06-06 12:46:21', 'hexashot@web.de');
INSERT INTO `vrp_account` VALUES ('28', 'Simpsons183', '27B2D0A6CBD72146E97C376F68BADD23', '5FB5EFE66EC63D0807C45A5EA55B51868BE905D1394DD52E2D127ABF985B2FE6', '0', '5C61D77DDB092AF8FAE6A7FA7AA55C02', '2015-06-06 12:30:30', 'albandietze1999@gmx.de');
INSERT INTO `vrp_account` VALUES ('29', 'Harrikan', 'DC186DB031FDF13683B3509108392A29', 'AFF556A2CE7979F5DBA736B93B5876AB56182896A0B9EC95B77377C48AFF81E8', '0', '1488BCD6D847073EA7D6D45435ED4E42', '2015-06-06 10:57:34', 'harrikan@web.de');
INSERT INTO `vrp_account` VALUES ('30', '[eXo]Stumpy', 'A67B7F80B14D0E0949EC8BE646BC2749', 'C8AEA0C5E92AB04380680526DE839F08F2DF93A01F0914AB8EC429F05FD344C7', '5', 'E8033EBE8177E7000D124B96FE892584', '2016-01-13 00:44:36', 'danieltaucher@gmail.com');
INSERT INTO `vrp_account` VALUES ('31', '[eXo]xXKing', '4AD644ABF7A17CD262B11B7C98CE6DD8', 'FD294590C5E550B4EE493C3BF6AE2C77F09849DB6717DB513AAAC2A4421F96FB', '5', '208FD89BECE7A15DFA58D7BD46DB24B2', '2016-01-12 20:38:40', 'xxking@gmx.de');
INSERT INTO `vrp_account` VALUES ('32', 'Heisi', '9F5E464E24385B1AD85A6080CC8150EF', '58B67E40B01BBC0C97494E27A34B00ADCD73EF665242A0FAF4773C895DABEB10', '5', 'E978B61F84DF3BC903A122FCCF52B584', '2016-01-12 17:55:50', null);
INSERT INTO `vrp_account` VALUES ('33', '[eXo]Chris', '4BE23F8D60D51E67251A331F11D7337F', 'E17D7A06746B79F879380CAE6D976B0DAF302B65D0A9CDE730E61362BB0806AA', '0', '7AAEFF7536DF77B19CCC518E52BA2594', '2016-01-12 18:51:01', 'mail@bach-christoph.com');
INSERT INTO `vrp_account` VALUES ('34', '[eXo]Clausus', '1962EFBB401D8BE07D3DBBA612A5FF80', 'C4A8FA2F88F01678A3318A58150B148CBEF46F668624D015544A480CECA29329', '0', '42CB6B6D021A4D119D8715965CE4D183', '2016-01-12 20:07:54', 'hotmail@hotmail.de');
INSERT INTO `vrp_account` VALUES ('35', '[eXo]LAURIIST4AR', 'BBB67AD1A3BE1899D03FF78869A85A39', '371735BC9C6B3BE870384AAF1D6BF1CAC5A96090F43E907129597F3C6F486730', '0', '1B870EC25B5AC9360169C4015A2165E3', '2016-01-12 19:49:12', 'lauriist4ar@hotmail.com');
INSERT INTO `vrp_account` VALUES ('36', '[eXo]Phil', 'D6B1CF20D95C044AB20EFE9106C71754', '78BEEA67F40228690A58CDE03198901AA196018E941F535E38D2C4D550AD89E9', '0', 'FA3751D9B491FE74489238C8EF151444', '2016-01-13 00:54:57', 'philipp.kirstein@web.de');
INSERT INTO `vrp_account` VALUES ('37', '[eXo]StrongVan', '2054FE8B39CA39D00D67917BDD1DBDEC', 'F57868ACC8A8B912006AAFBAAF4E7CD035B290B949D719766AE5A9DC548C7F64', '0', '2CF585F86E6A485A2F21C35C30EDDAB2', '2016-01-12 20:20:58', 'sunniqht@web.de');
INSERT INTO `vrp_account` VALUES ('38', '[eXo]Bonez', 'EB304E63992F67ED45BBA41D70566D26', 'E15AAED720EB3FA8567B727580602D0919DD98394AA5CF0D0288A5FFD3271A8F', '0', '705CE13430C9E17EDDC4685B53E36093', '2016-01-12 20:50:19', 'receful@gmail.com');
INSERT INTO `vrp_account` VALUES ('39', '[eXo]Don_Leone', 'AD41B8B809F3724F92B89FA79E733ADD', 'ED370A2A740E19ABB90A1DC371AD78FC48AD8C52E01D56BC74A2A415FCB88E6A', '0', '0C2738A7865C7103E8B2A4D489EFF9F4', '2016-01-13 00:42:23', 'lukab25@gmail.com');
INSERT INTO `vrp_account` VALUES ('40', '[eXo]John_Rambo', '5EB06691BDD55F7F605CE8A22B932BD6', '10EF4CA1D11984432130D24A8ED7B640C39363238961E7F58A7BDBDD8DA8792F', '0', '975FD14B31B50A263F90FBA98ED89CA1', '2016-01-12 21:15:30', 'alexanderkrauss93@gmail.com');
INSERT INTO `vrp_account` VALUES ('41', '[eXo]AfGun', 'AC5090FB03628F1CD452D10585FB4410', '8ED5BBE87CBF543622C05B230899C42915CFC6E66A623C094A105323758D27D3', '0', '1AE2DD2398BACC90E296C36D2F57A053', '2016-01-13 01:35:32', 'elias-n1@live.com');
INSERT INTO `vrp_account` VALUES ('42', '[eXo]Janni_Morita', '5DA79B9B2773E9C64707AF6119F7CC4E', '83449C818045C59B9C7CDC7200DFDFBD79B1AA8C6E88D5185241834137336690', '0', 'A816941145C55E377A0EC0A2E1920EA1', '2016-01-12 20:26:14', 'Jannik.paul@rs-kennedy.de');
INSERT INTO `vrp_account` VALUES ('43', '[eXo]Gamer64', 'B64EEB8FDB865BE975B1AC38E4B6304B', '861E726250B80C71A62CA32F37144E23E356AB0A74F06B766E2508C9EB0AE711', '0', '9871526C9034F4F51BDF42311B8BD542', '2016-01-12 20:33:23', 'struckaaron@web.de');

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
INSERT INTO `vrp_bank_statements` VALUES ('1', '4', '5000', '2015-05-14 00:05:04');
INSERT INTO `vrp_bank_statements` VALUES ('1', '4', '10000', '2015-05-14 00:05:11');
INSERT INTO `vrp_bank_statements` VALUES ('2', '4', '100000', '2015-05-25 14:59:02');
INSERT INTO `vrp_bank_statements` VALUES ('2', '3', '1000000', '2015-06-05 20:01:31');
INSERT INTO `vrp_bank_statements` VALUES ('26', '4', '758', '2015-06-05 20:48:51');
INSERT INTO `vrp_bank_statements` VALUES ('27', '4', '322', '2015-06-05 20:48:53');
INSERT INTO `vrp_bank_statements` VALUES ('28', '4', '947', '2015-06-05 20:48:59');
INSERT INTO `vrp_bank_statements` VALUES ('26', '4', '66909', '2015-06-05 21:20:33');
INSERT INTO `vrp_bank_statements` VALUES ('26', '3', '10000', '2015-06-05 21:50:27');
INSERT INTO `vrp_bank_statements` VALUES ('2', '4', '2900', '2015-06-06 10:56:56');
INSERT INTO `vrp_bank_statements` VALUES ('27', '4', '5148', '2015-06-06 13:11:23');
INSERT INTO `vrp_bank_statements` VALUES ('31', '4', '3933', '2016-01-12 19:03:36');
INSERT INTO `vrp_bank_statements` VALUES ('39', '4', '900000', '2016-01-12 21:00:09');
INSERT INTO `vrp_bank_statements` VALUES ('39', '4', '50000', '2016-01-13 01:21:49');

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
  `CompanyRank` int(11) NOT NULL DEFAULT '0',
  `FactionId` int(11) NOT NULL,
  `FactionRank` int(11) NOT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_character
-- ----------------------------
INSERT INTO `vrp_character` VALUES ('17', '706.309', '-481.976', '16.1875', '0', '0', '0', '70', '0', '1.5', '-0.15', '5', '24', '0', '0', '3', '0', '0', '0', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ] ] ]', '1', '0', '0', '0', '0', '0', '[ [ ] ]', '0', '0', '0', '0', '1', '', '[ { \"20\": true, \"0\": false, \"6\": true } ]', '4558', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('21', '2666.12', '-1843.64', '11.4632', '0', '0', '0', '100', '0', '0', '0', '0', '0', '0', '0', '3', '0', '0', '0', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ] ] ]', '8', '0', '0', '8', '0', '0', '[ [ ] ]', '0', '0', '2', '0', '1', '', '[ { \"9\": true, \"0\": false, \"3\": true, \"17\": true, \"19\": true, \"49\": true, \"45\": true, \"6\": true } ]', '102', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('3', '1523.6', '-1677.56', '13.5469', '0', '0', '200', '80', '0', '3', '-0.3', '25', '55361', '0', '1', '3', '0', '5', '2', '0', '0', '0', '0', '0', '[[[0,1],[41,138]]]', '2', '0', '0', '2', '0', '0', '[[\"1\"]]', '0', '0', '7', '0', '1', '[[]]', '[{\"40\":true,\"47\":true,\"46\":true,\"45\":true,\"48\":true,\"49\":true,\"0\":false,\"3\":true,\"19\":true,\"6\":true,\"9\":true,\"21\":true,\"17\":true,\"31\":true,\"12\":true,\"11\":true,\"13\":true}]', '6728', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('18', '1219.24', '-212.25', '34.587', '0', '0', '216', '100', '0', '0', '0', '0', '0', '0', '0', '3', '0', '0', '0', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ] ] ]', '3', '0', '0', '8', '0', '0', '[ { \"1\": \"1\", \"20\": \"1\" } ]', '0', '0', '1', '0', '1', '', '[ { \"1\": true, \"0\": false, \"3\": true, \"2\": true, \"11\": true, \"6\": true } ]', '81', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('19', '135.62', '1095.17', '13.6094', '0', '0', '0', '100', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0|1|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0', '4', '0', '0', '0', '0', '0', '[ [ ] ]', '0', '0', '0', '0', '1', '', '[ { \"0\": false } ]', '2', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('20', '1100.28', '-1406.92', '13.4516', '0', '0', '248', '80', '0', '0', '0', '33', '788', '0', '0', '3', '1', '0', '0', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ] ] ]', '3', '0', '0', '1', '0', '0', '[ { \"1\": \"1\", \"4\": \"1\", \"3\": \"1\" } ]', '0', '0', '5', '1', '1', '', '[ { \"0\": false, \"3\": true, \"46\": true, \"45\": true, \"6\": true, \"49\": true, \"17\": true, \"13\": true, \"12\": true, \"11\": true } ]', '1852', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('1', '1541.22', '-1475.21', '63.8594', '0', '0', '289', '16', '0', '0.833333', '-100.083', '41', '1000000', '0', '0', '3', '0', '0', '0', '0', '0', '0', '0', '0', '[[[0,1],[30,75],[38,9999]]]', '1', '1', '0', '8', '0', '0', '[{\"1\":\"1\",\"3\":\"1\",\"20\":\"1\"}]', '10', '10', '3', '10', '1', null, '[{\"1\":true,\"0\":false,\"3\":true,\"2\":true,\"19\":true,\"45\":true,\"6\":true,\"9\":true,\"49\":true,\"17\":true,\"13\":true,\"12\":true,\"11\":true,\"20\":true}]', '6462', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('22', '3449.95', '-2142.65', '16.8162', '0', '0', '163', '100', '0', '0', '0', '0', '0', '0', '0', '3', '0', '0', '0', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ], [ 25, 7 ], [ 30, 12 ] ] ]', '5', '0', '0', '3', '0', '0', '[ { \"13\": \"1\", \"12\": \"1\", \"7\": \"1\", \"1\": \"1\" } ]', '0', '0', '3', '0', '0', '', '[ { \"3\": true, \"0\": false } ]', '998', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('2', '2077.53', '-1474.15', '23.8287', '0', '0', '241', '50', '0', '10.4999', '-100', '538', '1000000', '2900', '0', '3', '0', '0', '0', '0', '0', '0', '0', '0', '[[[0,1]]]', '4', '0', '0', '1', '0', '0', '[{\"1\":\"1\",\"3\":\"1\",\"13\":\"1\",\"12\":\"1\",\"7\":\"1\"}]', '10', '10', '3', '10', '1', null, '[{\"0\":false,\"3\":true,\"45\":true,\"49\":true,\"13\":true,\"17\":true,\"20\":true,\"21\":true,\"11\":true,\"12\":true}]', '2098', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('24', '141.554', '-77.1562', '1.57812', '0', '0', '0', '100', '0', '0', '0', '0', '0', '0', '0', '3', '0', '0', '0', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ] ] ]', '8', '0', '0', '0', '0', '0', null, '0', '0', '0', '0', '0', '', '[ { \"0\": false } ]', '42', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('23', '131.378', '-67.6865', '1.57812', '0', '0', '0', '100', '0', '0', '0', '0', '0', '0', '0', '3', '0', '0', '0', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ] ] ]', '7', '0', '0', '0', '0', '0', null, '0', '0', '0', '0', '0', '', '[ { \"0\": false } ]', '3', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('25', '2011.37', '-1416.38', '16.9922', '0', '0', '0', '100', '0', '0', '0', '0', '0', '0', '0', '3', '0', '0', '0', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ] ] ]', '9', '0', '0', '2', '0', '0', null, '0', '0', '0', '0', '1', '', '[ { \"0\": false, \"3\": true, \"17\": true, \"13\": true, \"12\": true, \"11\": true, \"6\": true } ]', '113', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('26', '2243.62', '-1656.31', '15.2881', '0', '0', '164', '65', '0', '20', '2', '12', '12357', '0', '0', '3', '6', '0', '0', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ], [ 29, 264 ] ] ]', '10', '0', '0', '1', '0', '0', null, '6', '0', '1', '4', '0', '', '[ { \"0\": false, \"45\": true, \"6\": true, \"49\": true, \"31\": true, \"17\": true, \"13\": true, \"12\": true, \"11\": true, \"20\": true } ]', '257', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('27', '2006.46', '-1452.69', '13.5547', '0', '0', '185', '63', '0', '3', '-0.3', '146', '0', '5148', '0', '3', '0', '0', '0', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ] ] ]', '14', '0', '0', '1', '0', '0', null, '0', '1', '0', '1', '0', '', '[ { \"0\": false, \"3\": true, \"6\": true, \"9\": true, \"49\": true, \"17\": true, \"13\": true, \"12\": true, \"11\": true, \"20\": true } ]', '201', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('28', '1914.69', '-1453.18', '13.5469', '0', '0', '163', '95', '0', '30', '3', '254', '23153', '0', '0', '3', '0', '0', '0', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ] ] ]', '16', '0', '0', '1', '0', '0', '[ { \"4\": \"1\" } ]', '2', '4', '2', '5', '0', '', '[ { \"0\": false, \"3\": true, \"45\": true, \"6\": true, \"49\": true, \"17\": true, \"13\": true, \"12\": true, \"11\": true, \"20\": true } ]', '351', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('29', '1312.41', '-1568.69', '12.8948', '0', '0', '195', '100', '0', '0', '0', '0', '0', '0', '0', '3', '0', '0', '0', '0', '0', '0', '0', '0', '[ [ [ 0, 1 ] ] ]', '18', '0', '0', '1', '0', '0', null, '0', '0', '0', '0', '0', '', '[ { \"0\": false, \"3\": true, \"47\": true, \"9\": true, \"49\": true, \"17\": true, \"20\": true, \"12\": true, \"11\": true, \"13\": true } ]', '109', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('30', '2602.4', '-2116.54', '13.5469', '0', '0', '0', '80', '0', '1.5', '-100', '30', '1000000', '0', '0', '3', '0', '3', '2', '0', '0', '0', '0', '0', '[[[0,1]]]', '20', '1', '0', '8', '0', '0', null, '10', '10', '0', '10', '0', '[[]]', '[{\"0\":false,\"49\":true,\"6\":true}]', '360', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('31', '1515.26', '-1677.05', '14.0469', '0', '0', '0', '47', '0', '16530.9', '-100.993', '78', '23800', '3933', '1', '3', '4', '0', '0', '0', '0', '0', '0', '0', '[[[0,1],[2,1],[24,9985]]]', '22', '3', '0', '8', '0', '0', '[{\"13\":\"1\"}]', '10', '50', '0', '0', '0', '[[]]', '[{\"9\":true,\"49\":true,\"3\":true,\"0\":false,\"19\":true,\"47\":true,\"45\":true,\"6\":true}]', '228', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('32', '2029.32', '-1430.24', '17.0657', '0', '0', '0', '100', '0', '0', '0', '10', '15500', '0', '0', '3', '3', '3', '1', '0', '0', '0', '0', '0', '[[[0,1],[30,330]]]', '24', '0', '0', '0', '0', '0', null, '0', '0', '0', '10', '0', '[[]]', '[{\"0\":false,\"11\":true,\"3\":true}]', '45', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('33', '1522.78', '-1739.52', '13.5469', '0', '0', '0', '54', '0', '0', '-100', '548', '994904', '0', '0', '3', '0', '0', null, '0', '0', '0', '0', '0', '[[[0,1]]]', '26', '0', '0', '0', '0', '0', '[{\"13\":\"1\"}]', '10', '10', '0', '10', '0', '[[]]', '[{\"49\":true,\"3\":true,\"0\":false,\"12\":true,\"45\":true,\"6\":true}]', '157', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('34', '1457.91', '-1479.69', '13.5469', '0', '0', '0', '79', '0', '1.5', '-100', '50', '981360', '0', '0', '3', '6', '0', null, '0', '0', '0', '0', '0', '[[[0,1],[3,1],[29,120],[30,18]]]', '28', '0', '0', '0', '0', '0', null, '10', '10', '0', '10', '0', '[[]]', '[{\"0\":false,\"3\":true,\"17\":true,\"49\":true,\"12\":true,\"45\":true,\"6\":true}]', '104', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('35', '1384.91', '-915.344', '34.3619', '0', '0', '0', '93', '0', '0', '-100', '37', '994699', '0', '0', '3', '1', '0', null, '0', '0', '0', '0', '0', '[[[0,1]]]', '30', '0', '0', '0', '0', '0', null, '10', '10', '0', '10', '0', '[[]]', '[{\"0\":false,\"49\":true,\"12\":true,\"6\":true}]', '101', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('36', '1645.78', '-1666.97', '21.4375', '0', '0', '0', '95', '0', '1511.5', '301', '17', '944160', '0', '0', '3', '4', '6', '1', '0', '0', '0', '0', '0', '[[[0,1]]]', '32', '0', '0', '0', '0', '0', '[{\"4\":\"1\"}]', '10', '10', '2', '10', '0', '[[]]', '[{\"9\":true,\"0\":false,\"3\":true,\"11\":true,\"47\":true,\"12\":true,\"45\":true,\"49\":true}]', '92', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('37', '1537.79', '-1677.33', '6.9336', '0', '0', '0', '76', '0', '1.5', '150', '58', '899721', '0', '0', '3', '4', '0', null, '0', '0', '0', '0', '0', '[[[0,1],[3,1],[29,166]]]', '34', '0', '0', '0', '0', '0', null, '10', '10', '0', '10', '1', '[[]]', '[{\"0\":false,\"49\":true,\"3\":true,\"17\":true,\"9\":true,\"12\":true,\"45\":true,\"6\":true}]', '65', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('38', '-2021.5', '509.468', '35.4405', '0', '0', '0', '100', '0', '0', '-100', '35', '986080', '0', '0', '3', '1', '0', null, '0', '0', '0', '0', '0', '[[[0,1],[29,1260],[31,800]]]', '36', '0', '0', '0', '0', '0', null, '10', '10', '0', '10', '0', '[[]]', '[{\"12\":true,\"0\":false,\"3\":true,\"49\":true}]', '54', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('39', '516.967', '-1392.53', '15.745', '0', '0', '269', '35', '0', '2.33333', '-100.083', '84', '7962', '950000', '0', '3', '8', '6', '2', '0', '0', '0', '0', '0', '[[[0,1]]]', '38', '0', '0', '0', '0', '0', null, '10', '10', '0', '10', '0', '[[]]', '[{\"0\":false,\"3\":true,\"17\":true,\"49\":true,\"12\":true,\"45\":true,\"11\":true}]', '83', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('40', '2028', '-1405', '17.925', '0', '0', '0', '100', '0', '1500', '300', '53', '781523', '0', '0', '3', '4', '0', null, '0', '0', '0', '0', '0', '[[[0,1]]]', '40', '1', '0', '0', '0', '0', null, '10', '10', '0', '10', '0', '[[]]', '[{\"9\":true,\"0\":false,\"3\":true,\"47\":true,\"49\":true,\"45\":true,\"6\":true}]', '57', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('41', '1769.33', '-1494.51', '11.7212', '2', '0', '0', '69', '0', '3', '-0.3', '80', '691680', '0', '0', '3', '3', '0', null, '0', '0', '0', '0', '0', '[[[0,1],[9,1],[29,240],[31,446]]]', '42', '1', '0', '9', '0', '0', null, '10', '10', '0', '10', '1', '[[]]', '[{\"49\":true,\"0\":false,\"31\":true,\"12\":true,\"11\":true,\"45\":true}]', '111', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('42', '1525.54', '-1731.61', '13.5237', '0', '0', '0', '100', '0', '1.5', '-0.15', '17', '958248', '0', '0', '3', '0', '0', null, '0', '0', '0', '0', '0', '[[[0,1]]]', '44', '0', '0', '0', '0', '0', null, '10', '10', '0', '10', '0', '[[]]', '[{\"0\":false,\"12\":true,\"45\":true}]', '22', '0', '0', '0', '0');
INSERT INTO `vrp_character` VALUES ('43', '1593.42', '-1688.06', '5.89062', '0', '0', '0', '100', '0', '0', '150', '25', '999648', '0', '0', '3', '0', '0', null, '0', '0', '0', '0', '0', '[[[0,1]]]', '46', '0', '0', '0', '0', '0', null, '10', '10', '0', '0', '0', '[[]]', '[{\"0\":false,\"49\":true}]', '51', '0', '0', '0', '0');

-- ----------------------------
-- Table structure for `vrp_cheatlog`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_cheatlog`;
CREATE TABLE `vrp_cheatlog` (
  `UserId` int(10) unsigned NOT NULL,
  `Name` varchar(25) NOT NULL,
  `Severity` tinyint(1) unsigned NOT NULL,
  KEY `UserId` (`UserId`)
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
INSERT INTO `vrp_cheatlog` VALUES ('2', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('2', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('20', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('20', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('20', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('20', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('20', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('1', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('1', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('1', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('1', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('1', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('20', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('20', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('20', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('20', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('2', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('1', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('20', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('20', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('20', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('20', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('20', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('26', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('1', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('27', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('27', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('27', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('27', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('29', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('29', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('29', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('29', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('29', 'Triggered collect event o', '2');
INSERT INTO `vrp_cheatlog` VALUES ('29', 'Triggered collect event o', '2');

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
INSERT INTO `vrp_gangareas` VALUES ('4', '5', null);

-- ----------------------------
-- Table structure for `vrp_groups`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_groups`;
CREATE TABLE `vrp_groups` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) DEFAULT NULL,
  `Tag` varchar(5) DEFAULT NULL,
  `Money` int(10) unsigned DEFAULT '0',
  `Karma` int(10) DEFAULT '0',
  `lastNameChange` int(10) DEFAULT '0',
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_groups
-- ----------------------------
INSERT INTO `vrp_groups` VALUES ('3', 'eXo', null, '30000', '0', '0');
INSERT INTO `vrp_groups` VALUES ('6', 'ASSIS', null, '40000', '151', '0');
INSERT INTO `vrp_groups` VALUES ('5', 'Test', null, '500', '0', '0');

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
INSERT INTO `vrp_houses` VALUES ('2', '2111.196289062500000000000000000000', '-1279.395507812500000000000000000000', '25.687500000000000000000000000000', '1', '[ [ ] ]', '3', '35000', '0', '25', '[ [ ] ]');
INSERT INTO `vrp_houses` VALUES ('3', '2100.969726562500000000000000000000', '-1321.155273437500000000000000000000', '25.953125000000000000000000000000', '2', '[ [ ] ]', '3', '15000', '0', '25', '[ [ ] ]');
INSERT INTO `vrp_houses` VALUES ('4', '2126.564453125000000000000000000000', '-1320.563476562500000000000000000000', '26.623929977416992000000000000000', '1', '[ [ ] ]', '3', '150000', '0', '25', '[ [ ] ]');
INSERT INTO `vrp_houses` VALUES ('5', '2132.632812500000000000000000000000', '-1280.931640625000000000000000000000', '25.890625000000000000000000000000', '2', '[ [ ] ]', '3', '75000', '0', '25', '[ [ ] ]');
INSERT INTO `vrp_houses` VALUES ('6', '2150.021484375000000000000000000000', '-1285.411132812500000000000000000000', '24.196470260620117000000000000000', '2', '[ [ ] ]', '3', '60000', '0', '25', '[ [ ] ]');

-- ----------------------------
-- Table structure for `vrp_inventory`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_inventory`;
CREATE TABLE `vrp_inventory` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Items` text NOT NULL,
  `Data` text NOT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM AUTO_INCREMENT=47 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_inventory
-- ----------------------------
INSERT INTO `vrp_inventory` VALUES ('1', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('2', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('3', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('4', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('5', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('6', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('7', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('8', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('9', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('10', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('11', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('12', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('13', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('14', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('15', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('16', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('17', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('18', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('19', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('20', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('21', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('22', '[ [ [ 3, 1 ], [ 3, 1 ] ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('23', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('24', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('25', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('26', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('27', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('28', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('29', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('30', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('31', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('32', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('33', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('34', '[ [ [ 3, 1 ] ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('35', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('36', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('37', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('38', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('39', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('40', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('41', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('42', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('43', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('44', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('45', '[ [ ] ]', '');
INSERT INTO `vrp_inventory` VALUES ('46', '[ [ ] ]', '');

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
-- Table structure for `vrp_stats_money`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_stats_money`;
CREATE TABLE `vrp_stats_money` (
  `UserId` int(10) unsigned NOT NULL,
  `Amount` bigint(20) NOT NULL,
  `Description` text,
  `Date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_stats_money
-- ----------------------------
INSERT INTO `vrp_stats_money` VALUES ('32', '500', '=[C]:-1', '2016-01-12 16:51:00');
INSERT INTO `vrp_stats_money` VALUES ('32', '500', '=[C]:-1', '2016-01-12 16:51:04');
INSERT INTO `vrp_stats_money` VALUES ('32', '500', '=[C]:-1', '2016-01-12 16:51:05');
INSERT INTO `vrp_stats_money` VALUES ('32', '50000', '=[C]:-1', '2016-01-12 16:51:08');
INSERT INTO `vrp_stats_money` VALUES ('32', '-6000', '@vrp/server/classes/Vehicles/VehicleTuning.lua:171', '2016-01-12 16:51:44');
INSERT INTO `vrp_stats_money` VALUES ('30', '50000', '=[C]:-1', '2016-01-12 16:57:10');
INSERT INTO `vrp_stats_money` VALUES ('30', '50000', '=[C]:-1', '2016-01-12 16:57:26');
INSERT INTO `vrp_stats_money` VALUES ('30', '50000', '=[C]:-1', '2016-01-12 16:57:27');
INSERT INTO `vrp_stats_money` VALUES ('30', '50000', '=[C]:-1', '2016-01-12 16:57:28');
INSERT INTO `vrp_stats_money` VALUES ('30', '50000', '=[C]:-1', '2016-01-12 16:57:28');
INSERT INTO `vrp_stats_money` VALUES ('30', '-30000', '@vrp/server/classes/Groups/GroupManager.lua:97', '2016-01-12 16:57:38');
INSERT INTO `vrp_stats_money` VALUES ('32', '-15000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-12 16:58:35');
INSERT INTO `vrp_stats_money` VALUES ('32', '-15000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-12 16:58:38');
INSERT INTO `vrp_stats_money` VALUES ('30', '-200000', '@vrp/server/classes/Vehicles/VehicleManager.lua:365', '2016-01-12 17:49:09');
INSERT INTO `vrp_stats_money` VALUES ('30', '-17000', '@vrp/server/classes/Vehicles/VehicleManager.lua:187', '2016-01-12 17:52:29');
INSERT INTO `vrp_stats_money` VALUES ('31', '50000', '=[C]:-1', '2016-01-12 17:53:08');
INSERT INTO `vrp_stats_money` VALUES ('31', '-14000', '@vrp/server/classes/Vehicles/VehicleManager.lua:187', '2016-01-12 17:53:23');
INSERT INTO `vrp_stats_money` VALUES ('31', '-100', '@vrp/server/classes/Vehicles/VehicleManager.lua:295', '2016-01-12 17:56:33');
INSERT INTO `vrp_stats_money` VALUES ('31', '-30000', '@vrp/server/classes/Groups/GroupManager.lua:97', '2016-01-12 17:58:49');
INSERT INTO `vrp_stats_money` VALUES ('31', '-1', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-12 17:58:59');
INSERT INTO `vrp_stats_money` VALUES ('31', '-1', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-12 18:11:38');
INSERT INTO `vrp_stats_money` VALUES ('31', '-1', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-12 18:11:38');
INSERT INTO `vrp_stats_money` VALUES ('31', '-1', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-12 18:11:39');
INSERT INTO `vrp_stats_money` VALUES ('31', '-1', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-12 18:11:39');
INSERT INTO `vrp_stats_money` VALUES ('31', '-1', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-12 18:11:39');
INSERT INTO `vrp_stats_money` VALUES ('31', '-1', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-12 18:11:39');
INSERT INTO `vrp_stats_money` VALUES ('31', '-1', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-12 18:11:39');
INSERT INTO `vrp_stats_money` VALUES ('31', '-1', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-12 18:11:39');
INSERT INTO `vrp_stats_money` VALUES ('31', '1', '=(tail call):-1', '2016-01-12 18:11:40');
INSERT INTO `vrp_stats_money` VALUES ('31', '-1', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-12 18:11:40');
INSERT INTO `vrp_stats_money` VALUES ('31', '-1', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-12 18:11:41');
INSERT INTO `vrp_stats_money` VALUES ('31', '5', '=(tail call):-1', '2016-01-12 18:11:52');
INSERT INTO `vrp_stats_money` VALUES ('31', '-2000', '@vrp/server/classes/Inventory/ItemShops.lua:44', '2016-01-12 18:23:34');
INSERT INTO `vrp_stats_money` VALUES ('31', '-248', '@vrp/server/classes/Vehicles/PayNSpray.lua:29', '2016-01-12 18:39:30');
INSERT INTO `vrp_stats_money` VALUES ('2', '120', '=(tail call):-1', '2016-01-12 18:59:45');
INSERT INTO `vrp_stats_money` VALUES ('31', '-1', '@vrp/server/classes/Player/PlayerManager.lua:121', '2016-01-12 19:01:38');
INSERT INTO `vrp_stats_money` VALUES ('2', '1', '=(tail call):-1', '2016-01-12 19:01:38');
INSERT INTO `vrp_stats_money` VALUES ('31', '-3933', '@vrp/server/classes/Player/BankManager.lua:51', '2016-01-12 19:03:36');
INSERT INTO `vrp_stats_money` VALUES ('31', '200', '@vrp/server/classes/Jobs/JobPolice.lua:150', '2016-01-12 19:24:31');
INSERT INTO `vrp_stats_money` VALUES ('33', '105', '=(tail call):-1', '2016-01-12 20:33:26');
INSERT INTO `vrp_stats_money` VALUES ('39', '240', '=(tail call):-1', '2016-01-12 20:33:28');
INSERT INTO `vrp_stats_money` VALUES ('39', '0', '=(tail call):-1', '2016-01-12 20:33:34');
INSERT INTO `vrp_stats_money` VALUES ('39', '0', '=(tail call):-1', '2016-01-12 20:33:34');
INSERT INTO `vrp_stats_money` VALUES ('42', '285', '=(tail call):-1', '2016-01-12 20:33:56');
INSERT INTO `vrp_stats_money` VALUES ('35', '60', '=(tail call):-1', '2016-01-12 20:34:49');
INSERT INTO `vrp_stats_money` VALUES ('35', '0', '=(tail call):-1', '2016-01-12 20:34:56');
INSERT INTO `vrp_stats_money` VALUES ('41', '45', '=(tail call):-1', '2016-01-12 20:34:59');
INSERT INTO `vrp_stats_money` VALUES ('35', '0', '=(tail call):-1', '2016-01-12 20:35:11');
INSERT INTO `vrp_stats_money` VALUES ('37', '45', '=(tail call):-1', '2016-01-12 20:35:23');
INSERT INTO `vrp_stats_money` VALUES ('41', '-8000', '@vrp/server/classes/Vehicles/VehicleManager.lua:187', '2016-01-12 20:37:28');
INSERT INTO `vrp_stats_money` VALUES ('40', '-8000', '@vrp/server/classes/Vehicles/VehicleManager.lua:187', '2016-01-12 20:37:28');
INSERT INTO `vrp_stats_money` VALUES ('42', '-19000', '@vrp/server/classes/Vehicles/VehicleManager.lua:187', '2016-01-12 20:37:30');
INSERT INTO `vrp_stats_money` VALUES ('1', '-8000', '@vrp/server/classes/Vehicles/VehicleManager.lua:187', '2016-01-12 20:37:30');
INSERT INTO `vrp_stats_money` VALUES ('39', '-9000', '@vrp/server/classes/Vehicles/VehicleManager.lua:187', '2016-01-12 20:37:32');
INSERT INTO `vrp_stats_money` VALUES ('37', '-17000', '@vrp/server/classes/Vehicles/VehicleManager.lua:187', '2016-01-12 20:37:34');
INSERT INTO `vrp_stats_money` VALUES ('33', '-11000', '@vrp/server/classes/Vehicles/VehicleManager.lua:187', '2016-01-12 20:37:39');
INSERT INTO `vrp_stats_money` VALUES ('35', '-11300', '@vrp/server/classes/Vehicles/VehicleManager.lua:187', '2016-01-12 20:37:40');
INSERT INTO `vrp_stats_money` VALUES ('34', '-7200', '@vrp/server/classes/Vehicles/VehicleManager.lua:187', '2016-01-12 20:37:44');
INSERT INTO `vrp_stats_money` VALUES ('36', '375', '=(tail call):-1', '2016-01-12 20:38:50');
INSERT INTO `vrp_stats_money` VALUES ('1', '-200000', '@vrp/server/classes/Vehicles/VehicleManager.lua:365', '2016-01-12 20:39:11');
INSERT INTO `vrp_stats_money` VALUES ('40', '-100', '@vrp/server/classes/Vehicles/VehicleManager.lua:295', '2016-01-12 20:39:20');
INSERT INTO `vrp_stats_money` VALUES ('41', '-200000', '@vrp/server/classes/Vehicles/VehicleManager.lua:365', '2016-01-12 20:39:52');
INSERT INTO `vrp_stats_money` VALUES ('31', '-7200', '@vrp/server/classes/Vehicles/VehicleManager.lua:187', '2016-01-12 20:39:54');
INSERT INTO `vrp_stats_money` VALUES ('31', '-200000', '@vrp/server/classes/Vehicles/VehicleManager.lua:365', '2016-01-12 20:40:14');
INSERT INTO `vrp_stats_money` VALUES ('34', '-5000', '@vrp/server/classes/Vehicles/VehicleTuning.lua:171', '2016-01-12 20:40:16');
INSERT INTO `vrp_stats_money` VALUES ('31', '-250000', '@vrp/server/classes/Vehicles/VehicleManager.lua:365', '2016-01-12 20:40:18');
INSERT INTO `vrp_stats_money` VALUES ('31', '-500000', '@vrp/server/classes/Vehicles/VehicleManager.lua:365', '2016-01-12 20:40:21');
INSERT INTO `vrp_stats_money` VALUES ('34', '-11000', '@vrp/server/classes/Vehicles/VehicleTuning.lua:171', '2016-01-12 20:41:09');
INSERT INTO `vrp_stats_money` VALUES ('40', '-200000', '@vrp/server/classes/Vehicles/VehicleManager.lua:365', '2016-01-12 20:41:29');
INSERT INTO `vrp_stats_money` VALUES ('31', '-14000', '@vrp/server/classes/Vehicles/VehicleManager.lua:187', '2016-01-12 20:43:54');
INSERT INTO `vrp_stats_money` VALUES ('33', '-5000', '@vrp/server/classes/Vehicles/VehicleTuning.lua:171', '2016-01-12 20:44:20');
INSERT INTO `vrp_stats_money` VALUES ('40', '0', '@vrp/server/classes/Vehicles/VehicleTuning.lua:171', '2016-01-12 20:44:21');
INSERT INTO `vrp_stats_money` VALUES ('35', '-5000', '@vrp/server/classes/Vehicles/VehicleTuning.lua:171', '2016-01-12 20:44:43');
INSERT INTO `vrp_stats_money` VALUES ('40', '-13337', '@vrp/server/classes/Vehicles/VehicleTuning.lua:171', '2016-01-12 20:44:51');
INSERT INTO `vrp_stats_money` VALUES ('31', '-5000', '@vrp/server/classes/Vehicles/VehicleTuning.lua:171', '2016-01-12 20:44:59');
INSERT INTO `vrp_stats_money` VALUES ('42', '-262', '@vrp/server/classes/Vehicles/PayNSpray.lua:29', '2016-01-12 20:45:06');
INSERT INTO `vrp_stats_money` VALUES ('42', '-33400', '@vrp/server/classes/Vehicles/VehicleTuning.lua:171', '2016-01-12 20:46:39');
INSERT INTO `vrp_stats_money` VALUES ('35', '-291', '@vrp/server/classes/Vehicles/PayNSpray.lua:29', '2016-01-12 20:51:04');
INSERT INTO `vrp_stats_money` VALUES ('39', '-900000', '@vrp/server/classes/Player/BankManager.lua:51', '2016-01-12 21:00:09');
INSERT INTO `vrp_stats_money` VALUES ('33', '0', '=(tail call):-1', '2016-01-12 21:01:31');
INSERT INTO `vrp_stats_money` VALUES ('35', '-10', '@vrp/server/classes/Vehicles/GasStation.lua:46', '2016-01-12 21:01:38');
INSERT INTO `vrp_stats_money` VALUES ('43', '-286', '@vrp/server/classes/Vehicles/PayNSpray.lua:29', '2016-01-12 21:02:19');
INSERT INTO `vrp_stats_money` VALUES ('43', '-66', '@vrp/server/classes/Vehicles/PayNSpray.lua:29', '2016-01-12 21:02:32');
INSERT INTO `vrp_stats_money` VALUES ('43', '0', '@vrp/server/classes/Vehicles/VehicleTuning.lua:171', '2016-01-12 21:03:29');
INSERT INTO `vrp_stats_money` VALUES ('37', '-80000', '@vrp/server/classes/DrivingSchool.lua:33', '2016-01-12 21:03:41');
INSERT INTO `vrp_stats_money` VALUES ('33', '-96', '@vrp/server/classes/Vehicles/PayNSpray.lua:29', '2016-01-12 21:05:05');
INSERT INTO `vrp_stats_money` VALUES ('37', '-16000', '@vrp/server/classes/Vehicles/VehicleManager.lua:187', '2016-01-12 21:05:53');
INSERT INTO `vrp_stats_money` VALUES ('37', '-2000', '@vrp/server/classes/Inventory/ItemShops.lua:44', '2016-01-12 21:07:58');
INSERT INTO `vrp_stats_money` VALUES ('37', '-100', '@vrp/server/classes/Vehicles/VehicleManager.lua:295', '2016-01-12 21:10:47');
INSERT INTO `vrp_stats_money` VALUES ('37', '50', '=(tail call):-1', '2016-01-12 21:17:16');
INSERT INTO `vrp_stats_money` VALUES ('37', '0', '=(tail call):-1', '2016-01-12 21:17:16');
INSERT INTO `vrp_stats_money` VALUES ('40', '100', '@vrp/server/classes/Jobs/JobPolice.lua:150', '2016-01-12 21:17:50');
INSERT INTO `vrp_stats_money` VALUES ('3', '12123', '=[C]:-1', '2016-01-12 21:21:19');
INSERT INTO `vrp_stats_money` VALUES ('3', '12123', '=[C]:-1', '2016-01-12 21:21:21');
INSERT INTO `vrp_stats_money` VALUES ('3', '12123', '=[C]:-1', '2016-01-12 21:21:22');
INSERT INTO `vrp_stats_money` VALUES ('3', '12123', '=[C]:-1', '2016-01-12 21:21:22');
INSERT INTO `vrp_stats_money` VALUES ('3', '12123', '=[C]:-1', '2016-01-12 21:21:22');
INSERT INTO `vrp_stats_money` VALUES ('3', '12123', '=[C]:-1', '2016-01-12 21:21:23');
INSERT INTO `vrp_stats_money` VALUES ('3', '12123', '=[C]:-1', '2016-01-12 21:21:23');
INSERT INTO `vrp_stats_money` VALUES ('3', '-30000', '@vrp/server/classes/Groups/GroupManager.lua:97', '2016-01-12 21:21:26');
INSERT INTO `vrp_stats_money` VALUES ('3', '250', '@vrp/server/classes/Groups/GangArea.lua:278', '2016-01-12 23:03:24');
INSERT INTO `vrp_stats_money` VALUES ('3', '250', '@vrp/server/classes/Groups/GangArea.lua:278', '2016-01-12 23:18:24');
INSERT INTO `vrp_stats_money` VALUES ('39', '-30000', '@vrp/server/classes/Groups/GroupManager.lua:97', '2016-01-13 00:44:23');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:44:57');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:06');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:08');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:09');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:09');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:09');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:09');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:10');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:10');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:10');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:10');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:11');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:11');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:11');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:11');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:12');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:12');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:12');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:12');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:13');
INSERT INTO `vrp_stats_money` VALUES ('36', '2000', '=(tail call):-1', '2016-01-13 00:45:21');
INSERT INTO `vrp_stats_money` VALUES ('36', '-2000', '@vrp/server/classes/Groups/GroupManager.lua:173', '2016-01-13 00:45:22');
INSERT INTO `vrp_stats_money` VALUES ('39', '400', '=(tail call):-1', '2016-01-13 00:59:53');
INSERT INTO `vrp_stats_money` VALUES ('41', '1360', '=(tail call):-1', '2016-01-13 01:01:59');
INSERT INTO `vrp_stats_money` VALUES ('39', '50', '=(tail call):-1', '2016-01-13 01:06:31');
INSERT INTO `vrp_stats_money` VALUES ('39', '0', '=(tail call):-1', '2016-01-13 01:06:31');
INSERT INTO `vrp_stats_money` VALUES ('39', '50', '=(tail call):-1', '2016-01-13 01:06:58');
INSERT INTO `vrp_stats_money` VALUES ('39', '0', '=(tail call):-1', '2016-01-13 01:06:58');
INSERT INTO `vrp_stats_money` VALUES ('41', '-80000', '@vrp/server/classes/DrivingSchool.lua:33', '2016-01-13 01:07:17');
INSERT INTO `vrp_stats_money` VALUES ('39', '50', '=(tail call):-1', '2016-01-13 01:07:23');
INSERT INTO `vrp_stats_money` VALUES ('39', '0', '=(tail call):-1', '2016-01-13 01:07:23');
INSERT INTO `vrp_stats_money` VALUES ('39', '50', '=(tail call):-1', '2016-01-13 01:07:55');
INSERT INTO `vrp_stats_money` VALUES ('39', '0', '=(tail call):-1', '2016-01-13 01:07:55');
INSERT INTO `vrp_stats_money` VALUES ('39', '50', '=(tail call):-1', '2016-01-13 01:08:13');
INSERT INTO `vrp_stats_money` VALUES ('39', '0', '=(tail call):-1', '2016-01-13 01:08:13');
INSERT INTO `vrp_stats_money` VALUES ('41', '-8000', '@vrp/server/classes/Vehicles/VehicleManager.lua:187', '2016-01-13 01:08:26');
INSERT INTO `vrp_stats_money` VALUES ('39', '50', '=(tail call):-1', '2016-01-13 01:08:27');
INSERT INTO `vrp_stats_money` VALUES ('39', '0', '=(tail call):-1', '2016-01-13 01:08:27');
INSERT INTO `vrp_stats_money` VALUES ('39', '50', '=(tail call):-1', '2016-01-13 01:08:53');
INSERT INTO `vrp_stats_money` VALUES ('39', '0', '=(tail call):-1', '2016-01-13 01:08:53');
INSERT INTO `vrp_stats_money` VALUES ('39', '50', '=(tail call):-1', '2016-01-13 01:09:21');
INSERT INTO `vrp_stats_money` VALUES ('39', '0', '=(tail call):-1', '2016-01-13 01:09:21');
INSERT INTO `vrp_stats_money` VALUES ('39', '50', '=(tail call):-1', '2016-01-13 01:09:45');
INSERT INTO `vrp_stats_money` VALUES ('39', '0', '=(tail call):-1', '2016-01-13 01:09:45');
INSERT INTO `vrp_stats_money` VALUES ('36', '-8000', '@vrp/server/classes/Vehicles/VehicleManager.lua:187', '2016-01-13 01:11:01');
INSERT INTO `vrp_stats_money` VALUES ('39', '-428', '@vrp/server/classes/Vehicles/PayNSpray.lua:29', '2016-01-13 01:11:01');
INSERT INTO `vrp_stats_money` VALUES ('39', '-2000', '@vrp/server/classes/Gameplay/SkinShops.lua:24', '2016-01-13 01:12:42');
INSERT INTO `vrp_stats_money` VALUES ('39', '-2000', '@vrp/server/classes/Gameplay/SkinShops.lua:24', '2016-01-13 01:12:59');
INSERT INTO `vrp_stats_money` VALUES ('39', '-100', '@vrp/server/classes/Vehicles/VehicleManager.lua:295', '2016-01-13 01:16:15');
INSERT INTO `vrp_stats_money` VALUES ('36', '100', '@vrp/server/classes/Jobs/JobPolice.lua:150', '2016-01-13 01:18:30');
INSERT INTO `vrp_stats_money` VALUES ('39', '-50000', '@vrp/server/classes/Player/BankManager.lua:51', '2016-01-13 01:21:49');

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
  `PositionType` tinyint(3) unsigned DEFAULT '0',
  `Tunings` text,
  `Mileage` bigint(20) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_vehicles
-- ----------------------------
INSERT INTO `vrp_vehicles` VALUES ('1', '489', '30', '2148.2', '-1179.96', '23.5', '90', '0', '1000', null, '0', null, '0');
INSERT INTO `vrp_vehicles` VALUES ('3', '567', '41', '2148.2', '-1179.96', '23.5', '90', '0', '1000', null, '0', null, '0');
INSERT INTO `vrp_vehicles` VALUES ('4', '567', '40', '2148.2', '-1179.96', '23.5', '90', '0', '1000', null, '0', null, '0');
INSERT INTO `vrp_vehicles` VALUES ('5', '560', '42', '2148.2', '-1179.96', '23.5', '90', '0', '1000', null, '0', null, '0');
INSERT INTO `vrp_vehicles` VALUES ('6', '567', '1', '2148.2', '-1179.96', '23.5', '90', '0', '1000', null, '0', null, '0');
INSERT INTO `vrp_vehicles` VALUES ('7', '540', '39', '2148.2', '-1179.96', '23.5', '90', '0', '1000', null, '0', null, '0');
INSERT INTO `vrp_vehicles` VALUES ('8', '489', '37', '2148.2', '-1179.96', '23.5', '90', '0', '1000', null, '0', null, '0');
INSERT INTO `vrp_vehicles` VALUES ('9', '589', '33', '2148.2', '-1179.96', '23.5', '90', '0', '1000', null, '0', null, '0');
INSERT INTO `vrp_vehicles` VALUES ('10', '533', '35', '2148.2', '-1179.96', '23.5', '90', '0', '1000', null, '0', null, '0');
INSERT INTO `vrp_vehicles` VALUES ('11', '536', '34', '2148.2', '-1179.96', '23.5', '90', '0', '1000', null, '0', null, '0');
INSERT INTO `vrp_vehicles` VALUES ('12', '536', '31', '2148.2', '-1179.96', '23.5', '90', '0', '1000', null, '0', null, '0');
INSERT INTO `vrp_vehicles` VALUES ('13', '402', '31', '2148.2', '-1179.96', '23.5', '90', '0', '1000', null, '0', null, '0');
INSERT INTO `vrp_vehicles` VALUES ('14', '522', '37', '1274.9', '-1373.6', '13.1', '0', '0', '1000', null, '0', null, '0');
INSERT INTO `vrp_vehicles` VALUES ('15', '521', '41', '1274.9', '-1373.6', '13.1', '0', '0', '1000', null, '0', null, '0');
INSERT INTO `vrp_vehicles` VALUES ('16', '581', '36', '1274.9', '-1373.6', '13.1', '0', '0', '1000', null, '0', null, '0');
