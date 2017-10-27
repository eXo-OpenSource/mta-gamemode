-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/Wearables/WearableHelmet.lua
-- *  PURPOSE:     Wearable Helmets
-- *
-- ****************************************************************************
WearableHelmet = inherit( Item )

WearableHelmet.objectTable =
{
	["Helm"] = {2052, 0.05, 0.05, 1, 5, 180, "Integral-Helm",true},
	["Motorcross-Helm"] = {1924, 0.09, 0.02, 0.9, 10, 180,"Motocross-Helm",true},
	["Pot-Helm"] = {3911,0.1, 0, 1, 0, 180, "Biker-Helm",false},
	["Einsatzhelm"] = {3911,0.1, 0.05, 0.95, 10, 180, "Einsatzhelm",false},
	["Gasmaske"] = {3890,0, 0.15, 0.9, 0, 90, "Gasmaske",true},
	["Hasenohren"] = {1934, 0, 0, 1, 0, 180, "Hasenohren", true},
}

function WearableHelmet:constructor()
	self.m_Helmets = {}
end

function WearableHelmet:destructor()

end

function WearableHelmet:use(player, itemId, bag, place, itemName)
	local inventory = InventoryManager:getSingleton():getPlayerInventory(player)
	local value = inventory:getItemValueByBag( bag, place)
	if value then --// for texture usage later

	end
	if not player.m_IsWearingHelmet and not player.m_Helmet then --// if the player clicks onto the helmet without currently wearing one
		outputChatBox(itemName)
		if itemName == "Einsatzhelm" and (not player:getFaction() or not player:getFaction():isStateFaction() or not player:isFactionDuty()) then
			player:sendError(_("Du bist nicht im Dienst! Das Item wurde abgenommen.", player))
			player:getInventory():removeAllItem(self:getName())
			return
		end
		if isElement(player.m_Helmet) then
			destroyElement(player.m_Helmet)
		end
		local x,y,z = getElementPosition(player)
		local dim = getElementDimension(player)
		local int = getElementInterior(player)
		local model, zOffset, yOffset, scale, rotX, rotZ  = WearableHelmet.objectTable[itemName][1] or WearableHelmet.objectTable["Helm"][1],  WearableHelmet.objectTable[itemName][2] or WearableHelmet.objectTable["Helm"][2], WearableHelmet.objectTable[itemName][3] or WearableHelmet.objectTable["Helm"][3], WearableHelmet.objectTable[itemName][4] or WearableHelmet.objectTable["Helm"][4], WearableHelmet.objectTable[itemName][5] or WearableHelmet.objectTable["Helm"][5],  WearableHelmet.objectTable[itemName][6] or WearableHelmet.objectTable["Helm"][6]
		local obj = createObject(model,x,y,z)
		local objName =  WearableHelmet.objectTable[itemName][7]
		local isFaceConcealed = WearableHelmet.objectTable[itemName][8]
		setElementDimension(obj, dim)
		setElementInterior(obj, int)
		setObjectScale(obj, scale)
		setElementDoubleSided(obj,true)
		exports.bone_attach:attachElementToBone(obj, player, 1, 0, yOffset, zOffset, rotX , 0, rotZ)
		player.m_Helmet = obj
		player.m_IsWearingHelmet = itemName
		player:meChat(true, "zieht "..objName.." an!")
		player:setData("isFaceConcealed", isFaceConcealed)
		if itemName == "Einsatzhelm" then
			obj:setData("isProtectingHeadshot", true)
		elseif itemName == "Hasenohren" then
			player:giveAchievement(90) -- Trage die tollen Hasenohren
		end
	elseif player.m_IsWearingHelmet == itemName and player.m_Helmet then --// if the player clicks onto the same helmet once more remove it
		destroyElement(player.m_Helmet)
		self.m_Helmets[player] = nil
		player.m_IsWearingHelmet = false
		player.m_Helmet = false
		player:setData("isFaceConcealed", false)
		player:meChat(true, "setzt "..WearableHelmet.objectTable[itemName][7].." ab!")
	else --// else the player must have clicked on another helmet otherwise this instance of the class would have not been called
		if itemName == "Einsatzhelm" and not player:getFaction() or not player:getFaction():isStateFaction() or not player:isFactionDuty() then
			player:sendError(_("Du bist nicht im Dienst! Das Item wurde abgenommen.", player))
			player:getInventory():removeAllItem(self:getName())
			return
		end
		if isElement(player.m_Helmet) then
			destroyElement(player.m_Helmet)
		end
		local x,y,z = getElementPosition(player)
		local model, zOffset, yOffset, scale, rotX, rotZ  = WearableHelmet.objectTable[itemName][1] or WearableHelmet.objectTable["Helm"][1],  WearableHelmet.objectTable[itemName][2] or WearableHelmet.objectTable["Helm"][2], WearableHelmet.objectTable[itemName][3] or WearableHelmet.objectTable["Helm"][3], WearableHelmet.objectTable[itemName][4] or WearableHelmet.objectTable["Helm"][4], WearableHelmet.objectTable[itemName][5] or WearableHelmet.objectTable["Helm"][5],  WearableHelmet.objectTable[itemName][6] or WearableHelmet.objectTable["Helm"][6]
		local obj = createObject(model,x,y,z)
		local dim = getElementDimension(player)
		local int = getElementInterior(player)
		local objName =  WearableHelmet.objectTable[itemName][7]
		local isFaceConcealed = WearableHelmet.objectTable[itemName][8]
		setElementDimension(obj, dim)
		setElementInterior(obj, int)
		setObjectScale(obj, scale)
		setElementDoubleSided(obj,true)
		exports.bone_attach:attachElementToBone(obj, player, 1, 0, yOffset, zOffset, rotX, 0, rotZ)
		player.m_Helmet = obj
		player.m_IsWearingHelmet = itemName
		player:meChat(true, "zieht "..objName.." an!")
		player:setData("isFaceConcealed", isFaceConcealed)
		if itemName == "Einsatzhelm" then
			obj:setData("isProtectingHeadshot", true)
		end
	end
end
