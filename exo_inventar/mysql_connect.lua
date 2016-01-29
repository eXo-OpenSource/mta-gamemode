MYSQL_HOST	= "87.98.241.93"
MYSQL_PORT	= 6033
MYSQL_USER	= "vRP"
MYSQL_PW	= "kmd1581adf%%f"
MYSQL_DB	= "vRP"
MYSQL_UNIX_SOCKET = "/var/run/mysqld/mysqld.sock"


function OnGameModInit()
	Datenbank = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PW, MYSQL_DB, MYSQL_PORT, MYSQL_UNIX_SOCKET)
	if(Datenbank) then
		outputDebugString  ("exo_inventar: Die Verbindung zur MySQL-Datenbank wurd erfolgreich hergestellt.")
	elseif(not Datenbank) then
		outputDebugString ("exo_inventar: Die Verbindung zur MySQL Datenbank konnte nicht hergestellt werden")
		shutdown ( "exo_inventar: Die Verbindung zur Mysql-Datenbank konnte nicht aufgebaut werden!" )
		return 0
	end
	
end -- Verbindung zur Datenbank + Sonstiges

addEventHandler ( "onResourceStart", resourceRoot, OnGameModInit )

local function onPlayerJoin()
	if(not mysql_ping ( Datenbank )) then
		outputDebugString("INVENTAR: Verbindung zur Datenbank verloren")
		Datenbank = mysql_connect(ipMysql,userMysql,pwMysql,databaseMysql);
		if(Datenbank) then
			outputDebugString ("exo_inventar: Verbindung zur Datenbank wurde wieder hergestellt.")
		elseif(not Datenbank) then
			outputDebugString ("exo_inventar: Die Verbindung konnte nicht hergestellt werden!")
			mysql_close(Datenbank)
		end
	end
end
addEventHandler ( "onPlayerJoin", getRootElement(), onPlayerJoin)

function MySQL_GetString(tablename, feldname, bedingung)
	local result = mysql_query(Datenbank, "SELECT "..feldname.." from "..tablename.." WHERE "..bedingung)
	if( not result) then
		 outputDebugString("exo_inventar: Error executing the query: (" .. mysql_errno(Datenbank) .. ") " .. mysql_error(Datenbank))
		if mysql_errno(Datenbank) == 2006 then
			outputDebugString("exo_inventar: Neuaufbau der Verbindung...")
			MySQL_End()
			MySQL_Startup()
		end
	else
		if(mysql_num_rows(result) > 0) then
			local dsatz = mysql_fetch_assoc(result)
			local savename = feldname
			mysql_free_result(result)
			return dsatz[feldname]
		else
			mysql_free_result(result)
			return false
		end
	end
end