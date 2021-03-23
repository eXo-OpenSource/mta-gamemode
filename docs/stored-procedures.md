# Update factions

```sql
CREATE OR REPLACE PROCEDURE UpdateFactions()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE curUserId INT;
  DECLARE curName VARCHAR(255);
	
	
	DECLARE factions CURSOR FOR SELECT a.ForumId, f.Name FROM vrp_public.vrp_character c INNER JOIN vrp_public.vrp_account a ON a.Id = c.Id INNER JOIN vrp_public.vrp_factions f ON f.Id = c.FactionId WHERE c.FactionId <> 0;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
	-- Setting selection list
	UPDATE vrp_forum.wcf1_user_option SET selectOptions = (SELECT GROUP_CONCAT(a.Name SEPARATOR '\n') AS selectOptions FROM (SELECT wuo.defaultValue AS Name FROM vrp_forum.wcf1_user_option wuo WHERE wuo.optionID = 45 UNION SELECT f.Name FROM vrp_public.vrp_factions f) AS a) WHERE optionID = 45;
	-- Resetting values
	UPDATE vrp_forum.wcf1_user_option_value SET userOption45 = (SELECT wuo.defaultValue AS Name FROM vrp_forum.wcf1_user_option wuo WHERE wuo.optionID = 45);


	-- Settings new values
	OPEN factions;
	
	read_loop: LOOP
		FETCH factions INTO curUserId, curName;
	  IF done THEN
		  LEAVE read_loop;
	  END IF;
	
		UPDATE vrp_forum.wcf1_user_option_value SET userOption45 = curName WHERE userID = curUserId;
	END LOOP;
	
	CLOSE factions;
END;
```

