/*
Navicat MySQL Data Transfer

Source Server         : vServer
Source Server Version : 50173
Source Host           : jusonex.net:3306
Source Database       : saonline

Target Server Type    : MYSQL
Target Server Version : 50173
File Encoding         : 65001

Date: 2014-11-10 20:06:29
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
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_account
-- ----------------------------

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
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_character
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

-- ----------------------------
-- Table structure for `vrp_groups`
-- ----------------------------
DROP TABLE IF EXISTS `vrp_groups`;
CREATE TABLE `vrp_groups` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) DEFAULT NULL,
  `Money` int(10) unsigned DEFAULT '0',
  PRIMARY KEY (`Id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_groups
-- ----------------------------

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
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_inventory
-- ----------------------------

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
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vrp_vehicles
-- ----------------------------
