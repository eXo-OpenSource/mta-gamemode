AmmunationEvaluation = inherit(Singleton) 


local damageTypes = {
	[19] = "Rakete",
	[37] = "Verbannt",
	[49] = "Roadkill",
	[50] = "Helikopterrotor / Roadkill",
	[51] = "Explosion",
	[52] = "Driveby",
	[53] = "Ertrunken",
	[54] = "Durch Fall",
	[55] = "Unbekannt",
	[56] = "Nahkampf",
	[57] = "Waffen",
	[59] = "Panzer-Granate",
	[63] = "Fahrzeugexplosion"
}

local DATE_AFTER =  "2019-01-01 00:00:00"
local EVALUATION_FILE = "zusammenfassung"
local EVALUATION_CSV = "ammunation"
--// use local functions https://www.lua.org/gems/sample.pdf #page 17
local scope_print = print
local scope_type = type
local scope_tonumber = tonumber
local scope_pairs = pairs
local scope_floor = math.floor

function AmmunationEvaluation:constructor() 
	self.m_EvaluationTable = {}
	self.m_CSVTable = {}
	Async.create(function() self:evaluate() end)()
end

function AmmunationEvaluation:evaluate() 

	local formatPercentage = function (value, max)
		return ((scope_floor((value/max)*1000)/1000)*100)
	end

	sqlLogs:queryFetch(Async.waitFor(), 'SELECT Weapons, Type, Costs FROM ??_ammunation WHERE (Type LIKE "Bestellung" OR Type LIKE "Shop") AND Date >= ?;', sqlLogs:getPrefix(),  DATE_AFTER)
	local ordersResult = Async.wait()
	
	sqlLogs:queryFetchSingle(Async.waitFor(), 'SELECT COUNT(*) as Anzahl FROM ??_ammunation WHERE (Type LIKE "Bestellung" OR Type LIKE "Shop") AND Date >= ?;', sqlLogs:getPrefix(), DATE_AFTER) -- could be done with table.count but using sql for COUNT is faster
	local totalOrders = Async.wait().Anzahl
	
	sqlLogs:queryFetchSingle(Async.waitFor(), 'SELECT SUM(Costs) as Kosten FROM ??_ammunation WHERE (Type LIKE "Bestellung" OR Type LIKE "Shop") AND Date >= ?;', sqlLogs:getPrefix(), DATE_AFTER) -- could be done with table.count but using sql for SUM is fastern
	local totalCosts = Async.wait().Kosten

	local currentCount = 0

	local preTick = getTickCount()

	sqlLogs:queryFetch(Async.waitFor(), "SELECT Weapon, Count(*) as Kills FROM ??_Kills WHERE Date >= ? GROUP BY Weapon", sqlLogs:getPrefix(), DATE_AFTER)
	local killDataResult = Async.wait()

	sqlLogs:queryFetch(Async.waitFor(), "SELECT Weapon, Count(Damage) as Damage FROM ??_Damage WHERE Date >= ? GROUP BY Weapon", sqlLogs:getPrefix(), DATE_AFTER)
	local damageDataResult = Async.wait()

	sqlLogs:queryFetchSingle(Async.waitFor(), "SELECT Count(*) as Kills FROM ??_Kills WHERE Date >= ?", sqlLogs:getPrefix(), DATE_AFTER)
	local totalKills = Async.wait().Kills

	sqlLogs:queryFetchSingle(Async.waitFor(), "SELECT Count(*) as Damage FROM ??_Damage WHERE Date >= ?", sqlLogs:getPrefix(), DATE_AFTER)
	local totalDamage = Async.wait().Damage

	local killData = {}
	for weapon, data in pairs(killDataResult) do 
		percentage = formatPercentage(data.Kills, totalKills)
		killData[scope_tonumber(data.Weapon)]  = {data.Kills, formatPercentage(data.Kills, totalKills)}
	end

	
	local damageData = {}
	for weapon, data in pairs(damageDataResult) do 
		percentage = formatPercentage(data.Damage, totalDamage)
		damageData[scope_tonumber(data.Weapon)]  = {data.Damage, formatPercentage(data.Damage, totalDamage)}
	end

	debug.sethook(nil) -- suppress infinite-loop
	
	for k, row in scope_pairs(ordersResult) do 
		currentCount = currentCount + 1
		data = fromJSON(row.Weapons) 
		for key, obj in scope_pairs( data ) do
			if not self.m_EvaluationTable[scope_tonumber(key)] then 
				self.m_EvaluationTable[scope_tonumber(key)] = {}
				self.m_EvaluationTable[scope_tonumber(key)]["Waffe"] = 0
				self.m_EvaluationTable[scope_tonumber(key)]["Munition"] = 0
			end

			if scope_type(data[key]) == "table" then
				self.m_EvaluationTable[scope_tonumber(key)]["Waffe"] = self.m_EvaluationTable[scope_tonumber(key)]["Waffe"] + scope_tonumber(data[key]["Waffe"])
				self.m_EvaluationTable[scope_tonumber(key)]["Munition"] = self.m_EvaluationTable[scope_tonumber(key)]["Munition"] + scope_tonumber(data[key]["Munition"])
			elseif scope_type(data[key]) == "number" then
				self.m_EvaluationTable[scope_tonumber(key)]["Munition"] = self.m_EvaluationTable[scope_tonumber(key)]["Munition"] + scope_tonumber(data[key])-1
				self.m_EvaluationTable[scope_tonumber(key)]["Waffe"] = self.m_EvaluationTable[scope_tonumber(key)]["Waffe"] + 1
			end
			
			if (currentCount  % 100 == 0 or currentCount == totalOrders) then
				scope_print(("Auswertung Ammunation: %s von %s (%.2f%%)"):format(currentCount, totalOrders, (currentCount/totalOrders)*100))
			end
		end
	end

	local postTick = getTickCount() 
	self.m_Time = postTick - preTick
	scope_print(("Ammunation-Evaluation took %s seconds!"):format(self.m_Time/1000))

	self:writeLineToFile(("Zeitraum vom %s bis %s"):format(DATE_AFTER, os.date('%Y-%m-%d %H:%M:%S', getRealTime().timestamp)))
	self:writeLineToFile("\n")

	self:writeLineToFile(("**Einnahmen insgesamt %s!**"):format(toMoneyString(totalCosts)))
	self:writeLineToCSV(("Waffe, Anzahl, Stückverkauf, Magazin, Magazinverkauf, Anteil an Toden, Anteil an Schaden")) -- setup csv-titles for ammunation 

	self:writeLineToCSV(("Art, Tode, Anteil an Toden, Schaden, Antel an Schaden"), "deathmatch") -- setup csv-titles for general damage

	local costWeapon, costMagazine, pieceOnly, weapon
	for k, data in pairs(self.m_EvaluationTable) do
		weapon = scope_tonumber(k)
		if AmmuNationInfo[weapon] then 
			if AmmuNationInfo[weapon].Weapon then 
				costWeapon = data["Waffe"] * AmmuNationInfo[weapon].Weapon 
			else 
				costWeapon = 0
			end 
			if AmmuNationInfo[weapon].Magazine then 
				costMagazine = data["Munition"] * AmmuNationInfo[weapon].Magazine.price
			else 
				costMagazine = 0
			end 	
			
			
			if AmmuNationInfo[weapon].Magazine then
				self:writeLineToFile(("\n%s: \n Stück -> %i Stück für %s verkauft!\n Munition -> %i Munition für %s verkauft"):format((weapon and weapon > 0 and WEAPON_NAMES[weapon]) or "Schutzweste", data["Waffe"], toMoneyString(costWeapon), data["Munition"], toMoneyString(costMagazine)))
				if killData[weapon] and weapon > 0 then -- > 0 because in the ammunation 0 is considered to be a bulletproof vest whereas in gta 0 is considered the fist
					self:writeLineToFile((" Anteil an Tötungen mit dieser Waffe: %s%%"):format(killData[weapon][2]))
				end
				if damageData[weapon] and weapon > 0 then -- > 0 because in the ammunation 0 is considered to be a bulletproof vest whereas in gta 0 is considered the fist
					self:writeLineToFile((" Anteil an Schaden mit dieser Waffe: %s%%"):format(damageData[weapon][2]))
				end
			else
				self:writeLineToFile(("\n%s: \n Stück -> %i Stück für %s verkauft!"):format((weapon and weapon > 0 and WEAPON_NAMES[weapon]) or "Schutzweste", data["Waffe"], toMoneyString(costWeapon), data["Munition"]))
				if killData[weapon] and weapon > 0 then -- > 0 because in the ammunation 0 is considered to be a bulletproof vest whereas in gta 0 is considered the fist
					self:writeLineToFile((" Anteil an Tötungen mit dieser Waffe: %s%%"):format(killData[weapon][2]))
				end
				if damageData[weapon] and weapon > 0 then -- > 0 because in the ammunation 0 is considered to be a bulletproof vest whereas in gta 0 is considered the fist
					self:writeLineToFile((" Anteil an Schaden mit dieser Waffe: %s%%"):format(damageData[weapon][2]))
				end
			end
			
			self:writeLineToCSV(("%s, %s, %s, %s, %s, %s, %s"):format(
				(weapon and weapon > 0 and WEAPON_NAMES[weapon]) or "Schutzweste", 
				data["Waffe"],
				costWeapon, 
				data["Munition"], 
				costMagazine, 
				killData[weapon] and killData[weapon][2] or 0, 
				damageData[weapon] and damageData[weapon][2] or 0
			))
		end
	end

	local percentageCheck = 0
	local percentage
	local copyKillData = {} -- used for accessing kill data outside of the sql
	self:writeLineToFile(("\n**Totale Tötungen: %s**"):format(totalKills))
	for weapon, data in pairs(killData) do 
		weapon = scope_tonumber(weapon)
		self:writeLineToFile((" %s - %s (%s%%)"):format(damageTypes[weapon] or WEAPON_NAMES[weapon] or getWeaponNameFromID(weapon), data[1], data[2]))
		percentageCheck = percentageCheck + data[2]
		copyKillData[weapon] = {data[1], data[2]}
	end
	self:writeLineToFile(("\n->Prozent der Tötungen die nicht in der Statistik sind: %s%%"):format(100 - percentageCheck))
	
	percentageCheck = 0
	self:writeLineToFile(("\n**Totaler Schaden: %s**"):format(totalDamage))
	for weapon, data in pairs(damageData) do 
		weapon = scope_tonumber(weapon)
		self:writeLineToFile((" %s - %s (%s%%)"):format(damageTypes[weapon] or WEAPON_NAMES[weapon] or getWeaponNameFromID(weapon), data[1], data[2]))
		percentageCheck = percentageCheck + data[2]

		self:writeLineToCSV(("%s, %s, %s, %s, %s"):format(damageTypes[weapon] or WEAPON_NAMES[weapon] or getWeaponNameFromID(weapon), 
		killData[weapon] and killData[weapon][1] or 0,
		killData[weapon] and killData[weapon][2] or 0,
		damageData[weapon] and damageData[weapon][1] or 0,
		damageData[weapon] and damageData[weapon][2] or 0
		), "deathmatch") 

	end
	self:writeLineToFile(("\n-> Prozent des Schadens der nicht in der Statistik ist: %s%%"):format(100 - percentageCheck))
	self:writeLineToFile("\n")

	self:closeFile()
	self:closeCSV()
