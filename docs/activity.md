```sql
CREATE TABLE `vrp_accountActivity`  (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `Date` date NOT NULL,
  `UserID` int(11) NOT NULL,
  `SessionStart` bigint(20) NULL DEFAULT NULL,
  `Duration` int(11) NULL DEFAULT NULL COMMENT 'Duration in Minutes',
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `Date_UserID`(`Date`, `UserID`) USING BTREE,
  INDEX `UserID_Date`(`UserID`, `Date`) USING BTREE
);
```

```sql
CREATE TABLE `vrp_account_activity`  (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `Date` date NOT NULL,
  `UserID` int(11) NOT NULL,
  `SessionStart` bigint(20) NULL DEFAULT NULL,
  `Duration` int(11) NULL DEFAULT NULL COMMENT 'Duration in Minutes',
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `Date_UserID`(`Date`, `UserID`) USING BTREE,
  INDEX `UserID_Date`(`UserID`, `Date`) USING BTREE
);
```

vrp_account_activity <- one entry per session
> Id
> Date
> UserId
> SessionStart
> Duration
> DurationDuty <- any duty
> DurationAfk

vrp_account_activity_group <- one entry per day & group (faction, company, groups)
> Date
> UserId
> ElementId
> ElementType
> Duration
> DurationDuty <- will be zero for groups

```sql
CREATE TABLE `vrp_account_activity_group`  (
  `Date` date NOT NULL,
  `UserID` int NOT NULL,
  `ElementId` int NOT NULL,
  `ElementType` tinyint NOT NULL,
  `SessionStart` bigint(20) NULL DEFAULT NULL,
  `Duration` int(11) NULL DEFAULT NULL COMMENT 'Duration in Minutes',
  `DurationDutyDurationDuty` int(11) NULL DEFAULT NULL COMMENT 'Duration in Minutes',
  PRIMARY KEY (`Date`, `ElementType`, `ElementId`, `UserId`) USING BTREE,
  INDEX `Date_UserID`(`Date`, `UserID`) USING BTREE,
  INDEX `UserID_Date`(`UserID`, `Date`) USING BTREE
);
```

```lua
if sql:queryFetchSingle("SHOW TABLES LIKE ?;", sql:getPrefix() .. "_items") then
if not sql:queryFetchSingle("SHOW COLUMNS FROM ??_factions WHERE Field = 'Name_Shorter';", sql:getPrefix()) then
```
