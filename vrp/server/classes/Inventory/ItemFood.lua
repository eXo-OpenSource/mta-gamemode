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
	local burger = createObject(2880,0,0,0)
	exports.bone_attach:attachElementToBone(burger, player,12,0,0,0,0,-90,0)
	player:meChat(true, "isst "..ItemFood.Settings[self:getName()]["Text"].."!")
	player:setAnimation("FOOD", "EAT_Burger", 2000, false, false, false)
	setTimer(function()
		burger:destroy()
		player:setHealth(player:getHealth()+ItemFood.Settings[self:getName()]["Health"])
	end, 4500, 1)
end
