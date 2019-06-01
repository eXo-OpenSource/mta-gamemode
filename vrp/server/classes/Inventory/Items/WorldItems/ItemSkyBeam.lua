-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/WorldItems/ItemSkyBeam.lua
-- *  PURPOSE:     Barricade item class
-- *
-- ****************************************************************************
ItemSkyBeam = inherit(Item) --this is not being used as of now (MasterM pls create !)

function ItemSkyBeam:use(player)
	if player:isCompanyDuty() and player:getCompany():getId() == CompanyStaticId.SANNEWS then
		local result = self:startObjectPlacing(player,
			function(item, position, rotation)
				if item ~= self or not position then return end
				local item = item
				self.m_WorldItem = CompanyWorldItem:new(self, player:getCompany(), position, rotation, false, player)
                self.m_WorldItem:setCompanySuperOwner(true)
                
                self.m_WorldItem:attach(createObject(2887, position), false, Vector3(0, 90, 0))

				player:getInventoryOld():removeItem(self:getName(), 1)
			end
		)
	else
		player:sendError(_("Du bist nicht im News-Dienst!", player))
		player:getInventoryOld():removeAllItem(self:getName())
	end
end

function ItemSkyBeam:removeFromWorld(player, worlditem, object)
	if object.m_LightTimer then
		self:toggleBlinkingLight(object, player)
	end
end