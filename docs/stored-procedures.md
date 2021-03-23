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

# Update companies

```sql
CREATE OR REPLACE PROCEDURE UpdateCompanies()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE curUserId INT;
  DECLARE curName VARCHAR(255);
	
	
	DECLARE companies CURSOR FOR SELECT a.ForumId, f.Name FROM vrp_public.vrp_character c INNER JOIN vrp_public.vrp_account a ON a.Id = c.Id INNER JOIN vrp_public.vrp_companies f ON f.Id = c.CompanyId WHERE c.CompanyId <> 0;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
	-- Setting selection list
	UPDATE vrp_forum.wcf1_user_option SET selectOptions = (SELECT GROUP_CONCAT(a.Name SEPARATOR '\n') AS selectOptions FROM (SELECT wuo.defaultValue AS Name FROM vrp_forum.wcf1_user_option wuo WHERE wuo.optionID = 46 UNION SELECT f.Name FROM vrp_public.vrp_companies f) AS a) WHERE optionID = 46;
	-- Resetting values
	UPDATE vrp_forum.wcf1_user_option_value SET userOption46 = (SELECT wuo.defaultValue AS Name FROM vrp_forum.wcf1_user_option wuo WHERE wuo.optionID = 46);


	-- Settings new values
	OPEN companies;
	
	read_loop: LOOP
		FETCH companies INTO curUserId, curName;
	  IF done THEN
		  LEAVE read_loop;
	  END IF;
	
		UPDATE vrp_forum.wcf1_user_option_value SET userOption46 = curName WHERE userID = curUserId;
	END LOOP;
	
	CLOSE companies;
END;
```

# Update groups

```sql
CREATE OR REPLACE PROCEDURE UpdateGroups()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE curUserId INT;
  DECLARE curName VARCHAR(255);
	
	
	DECLARE groups CURSOR FOR SELECT a.ForumId, f.Name FROM vrp_public.vrp_character c INNER JOIN vrp_public.vrp_account a ON a.Id = c.Id INNER JOIN vrp_public.vrp_groups f ON f.Id = c.GroupId WHERE c.GroupId <> 0;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
	-- Resetting values
	UPDATE vrp_forum.wcf1_user_option_value SET userOption47 = (SELECT wuo.defaultValue AS Name FROM vrp_forum.wcf1_user_option wuo WHERE wuo.optionID = 47);

	-- Settings new values
	OPEN groups;
	
	read_loop: LOOP
		FETCH groups INTO curUserId, curName;
	  IF done THEN
		  LEAVE read_loop;
	  END IF;
	
		UPDATE vrp_forum.wcf1_user_option_value SET userOption47 = curName WHERE userID = curUserId;
	END LOOP;
	
	CLOSE groups;
END;

CALL UpdateGroups();
```

# Create event

```sql
CREATE PROCEDURE UpdateOptionsFields()
BEGIN
CALL UpdateFactions();
CALL UpdateCompanies();
CALL UpdateGroups();
END;

CREATE OR REPLACE EVENT UpdateOptionFields
ON SCHEDULE
EVERY '1' HOUR STARTS '2021-03-23 18:00:00'
DO 
CALL UpdateOptionFields;
```
