-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Factions/Depot.lua
-- *  PURPOSE:     Depot class
-- *
-- ****************************************************************************
Depot = inherit(Object)
Depot.Map = {}

function Depot.load(Id,Owner)
	if Depot.Map[Id] then return Depot.Map[Id] end
	local row = sql:queryFetchSingle("SELECT Weapons FROM ??_depot WHERE Id = ?;", sql:getPrefix(), Id)
	local weapons = row.Weapons
	local WeaponNew = false
	if string.len(weapons) < 10 then
		weapons = {}
		for i=1,45 do
			weapons[i] = {}
			weapons[i]["Id"] = i
			weapons[i]["Waffe"] = 0
			weapons[i]["Munition"] = 0
		end
		weapons = toJSON(weapons)
		WeaponNew = true
		outputDebugString("Creating new Weapon-Table for Depot "..Id)
	end
	Depot.Map[Id] = Depot:new(Id,weapons,Owner)
	if WeaponNew == true then Depot.Map[Id]:save() end
	return Depot.Map[Id]
end

function Depot:constructor(Id, weapons)
	self.m_Id = Id
	self.m_Weapons = fromJSON(weapons)  
end

function Depot:destructor()
  self:save()
end

function Depot:save()
	return sql:queryExec("UPDATE ??_depot SET Weapons = ? WHERE Id = ?", sql:getPrefix(), toJSON(self.m_Weapons), self.m_Id)
end

function Depot:getId()
  return self.m_Id
end

function Depot:getWeaponTable()
  return self.m_Weapons
end

function Depot:getWeapon(id)
	return self.m_Weapons[id]["Waffe"],self.m_Weapons[id]["Munition"]
end

function Depot:takeWeaponD(id,amount)
	self.m_Weapons[id]["Waffe"] = self.m_Weapons[id]["Waffe"]-amount
end

function Depot:takeMagazineD(id,amount)
	self.m_Weapons[id]["Munition"] = self.m_Weapons[id]["Munition"]-amount
end

function Depot:getPlayerWeapons(player)
	local playerWeapons = {}
	for i=1, 12 do
		if getPedWeapon(player,i) > 0 then
			playerWeapons[getPedWeapon(player,i)] = true
		end
	end
	return playerWeapons
end

function Depot:takeWeaponsFromDepot(player,weaponTable)
	local playerWeapons = self:getPlayerWeapons(player)
	outputChatBox("Du hast folgende Waffen und Magazine aus dem Lager genommen:",player,255,255,255)
	for weaponID,v in pairs(weaponTable) do
		for typ,amount in pairs(weaponTable[weaponID]) do
			if amount > 0 then
				if typ == "Waffe" then
					if self.m_Weapons[weaponID]["Waffe"] >= amount then
						outputChatBox(amount.." "..getWeaponNameFromID(weaponID),player,255,125,0)
						giveWeapon(player,weaponID,amount)
						self:takeWeaponD(weaponID,amount)
					else
						outputChatBox("Es sind nicht genug "..getWeaponNameFromID(weaponID).." im Lager! ("..amount..")",player,255,0,0)
					end
				elseif typ == "Munition" then
					playerWeapons = self:getPlayerWeapons(player)
					if playerWeapons[weaponID] then
						if self.m_Weapons[weaponID]["Munition"] >= amount then
							self:takeMagazineD(weaponID,amount)
							giveWeapon(player,weaponID,amount*getWeaponProperty(weaponID, "poor", "maximum_clip_ammo"))
							outputChatBox(amount.." "..getWeaponNameFromID(weaponID).." Magazin/e",player,255,125,0)
						else
							outputChatBox("Es sind nicht genug "..getWeaponNameFromID(weaponID).." Magazine im Lager! ("..amount..")",player,255,0,0)
						end
					else
						outputChatBox("Du hast keine "..getWeaponNameFromID(weaponID).." für ein Magazin!",player,255,0,0)
					end
				end
			end
		end
	end
	self:save()
end

