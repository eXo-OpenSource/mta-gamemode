-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/ShopManager.lua
-- *  PURPOSE:     Shop Manager Class
-- *
-- ****************************************************************************
ShopManager = inherit(Singleton)

function ShopManager:constructor()
	PizzaStack:new(Vector3(374.68, -118.80, 1000.6), 5, 5)
end
