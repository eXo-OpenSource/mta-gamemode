/*
Navicat MySQL Data Transfer

Source Server         : vServer - saonline
Source Server Version : 50172
Source Host           : jusonex.net:3306
Source Database       : saonline

Target Server Type    : MYSQL
Target Server Version : 50172
File Encoding         : 65001

Date: 2014-01-18 12:09:28
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `vrp_account`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_account`;
CREATE TABLE `vrp_account` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) DEFAULT NULL,
  `Salt` varchar(32) DEFAULT NULL,
  `Password` varchar(64) DEFAULT NULL,
  `Rank` tinyint(3) unsigned DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_account
-- ----------------------------
INSERT INTO `vrp_account` VALUES ('1', 'Jusonex', 'A2A1ADF8818717DFF9D40322D08A06DA', '0EB8829A1C7B2261C1723C0BAB8A35E481C0955099A29A06EFCDC02D463EBFB9', '0');

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
  `XP` int(11) DEFAULT '0',
  `Karma` smallint(6) DEFAULT '0',
  `Money` int(10) unsigned DEFAULT '0',
  `BankMoney` int(10) unsigned DEFAULT '0',
  `WantedLevel` tinyint(3) unsigned DEFAULT '0',
  `TutorialStage` tinyint(3) unsigned DEFAULT '0',
  `DrivingSkill` tinyint(3) unsigned DEFAULT '0',
  `GunSkill` tinyint(4) DEFAULT '0',
  `FlyingSkill` tinyint(3) unsigned DEFAULT '0',
  `SneakingSkill` tinyint(3) unsigned DEFAULT '0',
  `EnduranceSkill` tinyint(3) unsigned DEFAULT '0',
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_character
-- ----------------------------
INSERT INTO `vrp_character` VALUES ('1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');

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
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_vehicles
-- ----------------------------