end


function AmmunationEvaluation:getFile() 
	if not self.m_File then
		self.m_File = fileCreate(("Evaluation/%s.text"):format(EVALUATION_FILE))
		return self.m_File
	else 
		return self.m_File 
	end
end

function AmmunationEvaluation:getCSV(identifier) 
	if (identifier and not self.m_CSVTable[identifier]) or not self.m_CSV then
		local csv  = fileCreate(("Evaluation/%s.csv"):format(identifier or EVALUATION_CSV))
		if not identifier then 
			self.m_CSV = csv
		else 
			self.m_CSVTable[identifier] = csv
		end 
		return csv	
	else
		if identifier then 
			return self.m_CSVTable[identifier]
		else 
			return self.m_CSV
		end 
	end
end

function AmmunationEvaluation:closeFile() 
	fileClose(self:getFile())
end

function AmmunationEvaluation:closeCSV() 
	fileClose(self:getCSV())
	for ident, file in pairs(self.m_CSVTable) do 
		fileClose(file)
	end
end


function AmmunationEvaluation:writeLineToFile(string)
	fileWrite(self:getFile(), ("%s\n"):format(string)) 
end

function AmmunationEvaluation:writeLineToCSV(string, identifier)
	fileWrite(self:getCSV(identifier), ("%s\n"):format(string)) 
end

function AmmunationEvaluation:destructor()

end
