-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/Itemshop.lua
-- *  PURPOSE:     Item shop class
-- *
-- ****************************************************************************
ItemShop = inherit(Shop)

function ItemShop:constructor(id, position, typeData, dimension, robable)
	local interior, intPosition = unpack(typeData["Interior"])
	local pedSkin, pedPosition, pedRotation = unpack(typeData["Ped"])
	--	Blip:new("Shop.png", position.x, position.y)

	InteriorEnterExit:new(position, intPosition, 0, 0, interior, dimension)
	if robable == 1 then
		RobableShop:new(pedPosition, pedRotation, pedSkin, interior, dimension)
	else
		createPed(pedSkin, pedPosition, pedRotation)
	end
	self.m_Marker = createMarker(typeData["Marker"], "cylinder", 1, 255, 255, 0, 200)
	self.m_Marker:setInterior(interior)
	self.m_Marker:setDimension(dimension)
	self.m_Type = "ItemShop"
	self.m_Items = {["Radio"] = 2000,
		["Zigaretten"] = 10,
		["Wuerfel"] = 10
	}

	addEventHandler("onMarkerHit", self.m_Marker, bind(self.onItemMarkerHit, self))


end
