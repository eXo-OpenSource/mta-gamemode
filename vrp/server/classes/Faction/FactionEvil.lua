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
	self.InteriorEnterExit = {}
	self.m_WeaponPed = {}
	self.m_ItemDepot = {}

	nextframe(function()
		self:loadLCNGates(5)
	end)

	for Id, faction in pairs(FactionManager:getAllFactions()) do
		if faction:isEvilFaction() then
			self:createInterior(Id, faction)
		end
	end
end

function FactionEvil:destructor()
end

function FactionEvil:createInterior(Id, faction)
	self.InteriorEnterExit[Id] = InteriorEnterExit:new(evilFactionInteriorEnter[Id], Vector3(2807.32, -1173.92, 1025.57), 0, 0, 8, Id)
	self.m_WeaponPed[Id] = NPC:new(FactionManager:getFromId(Id):getRandomSkin(), 2819.20, -1166.77, 1025.58, 133.63)
	setElementDimension(self.m_WeaponPed[Id], Id)
	setElementInterior(self.m_WeaponPed[Id], 8)
	self.m_WeaponPed[Id]:setImmortal(true)
	self.m_WeaponPed[Id]:setData("clickable",true,true) -- Makes Ped clickable
	self.m_WeaponPed[Id].Faction = faction
	addEventHandler("onElementClicked", self.m_WeaponPed[Id], bind(self.onWeaponPedClicked, self))

	self.m_ItemDepot[Id] = createObject(2972, 2816.8, -1173.5, 1024.4, 0, 0, 0)
	self.m_ItemDepot[Id]:setDimension(Id)
	self.m_ItemDepot[Id]:setInterior(8)
	self.m_ItemDepot[Id].Faction = faction
	self.m_ItemDepot[Id]:setData("clickable",true,true) -- Makes Ped clickable
	addEventHandler("onElementClicked", self.m_ItemDepot[Id], bind(self.onDepotClicked, self))

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
		createObject(2332, 2814.6001, -1173.8, 1026.6, 0, 0, 180)
	}
	for k,v in pairs(int) do
		setElementDimension(v, Id)
		setElementInterior(v, 8)
		if v:getModel() == 2332 then
			faction:setSafe(v)
		end
	end
end

function FactionEvil:getOnlinePlayers()
	local factions = FactionManager:getSingleton():getAllFactions()
	local players = {}
	for index,faction in pairs(factions) do
		if faction:isEvilFaction() then
			for index, value in pairs(faction:getOnlinePlayers()) do
				table.insert(players, value)
			end
		end
	end
	return players
end

function FactionEvil:giveKarmaToOnlineMembers(karma, reason)
	for k, player in pairs(self:getOnlinePlayers()) do
		player:giveKarma(karma)
		player:sendShortMessage(_("%s\nDu hast %d Karma erhalten!", player, reason, karma), "Karma")
	end
end

function FactionEvil:onWeaponPedClicked(button, state, player)
	if button == "left" and state == "down" then
		if player:getFaction() and player:getFaction() == source.Faction then
			player:triggerEvent("showFactionWeaponShopGUI")
		else
			player:sendError(_("Dieser Waffenverkäufer liefert nicht an deine Fraktion!", player))
		end
	end
end

function FactionEvil:onDepotClicked(button, state, player)
	if button == "left" and state == "down" then
		if player:getFaction() and player:getFaction() == source.Faction then
			player:getFaction():getDepot():showItemDepot(player)
		else
			player:sendError(_("Dieses Depot gehört nicht deiner Fraktion!", player))
		end
	end
end

function FactionEvil:loadLCNGates(factionId)
	local lcnGates = {}
	lcnGates[1] = Gate:new(980, Vector3(783.60, -1152.40, 25.20), Vector3(0, 0, 90), Vector3(783.60, -1152.40, 19.80))
	lcnGates[2] = Gate:new(980, Vector3(661.20, -1228.00, 17.50), Vector3(0, 0, 241.25), Vector3(661.20, -1228.00, 12))
	lcnGates[3] = Gate:new(980, Vector3(664.90, -1307.90, 15.20), Vector3(0, 0, 0), Vector3(664.90, -1307.90, 9.20))
	lcnGates[3]:addCustomShapes(Vector3(664.80, -1302.78, 13.46), Vector3(664.64, -1313.76, 13.46))
	for index, gate in pairs(lcnGates) do
		gate:setOwner(FactionManager:getSingleton():getFromId(factionId))
		gate.onGateHit = bind(self.onBarrierGateHit, self)
	end
end

function FactionEvil:onBarrierGateHit(player, gate)
    if player:getFaction() == gate:getOwner() then
		return true
	else
		return false
	end

end
