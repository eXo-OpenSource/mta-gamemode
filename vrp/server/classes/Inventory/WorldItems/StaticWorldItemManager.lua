-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/StaticWorldItemManager.lua
-- *  PURPOSE:     This class manages StaticWorldItems
-- *
-- ****************************************************************************
StaticWorldItemManager = inherit(Singleton)

StaticWorldItemManager.Items = {
	["Mushroom"]= {
		["class"] = StaticItemMushroom,
		["offsetZ"] = -1,
		["chance"] = 33,
		["enabled"] = true
	},
	["Osterei"] = {
		["class"] = StaticItemEasterEgg,
		["offsetZ"] = -0.85,
		["chance"] = 33,
		["enabled"] = EVENT_EASTER
	},
	["Kürbis"] = {
		["class"] = StaticItemPumpkin,
		["offsetZ"] = -0.85,
		["chance"] = 33,
		["enabled"] = EVENT_HALLOWEEN
	}
}

function StaticWorldItemManager:constructor()
    self.m_Items = {}
    self:loadItems()

    self.m_TimedPulse = TimedPulse:new(1000*60*60)
	self.m_TimedPulse:registerHandler(bind(self.loadItems, self))
    self:loadItems()
end

function StaticWorldItemManager:destructor()

end

function StaticWorldItemManager:loadItems()
    for index, item in pairs(self.m_Items) do
        delete(item)
    end

    self.m_Items = {}

    for itemType, itemData in pairs(StaticWorldItemManager.Items) do
        if itemData["enabled"] == true then
            local result = sql:queryFetch("SELECT * FROM ??_word_objects WHERE Typ = ?", sql:getPrefix(), itemType)
            for index, row in pairs(result) do
                if DEBUG or chance(itemData["chance"]) then
                    local itemClass = itemData["class"]
                    local position = Vector3(row.PosX, row.PosY, row.PosZ)
                    local rotation = Vector3(0, 0, row.RotationZ)

                    self.m_Items[row.Id] = itemClass:new(position, rotation, row.Interior or 0, row.Dimension or 0, row.Value)
                end
            end
        end
    end
end