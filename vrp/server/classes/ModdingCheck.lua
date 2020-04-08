ModdingCheck = inherit( Singleton )

--[[
ModdingCheck.SKIN_MAX_DIFFER_X = 0.5
ModdingCheck.SKIN_MAX_DIFFER_Y = 0.5
ModdingCheck.SKIN_MAX_DIFFER_Z = 0.5

ModdingCheck.VEH_MAX_DIFFER_X = 0.8
ModdingCheck.VEH_MAX_DIFFER_Y = 0.8
ModdingCheck.VEH_MAX_DIFFER_Z = 0.8

ModdingCheck.OTHER_MAX_DIFFER_X = 0.2
ModdingCheck.OTHER_MAX_DIFFER_Y = 0.2
ModdingCheck.OTHER_MAX_DIFFER_Z = 0.2

--]]

ModdingCheck.SKIN_MAX_DIF = 0.2 --// 20% Difference
ModdingCheck.VEHICLE_MAX_DIF = 0.2
ModdingCheck.OTHER_MAX_DIF = 0.2
function ModdingCheck:constructor()
	if not sql:queryFetchSingle("SHOW TABLES LIKE ?;", ("%s_%s"):format(sql:getPrefix(), "account_mods")) then
		sql:queryExec([[
			CREATE TABLE ??_account_mods  (
				`Serial` varchar(32) NOT NULL,
				`SHA256` varchar(64) NOT NULL,
				`Model` int NOT NULL,
				`Name` varchar(255) NOT NULL,
				`MD5` varchar(32) NOT NULL,
				`MD5Padded` varchar(32) NOT NULL,
				`SHA256Padded` varchar(64) NOT NULL,
				`SizeX` double NULL,
				`SizeY` double NULL,
				`SizeZ` double NULL,
				`CreatedAt` datetime NOT NULL,
				`LastSeenAt` datetime NOT NULL,
				PRIMARY KEY (`Serial`, `SHA256`)
			);
		]], sql:getPrefix())

		sql:queryExec([[
			CREATE TABLE ??_account_mod_bans  (
				`Id` int NOT NULL AUTO_INCREMENT,
				`UserId` int NOT NULL,
				`AdminId` int NOT NULL,
				`CreatedAt` datetime NOT NULL,
				`ValidUntil` datetime NULL,
				PRIMARY KEY (`Id`)
			);
		]], sql:getPrefix())

		sql:queryExec([[
			CREATE TABLE ??_mod_blacklist  (
				`Id` int NOT NULL AUTO_INCREMENT,
				`SHA256` varchar(64) NULL,
				`MD5` varchar(32) NULL,
				PRIMARY KEY (`Id`)
			);
		]], sql:getPrefix())
	end

	self:loadBans()

	addEventHandler ( "onPlayerModInfo", getRootElement(), bind(self.handleOnPlayerModInfo, self))
	for _,plr in ipairs( getElementsByType("player") ) do
		resendPlayerModInfo( plr )
	end
end

function ModdingCheck:loadBans()
	self.m_ModUserBans = sql:queryFetch([[
		SELECT s.Serial FROM ??_account_mod_bans b INNER JOIN ??_account_to_serial s ON s.PlayerId = b.UserId WHERE b.ValidUntil IS NULL or b.ValidUntil > NOW()
	]], sql:getPrefix(), sql:getPrefix())

	self.m_ModBans = sql:queryFetch([[
		SELECT * FROM ??_mod_blacklist
	]], sql:getPrefix())
end

function ModdingCheck:handleOnPlayerModInfo ( filename, modList )
	local tNames = {}
	local sumOriginal, sumMod --// will store the product of all axis SUMMED
	local divResult --// sumOriginal / sumMod
	local difCondition --// bool that will state if the modded skin is differing too much from the original one
	local foundVehicleMods = false
	local hasModsBan = false

	for _, v in pairs(self.m_ModUserBans) do
		if v.Serial == source:getSerial() then
			hasModsBan = true
			break
		end
	end

	for idx,item in ipairs(modList) do
		if item.sizeX then
			sql:queryExec([[
				INSERT INTO ??_account_mods
				(Serial, SHA256, Model, Name, MD5, MD5Padded, SHA256Padded, SizeX, SizeY, SizeZ, CreatedAt, LastSeenAt)
				VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
				ON DUPLICATE KEY UPDATE LastSeenAt = NOW();
			]], sql:getPrefix(), source:getSerial(), item.sha256, item.id, item.name, item.md5, item.paddedMd5, item.paddedSha256, item.sizeX, item.sizeY, item.sizeZ)

			local found = false

			for _, v in pairs(self.m_ModBans) do
				if v.MD5 == item.md5 or v.SHA256 == item.sha256 then
					tNames[#tNames+1] = item.id.." - "..item.name
					found = true
				end
			end

			if not found then
				sumOriginal = item.originalSizeX + item.originalSizeY + item.originalSizeZ
				sumMod = item.sizeX + item.sizeY + item.sizeZ
				divResult = sumOriginal / sumMod
				if divResult then
					if item.id >= 0 and item.id <= 310 then -- Skins
						difCondition = divResult <= 1 and divResult < (1-ModdingCheck.SKIN_MAX_DIF)  or divResult > (1+ModdingCheck.SKIN_MAX_DIF)
						if difCondition then
							tNames[#tNames+1] = item.id.." - "..item.name
						end
					elseif item.id >= 400 and item.id <= 611 then -- Vehicles
						foundVehicleMods = true
						difCondition = divResult <= 1 and divResult < (1-ModdingCheck.VEHICLE_MAX_DIF)  or divResult > (1+ModdingCheck.VEHICLE_MAX_DIF)
						if difCondition or item.id == 482 or hasModsBan then
							tNames[#tNames+1] = item.id.." - "..item.name
						end
					elseif item.id >= 321 and item.id <= 372 then -- Weapons
						--Allow Weapon Mods
					else
						difCondition = divResult <= 1 and divResult < (1-ModdingCheck.OTHER_MAX_DIF)  or divResult > (1+ModdingCheck.OTHER_MAX_DIF)
						if difCondition then
							tNames[#tNames+1] = item.id.." - "..item.name
						end
					end
				end
			end
		end
	end
	if hasModsBan then
		tNames[#tNames+1] = "Du darfst keine Fahrzeuge modden!"
	end
	if #tNames > 0 then
		fadeCamera(source, false,0.5,255,255,255)
		triggerClientEvent("showModCheck", source, tNames)
	end
end
