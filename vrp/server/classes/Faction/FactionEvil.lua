-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionEvil.lua
-- *  PURPOSE:     Evil Faction Class
-- *
-- ****************************************************************************

FactionEvil = inherit(Singleton)
  -- implement by children

function FactionEvil:constructor()
	outputDebugString("Faction Evil loaded")

	self.InteriorEnterExit = {}
	self.WeaponPed = {}

	for Id,faction in pairs(FactionManager:getAllFactions()) do
		if faction:isEvilFaction() then
			self:createInterior(Id)
		end
	end

	WeaponTruck:getSingleton():new()
end

function FactionEvil:destructor()
end

function FactionEvil:createInterior(Id)
	self.InteriorEnterExit[Id] = InteriorEnterExit:new(Vector3(evilFactionInteriorEnter[Id]["x"], evilFactionInteriorEnter[Id]["y"], evilFactionInteriorEnter[Id]["z"]), Vector3(2807.32, -1173.92, 1025.57), 0, 0, 8, Id)
	self.WeaponPed[Id] = NPC:new(FactionManager:getFromId(Id):getRandomSkin(), 2819.20, -1166.77, 1025.58, 133.63)
	setElementDimension(self.WeaponPed[Id], Id)
	setElementInterior(self.WeaponPed[Id], 8)
	setElementData(self.WeaponPed[Id],"clickable",true) -- Makes Ped clickable
	setElementData(self.WeaponPed[Id],"factionWeaponShopPed",true)  -- Set factionWeaponShopPed for clickable
	local int = {
		createObject(351, 2818, -1173.6, 1025.6, 80, 340, 0),
		createObject(348, 2813.6001, -1166.8, 1025.64, 90, 0, 332),
		createObject(3016, 2820.3999, -1167.7, 1025.7, 0, 0, 18),
		createObject(1271, 2818.69995, -1167.30005, 1025.40002, 0, 0, 314),
		createObject(1271, 2818.19995, -1166.80005, 1024.69995, 0, 0, 314),
		createObject(1271, 2818.2, -1166.8, 1025.4, 0, 0, 312),
		createObject(1271, 2818.7, -1167.3, 1024.7, 0, 0, 313.995),
		createObject(1271, 2819.2, -1167.8, 1024.7, 0, 0, 314.495),
		createObject(1271, 2819.2, -1167.8, 1025.4, 0, 0, 315.25),
		createObject(2041, 2819.1001, -1165.2, 1025.9, 0, 0, 10),
		createObject(2042, 2818.3, -1166.8, 1025.8),
		createObject(2359, 2817.7, -1165.1, 1025.9, 0, 0, 348),
		createObject(2358, 2820.2, -1165.1, 1024.7 ),
		createObject(2358, 2820.19995, -1165.09998, 1024.90002, 0, 0, 354),
		createObject(2358, 2820.2, -1165.1, 1025.1, 0, 0, 10),
		createObject(2358, 2820.2, -1165.1, 1025.3),
		createObject(2358, 2820.2, -1165.1, 1025.5, 0, 0, 348),
		createObject(349, 2818.8999, -1167.7, 1025.8, 90, 0, 0),
		createObject(2977, 2819.3, -1170.6, 1024.4, 0, 0, 30.5),
		createObject(2977, 2816.8, -1173.5, 1024.4, 0, 0, 4.498),
		createObject(2332, 2814.6001, -1173.8, 1026.6, 0, 0, 180)
	}
	for k,v in pairs(int) do
		setElementDimension(v, Id)
		setElementInterior(v, 8)
	end
end
