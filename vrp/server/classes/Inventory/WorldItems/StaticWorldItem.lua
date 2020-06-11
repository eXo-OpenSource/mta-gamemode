-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/StaticWorldItem.lua
-- *  PURPOSE:     Static World Item class
-- *
-- ****************************************************************************

StaticWorldItem = inherit(Object)

function StaticWorldItem:constructor(model, position, rotation, interior, dimension)
    self.m_Object = createObject(model, position, rotation)
    self.m_Object:setInterior(interior)
    self.m_Object:setDimension(dimension)
    self.m_Object:setData("clickable", true, true)
    addEventHandler("onElementClicked", self.m_Object, bind(self.onClick, self))
end

function StaticWorldItem:destructor()
    self.m_Object:destroy()
end

function StaticWorldItem:onClick(button, state, player)
    if button == "left" and state == "down" then
        if self.m_ItemClass then
            player:getInventory():giveItem(self.m_ItemClass, self.m_ItemAmount, self.m_ItemDurability, self.m_ItemMetaData)

            if self.onCollect then
                self:onCollect(player)
            end

            local itemName = ItemManager.get(self.m_ItemClass).Name
            player:sendInfo(_("%s gefunden!", player, itemName))
        end
        delete(self)
    end
end