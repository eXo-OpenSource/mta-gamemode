-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        client/classes/Business/VehicleImportManager.lua
-- *  PURPOSE:     manager for vehicle importing missions (delivery to vehicle shops) 
-- *
-- ****************************************************************************

addRemoteEvents {"createVehicleTransportDestinationBlips", "destroyVehicleTransportDestinationBlips"}

VehicleImportManager = inherit(Singleton)

function VehicleImportManager:constructor()
	self.m_CreateBlipsFunc = bind(self.createBlips, self)
	self.m_DestroyBlipsFunc = bind(self.destroyBlips, self)

	addEventHandler("createVehicleTransportDestinationBlips", localPlayer, self.m_CreateBlipsFunc)
	addEventHandler("destroyVehicleTransportDestinationBlips", localPlayer, self.m_DestroyBlipsFunc)
	self.m_BlipsVisible = false
	self.m_Blips = {}
end




function VehicleImportManager:createBlips(vehicles)
	if self.m_BlipsVisible then self:destroyBlips() end -- destroy old blips
	for vehicle, destinationPos in pairs(vehicles) do
		local x, y, z = unpack(destinationPos)
		local r, g, b = vehicle:getColor(true)
		local h, s, v = Color.rgbToHsv(r, g, b)
		v = math.min(v+0.5, 1) -- brighten up color to make it more visible on the map
		local blip = Blip:new("Marker.png", x, y, 9999, {Color.hsvToRgb(h, s, v)})
		blip:setZ(tonumber(z))
		blip:setDisplayText("Abgabepunkt "..vehicle:getName())
		self.m_Blips[vehicle] = blip
	end
	self.m_BlipsVisible = true
end

function VehicleImportManager:destroyBlips()
	if not self.m_BlipsVisible then return end
	for vehicle, blip in pairs(self.m_Blips) do
		blip:delete()
	end
	self.m_Blips = {}
	self.m_BlipsVisible = false
end