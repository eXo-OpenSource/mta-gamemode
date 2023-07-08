Migration_20230708_2055_game_view = {}

Migration_20230708_2055_game_view.Database = MigrationManager.DATABASES.GAME;

Migration_20230708_2055_game_view.Up = function(game, logs, premium)
    return string.format([[
        DROP TABLE IF EXISTS `view_accountgroups`;
        CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `view_accountgroups` AS select `ac`.`Id` AS `Id`,`ac`.`ForumID` AS `ForumID`,`ch`.`FactionId` AS `FactionId`,`ch`.`FactionRank` AS `FactionRank`,`ch`.`CompanyId` AS `CompanyId`,`ch`.`CompanyRank` AS `CompanyRank`,ifnull(`pu`.`premium_bis`,0) AS `premium_bis` from ((`%s`.`vrp_account` `ac` join `%s`.`vrp_character` `ch` on(`ch`.`Id` = `ac`.`Id`)) left join `%s`.`user` `pu` on(`pu`.`UserId` = `ac`.`Id`)) ;     
    ]], game, game, premium)
end
