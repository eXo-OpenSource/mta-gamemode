-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/VehicleShop.lua
-- *  PURPOSE:     VehicleShop class
-- *
-- ****************************************************************************
VehicleShop = inherit(Object)

function VehicleShop:constructor(name, imagePath, position, rect, vehicles)
	self.m_Name = name
	self.m_ImagePath = imagePath
	self.m_Marker = createMarker(position.x, position.y, position.z, "cylinder", 1, 255, 255, 0, 150)
	self.m_Area = NonCollidingArea:new(rect.x, rect.y, rect.Width, rect.Height)
	self.m_Blip = Blip:new("CarShop.png", position.x, position.y)
	self.m_Vehicles = vehicles
	
	addEventHandler("onClientMarkerHit", self.m_Marker, bind(self.markerHit, self))
end

function VehicleShop:destructor()
	destroyElement(self.m_Marker)
	delete(self.m_Area)
	delete(self.m_Blip)
end

function VehicleShop:markerHit(hitElement, matchingDimension)
	if hitElement == localPlayer and matchingDimension then
		local shopGUI = VehicleShopGUI:getSingleton()
		shopGUI:setShopName(self.m_Name)
		shopGUI:setShopLogoPath(self.m_ImagePath)
		shopGUI:setVehicleList(self.m_Vehicles)
		VehicleShopGUI:getSingleton():setVisible(true)
	end
end

function VehicleShop.initializeAll()
	for shopName, info in pairs(VEHICLESHOPS) do
		local x, y, z = unpack(info.Position)
		VehicleShop:new(shopName, info.ImgPath, Vector3(x, y, z), Rect:new(unpack(info.Rect)), info.Vehicles)
	end
end
