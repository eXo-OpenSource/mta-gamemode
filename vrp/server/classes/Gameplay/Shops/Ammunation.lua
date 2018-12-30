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

	self.m_TypeName = typeData["Name"]

	self.m_Weapons = {}
	self.m_Magazines = {}
	self:loadWeapons()

	--addEventHandler("onMarkerHit", self.m_Marker, bind(self.onAmmunationMarkerHit, self))

	if self.m_Ped then
		self.m_Ped:setData("clickable",true,true)
		addEventHandler("onElementClicked", self.m_Ped, function(button, state, player)
			if button =="left" and state == "down" then
				self:onAmmunationMarkerHit(player, true)
			end
		end)
	end
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
		if self.m_Robable and self.m_Robable.m_RobActive then return end

		hitElement:triggerEvent("showAmmunationMenu")
		triggerClientEvent(hitElement, "refreshAmmunationMenu", hitElement, self.m_Id, self.m_TypeName, self.m_Weapons, self.m_Magazines)
	end
end
