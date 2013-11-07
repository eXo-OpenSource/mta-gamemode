
exports.woltlab:woltlab_connect ( "vweb20.nitrado.net", "ni258461_1sql1", "gtasaonlinedbpw", "ni258461_1sql1" )


local PlayerData = {}

function onStart ()
	establishMySQLCon()
end
addEventHandler( "onResourceStart", getResourceRootElement(), onStart )


function establishMySQLCon ()
	MySQLConnection = dbConnect( "mysql", "dbname=account;host=127.0.0.1", "root", "", "share=1" )
	if MySQLConnection then
		outputDebugString( "Die MySQL Verbindung wurde erfolgreich hergestellt." )
	else
		outputDebugString( "Die MySQL Verbindung konnte nicht hergestellt werden." )
	end
end


function onReadyClient ()
	--checkMySQLCon()
	PlayerData[source] = {}
	PlayerData[source]["Char1"] = {}
	PlayerData[source]["Char2"] = {}
	PlayerData[source]["LoggedIn"] = false
end
addEvent( "onPlayerReadyToPlay", true )
addEventHandler( "onPlayerReadyToPlay", getRootElement(), onReadyClient )



function loginPlayer ( thePlayer, username, password )
	
	local login = exports.woltlab:woltlab_checkPassword ( username, password )
	if login == true then
		nRows = 0
		outputChatBox( "Du hast dich erfolgreich eingeloggt!", thePlayer, 0,255,0 )
		local db_chars_select = dbQuery( MySQLConnection, "SELECT * FROM charakters WHERE charname=?", username )
		local result = dbPoll ( db_chars_select, -1 )
		if result then
			for _, row in ipairs ( result ) do
				nRows = nRows + 1
			end
			if nRows == 0 then
				-- 2 Charaktere anlegen
				local db_chars_insert1 = dbExec( MySQLConnection, "INSERT INTO charakters (charname, hours, minutes) VALUES (?, ?, ?)", username, 0, 0 )
				local db_chars_insert2 = dbExec( MySQLConnection, "INSERT INTO charakters (charname, hours, minutes) VALUES (?, ?, ?)", username, 0, 0 )
				if db_chars_insert1 == false then
					outputChatBox( "1# Ein unerwarteter Fehler ist aufgetreten.", thePlayer )
				end
				if db_chars_insert2 == false then
					outputChatBox( "2# Ein unerwarteter Fehler ist aufgetreten.", thePlayer )
				end
			end
			
			local db_chars_selected_char1 = dbQuery( MySQLConnection, "SELECT * FROM charakters WHERE charname=? ORDER BY accid ASC LIMIT 1", username)
			local result = dbPoll ( db_chars_selected_char1, -1 )
			if result then
				for _, row in ipairs ( result ) do
					PlayerData[thePlayer]["Char1"]["Charname"] = row["charname"]
					PlayerData[thePlayer]["Char1"]["Stunden"] = row["hours"]
					PlayerData[thePlayer]["Char1"]["Minuten"] = row["minutes"]
					PlayerData[thePlayer]["Char1"]["Level"] = row["level"]
					PlayerData[thePlayer]["Char1"]["Fahren"] = row["driving"]
					PlayerData[thePlayer]["Char1"]["Schiessen"] = row["shooting"]
					PlayerData[thePlayer]["Char1"]["Fliegen"] = row["flying"]
					PlayerData[thePlayer]["Char1"]["Schleichen"] = row["stealthing"]
					PlayerData[thePlayer]["Char1"]["Ausdauer"] = row["stamina"]
				end
			end
			dbFree( db_chars_selected_char1 )
			
			
			local db_chars_selected_char2 = dbQuery( MySQLConnection, "SELECT * FROM charakters WHERE charname=? ORDER BY accid DESC LIMIT 1", username)
			local result = dbPoll ( db_chars_selected_char2, -1 )
			if result then
				for _, row in ipairs ( result ) do
					PlayerData[thePlayer]["Char2"]["Charname"] = row["charname"]
					PlayerData[thePlayer]["Char2"]["Stunden"] = row["hours"]
					PlayerData[thePlayer]["Char2"]["Minuten"] = row["minutes"]
					PlayerData[thePlayer]["Char2"]["Level"] = row["level"]
					PlayerData[thePlayer]["Char2"]["Fahren"] = row["driving"]
					PlayerData[thePlayer]["Char2"]["Schiessen"] = row["shooting"]
					PlayerData[thePlayer]["Char2"]["Fliegen"] = row["flying"]
					PlayerData[thePlayer]["Char2"]["Schleichen"] = row["stealthing"]
					PlayerData[thePlayer]["Char2"]["Ausdauer"] = row["stamina"]
				end
			end
			dbFree( db_chars_selected_char2 )
			
			
			
			char1 = {}
			char1.charname = PlayerData[thePlayer]["Char1"]["Charname"]
			char1.stunden = tonumber(PlayerData[thePlayer]["Char1"]["Stunden"])
			char1.minuten = tonumber(PlayerData[thePlayer]["Char1"]["Minuten"])
			char1.level = tonumber(PlayerData[thePlayer]["Char1"]["Level"])
			char1.fahren = tonumber(PlayerData[thePlayer]["Char1"]["Fahren"])
			char1.schiessen = tonumber(PlayerData[thePlayer]["Char1"]["Schiessen"])
			char1.fliegen = tonumber(PlayerData[thePlayer]["Char1"]["Fliegen"])
			char1.schleichen = tonumber(PlayerData[thePlayer]["Char1"]["Schleichen"])
			char1.ausdauer = tonumber(PlayerData[thePlayer]["Char1"]["Ausdauer"])
			
			char2 = {}
			char2.charname = PlayerData[thePlayer]["Char2"]["Charname"]
			char2.stunden = tonumber(PlayerData[thePlayer]["Char2"]["Stunden"])
			char2.minuten = tonumber(PlayerData[thePlayer]["Char2"]["Minuten"])
			char2.level = tonumber(PlayerData[thePlayer]["Char2"]["Level"])
			char2.fahren = tonumber(PlayerData[thePlayer]["Char2"]["Fahren"])
			char2.schiessen = tonumber(PlayerData[thePlayer]["Char2"]["Schiessen"])
			char2.fliegen = tonumber(PlayerData[thePlayer]["Char2"]["Fliegen"])
			char2.schleichen = tonumber(PlayerData[thePlayer]["Char2"]["Schleichen"])
			char2.ausdauer = tonumber(PlayerData[thePlayer]["Char2"]["Ausdauer"])
			

			triggerClientEvent(thePlayer, "pili", thePlayer, char1.charname, char1.level, char1.fahren, char1.schiessen, char1.fliegen, char1.schleichen, char1.ausdauer, char2.level, char2.fahren, char2.schiessen, char2.fliegen, char2.schleichen, char2.ausdauer)
		else
			outputChatBox( "2# Ein unerwarteter Fehler ist aufgetreten.", thePlayer )
		end
	else
		outputChatBox( "Account/Benutzername/Passwort wurde nicht gefunden.", thePlayer, 255, 0, 0 )
		return
	end
