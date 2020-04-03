-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/Wearables/WearableHelmet.lua
-- *  PURPOSE:     Wearable Helmets
-- *
-- ****************************************************************************

WearableHelmet = inherit(ItemNew)

WearableHelmet.Data = {
	["integralHelmet"] = { offset = Vector3(0, 0.05, 0.05), rotation = Vector3(5, 0, 180), scale = 1, isFaceConcealed = true },
	["motoHelmet"] = { offset = Vector3(0, 0.02, 0.09), rotation = Vector3(10, 0, 180), scale = 0.9, isFaceConcealed = true },
	["pothelmet"] = { offset = Vector3(0, 0, 0.1), rotation = Vector3(1, 0, 180), scale = 1, isFaceConcealed = false },
	["swathelmet"] = { offset = Vector3(0, 0.05, 0.1), rotation = Vector3(10, 0, 180), scale = 0.95, isFaceConcealed = false },
	["gasmask"] = { offset = Vector3(0, 0.15, 0), rotation = Vector3(0, 0, 90), scale = 0.8, isFaceConcealed = true },
	["bunnyEars"] = { offset = Vector3(0, 0, 0), rotation = Vector3(0, 0, 180), scale = 1, isFaceConcealed = true },
	["christmasHat"] = { offset = Vector3(0, 0, 0.14), rotation = Vector3(0, 0, 90), scale = 1, isFaceConcealed = true },
	["star"] = { offset = Vector3(0, 0, 0.1), rotation = Vector3(0, 0, 90), scale = 0.2, isFaceConcealed = true }
}

function WearableHelmet:use()
	local player = self.m_Inventory:getPlayer()
	if not player then return false end
	if player.m_PrisonTime > 0 then player:sendError("Im Prison nicht erlaubt!") return end
	if player.m_JailTime > 0 then player:sendError("Im Gefängnis nicht erlaubt!") return end
	if not WearableHelmet.Data[self:getTechnicalName()] then return false end
	local data = WearableHelmet.Data[self:getTechnicalName()]
	
	if player.m_IsWearingHelmet == self:getTechnicalName() and player.m_Helmet then --// if the player clicks onto the same helmet once more remove it
		destroyElement(player.m_Helmet)
		player.m_IsWearingHelmet = false
		player.m_Helmet = false
		player:setData("isFaceConcealed", false)
		if player.m_HelmetPutOnTimer then if isTimer(player.m_HelmetPutOnTimer) then killTimer(player.m_HelmetPutOnTimer) end end
		player:meChat(true, "setzt " .. self:getName() .. " ab!")
		player:triggerEvent("onClientToggleHelmet", false, self:getTechnicalName())
		player:setPublicSync("HelmetItem", false)
		return true
	else --// else the player must have clicked on another helmet otherwise this instance of the class would have not been called
		if self:getTechnicalName() == "swathelmet" and not (player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty()) then
			player:sendError(_("Du bist nicht im Dienst! Das Item wurde abgenommen.", player))
			return true, true
		end

		if isElement(player.m_Helmet) then
			destroyElement(player.m_Helmet)
		end

		if player.m_HelmetPutOnTimer then if isTimer(player.m_HelmetPutOnTimer) then killTimer(player.m_HelmetPutOnTimer) end end

		local obj = createObject(self:getModel(), player.position)
		obj:setDimension(player.dimension)
		obj:setInterior(player.interior)
		obj:setScale(data.scale)
		obj:setDoubleSided(true)

		setPedAnimation(player, "goggles", "goggles_put_on", 500, false, false, false)
		exports.bone_attach:attachElementToBone(obj, player, 12, data.offset.x, data.offset.y, data.offset.z, data.rotation.x, data.rotation.y, data.rotation.z + 90)
		
		player.m_HelmetPutOnTimer = setTimer(function() 
			if player and isElement(player) and obj and isElement(obj) then
				exports.bone_attach:attachElementToBone(obj, player, 1, data.offset.x, data.offset.y, data.offset.z, data.rotation.x, data.rotation.y, data.rotation.z)
				setPedAnimation(player, nil) 
			end 
		end, 500, 1)

		player.m_Helmet = obj
		player.m_IsWearingHelmet = self:getTechnicalName()
		player:meChat(true, "zieht " .. self:getName() .. " an!")
		player:setData("isFaceConcealed", data.isFaceConcealed)
		
		if self:getTechnicalName() == "swathelmet" then
			obj:setData("isProtectingHeadshot", true)
		elseif self:getTechnicalName() == "bunnyEars" then
			player:giveAchievement(90) -- Trage die tollen Hasenohren
		end

		player:triggerEvent("onClientToggleHelmet", true, self:getTechnicalName())
		player:setPublicSync("HelmetItem", self:getTechnicalName())
		return true
	end
end
