-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/Ammunation.lua
-- *  PURPOSE:     Ammunation Shop Class
-- *
-- ****************************************************************************
Ammunation = inherit(Shop)

function Ammunation:constructor(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType)
	self:create(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType)

	self.m_Weapons = {}
	self.m_Magazines = {}
	self:loadWeapons()

	addEventHandler("onMarkerHit", self.m_Marker, bind(self.onAmmunationMarkerHit, self))
end

function Ammunation:loadWeapons()

	for weaponId, data in pairs(AmmuNationInfo) do
		self.m_Weapons[weaponId] = data["Weapon"]
		if data["Magazine"] then
			self.m_Magazines[weaponId] = data["Magazine"]
		end
	end
end

function Ammunation:onAmmunationMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		if self.m_Marker then
			if not self.m_Marker.m_Disable then
				hitElement:triggerEvent("showAmmunationMenu")
				triggerClientEvent(hitElement, "refreshAmmunationMenu", hitElement, self.m_Id, self.m_Weapons, self.m_Magazines)
			end
		end
	end
end
