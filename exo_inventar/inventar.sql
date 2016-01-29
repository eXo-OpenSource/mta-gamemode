/*
Navicat MySQL Data Transfer

Source Server         : Unlimited RL
Source Server Version : 50519
Source Host           : localhost:3306
Source Database       : mta_datenbank

Target Server Type    : MYSQL
Target Server Version : 50519
File Encoding         : 65001

Date: 2012-01-27 16:37:20
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `inventardef`
-- ----------------------------
DROP TABLE IF EXISTS `inventardef`;
CREATE TABLE `inventardef` (
  `Objektname` varchar(64) NOT NULL,
  `STasche` varchar(12) DEFAULT NULL,
  `max_items` int(15) NOT NULL DEFAULT '1',
  `Info` mediumtext CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of inventardef
-- ----------------------------
INSERT INTO `inventardef` VALUES ('Geld', 'Potte', '100000', '2');
INSERT INTO `inventardef` VALUES ('ECKarte', 'Potte', '1', 'Aendern buette');
INSERT INTO `inventardef` VALUES ('weapons/AK-47', 'Waffen', '1000000', 'T');
INSERT INTO `inventardef` VALUES ('weapons/Baseballschlaeger', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Billiard Koe', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Blumen', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Countryschrotflinte', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Desert Eagle', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Digitalkamera', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Fallschirm', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Feuerloescher', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Flammenwerfer', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Gehstock', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Golfschlaeger', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Granate', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Infrarotsichtgeraet', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Katana', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Kettensaege', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Kurzer Dildo', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Langer lila Dildo', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/M4', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Messer', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Molotov Cocktails', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/MP5', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Nachtsichtgerät', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Pistole', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Raketenwerfer', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Rucksackbomben', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Rucksackbombenzünder', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Sawn-Off Schrotflinte', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Schalldaempferpistole', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Schaufel', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Schlagring', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Schlagstock', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Schrotflinte', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Sniper', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/SPAZ-12 Gefechtsschrotflinte', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Spraydose', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/TEC-9', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Tränengas', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Uzi', 'Waffen', '1000000', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Vibrator', 'Waffen', '1', 'a');
INSERT INTO `inventardef` VALUES ('weapons/Waermelenkraketenwerfer', 'Waffen', '1000000', 'a');

-- ----------------------------
-- Table structure for `inventarinfo`
-- ----------------------------
DROP TABLE IF EXISTS `inventarinfo`;
CREATE TABLE `inventarinfo` (
  `Name` varchar(32) NOT NULL,
  `TaschenPlatz` int(3) NOT NULL DEFAULT '20',
  `PottePlatz` int(3) NOT NULL DEFAULT '7',
  `KeysPlatz` int(3) NOT NULL DEFAULT '14',
  `WaffenPlatz` int(2) NOT NULL DEFAULT '10'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of inventarinfo
-- ----------------------------
INSERT INTO `inventarinfo` VALUES ('Audifire', '20', '7', '14', '10');
INSERT INTO `inventarinfo` VALUES ('Tockra', '20', '20', '14', '10');
INSERT INTO `inventarinfo` VALUES ('Johnny', '20', '7', '14', '10');
INSERT INTO `inventarinfo` VALUES ('Snap*', '20', '7', '14', '10');
INSERT INTO `inventarinfo` VALUES ('Shady', '20', '7', '14', '10');
INSERT INTO `inventarinfo` VALUES ('bLah_xP', '20', '7', '14', '10');

-- ----------------------------
-- Table structure for `inventarinhalt`
-- ----------------------------
DROP TABLE IF EXISTS `inventarinhalt`;
CREATE TABLE `inventarinhalt` (
  `id` mediumint(9) NOT NULL AUTO_INCREMENT,
  `Name` varchar(32) NOT NULL,
  `Objekt` varchar(24) NOT NULL,
  `Platz` int(3) NOT NULL,
  `Menge` int(18) NOT NULL,
  `Tasche` varchar(8) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of inventarinhalt
-- ----------------------------
INSERT INTO `inventarinhalt` VALUES ('8', 'Tockra', 'weapons/Schlagring', '4', '1', 'Waffen');
INSERT INTO `inventarinhalt` VALUES ('14', 'Tockra', 'weapons/Uzi', '0', '28', 'Waffen');

-- ----------------------------
-- Table structure for `weltitems`
-- ----------------------------
DROP TABLE IF EXISTS `weltitems`;
CREATE TABLE `weltitems` (
  `id` mediumint(100) NOT NULL AUTO_INCREMENT,
  `Name` varchar(24) DEFAULT NULL,
  `Menge` int(18) DEFAULT NULL,
  `Verschmutzer` varchar(32) DEFAULT NULL,
  `xPos` float(20,15) DEFAULT NULL,
  `yPos` float(20,15) DEFAULT NULL,
  `zPos` float(20,15) DEFAULT NULL,
  `Interior` int(3) DEFAULT '0',
  `Dimension` int(3) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of weltitems
-- ----------------------------
