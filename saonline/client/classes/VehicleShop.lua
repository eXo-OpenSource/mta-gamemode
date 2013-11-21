-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/VehicleShop.lua
-- *  PURPOSE:     VehicleShop class
-- *
-- ****************************************************************************
VehicleShop = inherit(Object)
outputDebug(Object)

function VehicleShop:constructor(name, imagePath, position, vehicles)
	self.m_Name = name
	self.m_ImagePath = imagePath
	self.m_Marker = createMarker(position.X, position.Y, position.Z, "cylinder", 1, 255, 255, 0, 150)
	self.m_Vehicles = vehicles
	addEventHandler("onClientMarkerHit", self.m_Marker, bind(self.markerHit, self))
end

function VehicleShop:markerHit(hitElement, matchingDimension)
	if hitElement == localPlayer and matchingDimension then
		VehicleShopGUI:new(self.m_Name, self.m_ImagePath, self.m_Vehicles)
	end
end

function VehicleShop.createShops()
	VehicleShop:new("Coutt and Schutz", "files/images/CouttSchutz.png", Vector(2132, -1150.3, 23), {["Infernus"] = 10210, ["Banshee"] = 112300, ["Bullet"] = 100, ["Tampa"] = 10041, ["Super GT"] = 1010, ["Turismo"] = 100, ["Sabre"] = 11100, ["NRG-500"] = 97300, ["FCR-600"] = 10,
		["Alpha"] = 123123, ["Jester"] = 12312323, ["Uranus"] = 123123, ["ZR-350"] = 69999, ["Blade"] = 123123123})
end
