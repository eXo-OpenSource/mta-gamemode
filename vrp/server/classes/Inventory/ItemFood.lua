-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemFood.lua
-- *  PURPOSE:     Food Item Super class
-- *
-- ****************************************************************************
ItemFood = inherit(Item)

ItemFood.Settings = {
	["Burger"] = {["Health"] = 80, ["Text"] = "einen Burger"}
}

function ItemFood:constructor()

end

function ItemFood:destructor()

end

function ItemFood:use(player)
	-- TODO: self:getName() does not work yet
	player:setHealth(player:getHealth()+ItemFood.Settings[self:getName()]["Health"])
	player:meChat(true, "isst "..ItemFood.Settings[self:getName()]["Text"].."!")
end
