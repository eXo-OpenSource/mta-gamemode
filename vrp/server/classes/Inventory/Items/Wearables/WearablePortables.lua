-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/Wearables/WearablePortables.lua
-- *  PURPOSE:     Wearable Portabless
-- *
-- ****************************************************************************
WearablePortables = inherit( Item )

--{model, bone, x, y, z, rx, ry, rz, scale, doublesided, texture},
--3,0,-0.1325,0.145,0,0,0,1
WearablePortables.objectTable =
{
	["Swatschild"] = {1631, -0.05, -0.15, 0.8, 180, -40,90, false,"Swat-Schild",0.4},
}

function WearablePortables:constructor()
	self.m_Portabless = {}
end

function WearablePortables:destructor()

end

function WearablePortables:use(player, itemId, bag, place, itemName)
	local inventory = player:getInventory()
	local value = inventory:getItemValueByBag( bag, place)
	if value then --// for texture usage later

	end
	if not player.m_IsWearingPortables and not player.m_Portables then --// if the player clicks onto the Portables without currently wearing one
		if isElement(player.m_Portables) then
			destroyElement(player.m_Portables)
		end
		local x,y,z = getElementPosition(player)
		local dim = getElementDimension(player)
		local int = getElementInterior(player)
		local model, zOffset, yOffset, scale, rotX, rotZ = WearablePortables.objectTable[itemName][1] or WearablePortables.objectTable["Swatschild"][1],  WearablePortables.objectTable[itemName][2] or WearablePortables.objectTable["Swatschild"][2], WearablePortables.objectTable[itemName][3] or WearablePortables.objectTable["Swatschild"][3], WearablePortables.objectTable[itemName][4] or WearablePortables.objectTable["Swatschild"][4], WearablePortables.objectTable[itemName][5] or WearablePortables.objectTable["Swatschild"][5],  WearablePortables.objectTable[itemName][6] or WearablePortables.objectTable["Swatschild"][6]
		local rotY =  WearablePortables.objectTable[itemName][7] or WearablePortables.objectTable["Swatschild"][7]
		local obj = createObject(model,x,y,z)
		local objCollision =  WearablePortables.objectTable[itemName][8]
		local objName =  WearablePortables.objectTable[itemName][9]
		setElementDimension(obj, dim)
		setElementInterior(obj, int)
		setObjectScale(obj, scale)
		setElementDoubleSided(obj,true)
		setElementData(obj,"boneattach:setCollision",objCollision)
		exports.bone_attach:attachElementToBone(obj, player, 11, 0, yOffset, zOffset, rotX , rotY, rotZ)
		player.m_Portables = obj
		player.m_IsWearingPortables = itemName
		player:meChat(true, "nimmt "..objName.." in die Hand!")
	elseif player.m_IsWearingPortables == itemName and player.m_Portables then --// if the player clicks onto the same Portables once more remove it
		destroyElement(player.m_Portables)
		self.m_Portabless[player] = nil
		player.m_IsWearingPortables = false
		player.m_Portables = false
		player:meChat(true, "legt "..WearablePortables.objectTable[itemName][9].." nieder!")
	else --// else the player must have clicked on another Portables otherwise this instance of the class would have not been called
		if isElement(player.m_Portables) then
			destroyElement(player.m_Portables)
		end
		local x,y,z = getElementPosition(player)
		local model, zOffset, yOffset, scale, rotX, rotZ  = WearablePortables.objectTable[itemName][1] or WearablePortables.objectTable["Swatschild"][1],  WearablePortables.objectTable[itemName][2] or WearablePortables.objectTable["Swatschild"][2], WearablePortables.objectTable[itemName][3] or WearablePortables.objectTable["Swatschild"][3], WearablePortables.objectTable[itemName][4] or WearablePortables.objectTable["Swatschild"][4], WearablePortables.objectTable[itemName][5] or WearablePortables.objectTable["Swatschild"][5],  WearablePortables.objectTable[itemName][6] or WearablePortables.objectTable["Swatschild"][6]
		local rotY =  WearablePortables.objectTable[itemName][7] or WearablePortables.objectTable["Swatschild"][7]
		local obj = createObject(model,x,y,z)
		local dim = getElementDimension(player)
		local int = getElementInterior(player)
		setElementDimension(obj, dim)
		setElementInterior(obj, int)
		setObjectScale(obj, scale)
		exports.bone_attach:attachElementToBone(obj, player, 11, 0, yOffset, zOffset, rotX, rotY, rotZ)
		player.m_Portables = obj
		player.m_IsWearingPortables = itemName
		player:meChat(true, "legt "..WearablePortables.objectTable[itemName][8].." nieder!")
	end
end
