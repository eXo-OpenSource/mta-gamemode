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
		for i=1,43 do
			weapons[i] = {}
			weapons[i]["Id"] = i
			weapons[i]["Waffe"] = 0
			weapons[i]["Munition"] = 0
		end
		WeaponNew = true
		outputDebugString("Creating new Weapon-Table for Depot "..Id)
	end
	Depot.Map[Id] = Depot:new(Id,weapons,Owner)
	if WeaponNew == true then Depot.Map[Id]:save() end
	return Depot.Map[Id]
end

function Depot:constructor(Id, weapons)
	self.m_Id = Id
	self.m_Weapons = weapons  
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