end
addEvent("loginMySQL", true)
addEventHandler("loginMySQL", root, loginPlayer)


function makeadmin ( thePlayer, command, targetPlayer )
	if not targetPlayer then
		outputChatBos( "BENUTZUNG: /makeadmin [Spielername]", thePlayer )
		return
	end
	local targetPlayerData = getPlayerFromName( targetPlayer )
	if not targetPlayerData then
		outputChatBos( "Der angebene Spieler existiert nicht.", thePlayer )
		return
	end
	if not PlayerData[thePlayer]["Admin"] then
		outputChatBox( "Du bist kein Administrator.", thePlayer )
		return
	end
	PlayerData[targetPlayerData]["Admin"] = not PlayerData[targetPlayerData]["Admin"]
	if PlayerData[targetPlayerData]["Admin"] then
		outputChatBox( "Du hast "..targetPlayer.." Rechte gegeben.", thePlayer )
		outputChatBox( "Du bist nun Admin.", targetPlayerData )
	else
		outputChatBox( "Du hast "..targetPlayer.." die Rechte entzogen.", thePlayer )
		outputChatBox( "Du bist nun kein Admin mehr.", targetPlayerData )
	end
end
addCommandHandler( "makeadmin", makeadmin, false, false )

function increasePlayingTime ()
	for _, player in ipairs( getElementsByType( "player" ) ) do
		if PlayerData[player]["LoggedIn"] then
			PlayerData[player]["Minutes"] = PlayerData[player]["Minutes"]+1
			outputChatBox("Minuten: "..PlayerData[player]["Minutes"], player, 255, 0, 0)
			if PlayerData[player]["Minutes"] == 60 then
				PlayerData[player]["Minutes"] = 0
				PlayerData[player]["Hours"] = PlayerData[player]["Hours"]+1
				outputChatBox("Stunden: "..PlayerData[player]["Minutes"], player, 255, 0, 0)
			end
		end
	end
end
setTimer( increasePlayingTime, 60000, 0 )
