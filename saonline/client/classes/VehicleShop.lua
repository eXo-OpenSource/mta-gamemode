-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/VehicleShop.lua
-- *  PURPOSE:     VehicleShop class
-- *
-- ****************************************************************************
VehicleShop = inherit(Object)

function VehicleShop:constructor(name, imagePath, position, vehicles)
	self.m_Name = name
	self.m_ImagePath = imagePath
	self.m_Marker = createMarker(position.X, position.Y, position.Z, "cylinder", 1, 255, 255, 0, 150)
	self.m_Vehicles = vehicles
	addEventHandler("onClientMarkerHit", self.m_Marker, bind(self.markerHit, self))
end

function VehicleShop:markerHit(hitElement, matchingDimension)
	if hitElement == localPlayer and matchingDimension then
		local shopGUI = VehicleShopGUI:getSingleton()
		shopGUI:setShopLogoPath(self.m_ImagePath)
		shopGUI:setVehicleList(self.m_Vehicles)
		VehicleShopGUI:getSingleton():setVisible(true)
	end
end

function VehicleShop.createShops()
	for shopName, info in pairs(VEHICLESHOPS) do
		local x, y, z = unpack(info.Position)
		VehicleShop:new(shopName, info.ImgPath, Vector(x, y, z), info.Vehicles)
	end
end
