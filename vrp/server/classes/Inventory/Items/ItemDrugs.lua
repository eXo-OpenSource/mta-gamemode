-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemDrugs.lua
-- *  PURPOSE:     Drugs Super class
-- *
-- ****************************************************************************
ItemDrugs = inherit(Item)
ItemDrugs.Texts = {
	["Weed"] = "raucht Weed",
	["Shrooms"] = "isst einen Magic Mushroom",
	["Heroin"] = "spritzt sich Heroin",
	["Kokain"] = "schnupft Kokain",

}

function ItemDrugs:constructor()

end

function ItemDrugs:destructor()

end

function ItemDrugs:use( player )
	player:meChat(true, ItemDrugs.Texts[self:getName()].."!")

	player:giveAchievement(73)
end
