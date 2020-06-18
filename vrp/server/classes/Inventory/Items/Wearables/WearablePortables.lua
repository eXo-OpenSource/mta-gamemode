-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/Wearables/WearablePortables.lua
-- *  PURPOSE:     Wearable Portabless
-- *
-- ****************************************************************************
WearablePortables = inherit(ItemNew)

--{model, bone, x, y, z, rx, ry, rz, scale, doublesided, texture},
--3,0,-0.1325,0.145,0,0,0,1
WearablePortables.Data =
{
	["swatshield"] = {offset = Vector3(0, -0.15, -0.05), rotation = Vector3(180, 90, -40), scale = 0.8},
}

function WearablePortables:use()
	local player = self.m_Inventory:getPlayer()
	if not player then return false end
	if player.m_PrisonTime > 0 then player:sendError("Im Prison nicht erlaubt!") return end
	if player.m_JailTime > 0 then player:sendError("Im Gefängnis nicht erlaubt!") return end
	local data = WearablePortables.Data[self:getTechnicalName()]

	if player.m_IsWearingPortables == self:getTechnicalName() and player.m_Portables then
		destroyElement(player.m_Portables)
		player.m_IsWearingPortables = false
		player.m_Portables = false
		player:meChat(true, "legt " .. self:getName() .. " weg!")
	else
		if isElement(player.m_Portables) then
			destroyElement(player.m_Portables)
		end

		local obj = createObject(self:getModel(), player.position)
		obj:setDimension(player.dimension)
		obj:setInterior(player.interior)
		obj:setScale(data.scale)
		obj:setDoubleSided(true)
		setElementData(obj, "boneattach:setCollision", false)
		exports.bone_attach:attachElementToBone(obj, player, 11, data.offset.x, data.offset.y, data.offset.z, data.rotation.x, data.rotation.y, data.rotation.z)
		player.m_Portables = obj
		player.m_IsWearingPortables = self:getTechnicalName()
		player:meChat(true, "nimmt " .. self:getName() .. " in die Hand!")
	end
end
