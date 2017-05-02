-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/ELSSystem.lua
-- *  PURPOSE:     Emergency Lightning System
-- *
-- ****************************************************************************

ELSSystem = inherit( Object )
ELSSystem.CustomSirens ={
	[560] = {0.7,0.2},
	[426] = {0.6,0.2},
	[420] = {0.6,0.2},
}
ELSSystem.BlinkMarkers ={
	[490] = {["y"] = -3 },
	[599] = {["y"] = -2.6},
	[427] = {["y"] = -3.87, ["z"] = 1.5},
	[560] = {["y"] = -1.5, ["z"] = 0.42},
	[598] = {["y"] = -1.5, ["z"] = 0.4},
	[601] = {["y"] = -2.2, ["z"] = 1.1},
	[528] = {["y"] = -2.2, ["z"] = 1.1},
	[416] = {["y"] = -3.6, ["z"] = 1.7},
	[544] = {["y"] = -3.6, ["z"] = 1.5},
	[407] = {["y"] = -3.5, ["z"] = 1.5},
}

function ELSSystem:constructor(vehicle)
	self.m_Vehicle = vehicle
	self.m_LightSystem = false

	self.m_BindLight = bind(self.setLightPeriod, self)
	self.m_BindBlink = bind(self.setBlinkBind, self)

	self:createBlinkMarkers( )

	local model = vehicle.model
	if ELSSystem.CustomSirens[model] then
		addVehicleSirens(vehicle, 2, 3, true)
		setVehicleSirens(vehicle, 1, 0 - ELSSystem.CustomSirens[model][2]/2, 0.000, ELSSystem.CustomSirens[model][1], 255, 0, 0, 255, 255)
		setVehicleSirens(vehicle, 2, 0 + ELSSystem.CustomSirens[model][2]/2, 0.000, ELSSystem.CustomSirens[model][1], 0, 0, 255, 255, 255)
	end
	addEventHandler("onVehicleEnter", vehicle, bind(self.onEnterVehicle, self))
	addEventHandler("onVehicleExit", vehicle, bind(self.onLeaveVehicle, self))
end

function ELSSystem:destructor( )
	local player = self.m_Vehicle:getOccupant(0)
	if player then
		unbindKey(player, "z","up",  self.m_BindLight , 400)
		unbindKey(player, "z","down", self.m_BindLight, 100)
		unbindKey(player, ",","up", self.m_BindBlink, "left")
		unbindKey(player, ".","up", self.m_BindBlink, "right")
		unbindKey(player, "horn","up", self.m_BindBlink, "blink")
		unbindKey(player, "-","up", self.m_BindBlink, "off")
	end
	for i = 1,8 do
		if self.m_Markers[i] then
			destroyElement( self.m_Markers[i] )
		end
	end

	local all = getElementsByType( "player" )
	for key, player in ipairs( all ) do
		player:triggerEvent( "onClientELSVehicleDestroy", self.m_Vehicle )
		unbindKey(player, "z","up",  self.m_BindLight , 400)
		unbindKey(player, "z","down", self.m_BindLight, 100)
		unbindKey(player, ",","up", self.m_BindBlink, "left")
		unbindKey(player, ".","up", self.m_BindBlink, "right")
		unbindKey(player, "horn","up", self.m_BindBlink, "blink")
		unbindKey(player, "-","up", self.m_BindBlink, "off")
	end
end

function ELSSystem:onLeaveVehicle(player, seat)
	if not player:getType() == "player" then return end
	if seat == 0 then
		unbindKey(player, "z","up",  self.m_BindLight , 400)
		unbindKey(player, "z","down", self.m_BindLight, 100)
		unbindKey(player, ",","up", self.m_BindBlink, "left")
		unbindKey(player, ".","up", self.m_BindBlink, "right")
		unbindKey(player, "horn","up", self.m_BindBlink, "blink")
		unbindKey(player, "-","up", self.m_BindBlink, "off")
	end
end

function ELSSystem:onEnterVehicle(player, seat)
	if seat == 0 then
		if not player:getType() == "player" then return end

		local vehType = getVehicleType(source)
		if vehType ~= VehicleType.Boat and vehType ~= VehicleType.Helicopter and vehType ~= VehicleType.Plane then
			bindKey(player, "z","up",  self.m_BindLight , 400)
			bindKey(player, "z","down", self.m_BindLight, 100)
			bindKey(player, ",","up", self.m_BindBlink, "left")
			bindKey(player, ".","up", self.m_BindBlink, "right")
			bindKey(player, "horn","up", self.m_BindBlink, "blink")
			bindKey(player, "-","up", self.m_BindBlink, "off")
		end
	end
end

function ELSSystem:setLightPeriod(press, key, state, period)
	if getVehicleOccupant(self.m_Vehicle) == press then
		if state == "up" then self.m_LightSystem = not self.m_LightSystem end

		triggerClientEvent(root, "updateVehicleELS", root, self.m_Vehicle, self.m_LightSystem , period)

		if state == "down" then
			triggerClientEvent(root, "onVehicleYelp", root, self.m_Vehicle)
		end
	end
end

function ELSSystem:setBlinkBind(press, key, _, dir)
   	if getVehicleOccupant(self.m_Vehicle) == press then
		self:setBlink(dir)
	end
end

function ELSSystem:setBlink(dir)
    triggerClientEvent(root, "updateVehicleBlink", root, self.m_Vehicle, self.m_Markers, dir)
end

function ELSSystem:createBlinkMarkers( )
	self.m_Markers = {  }
	local pos = self.m_Vehicle:getPosition()
	local model  = self.m_Vehicle:getModel()

	local offsetY, offsetZ = -2, 0.42

	if ELSSystem.BlinkMarkers[model] then
		if ELSSystem.BlinkMarkers[model].y then offsetY = ELSSystem.BlinkMarkers[model].y end
		if ELSSystem.BlinkMarkers[model].z then offsetZ = ELSSystem.BlinkMarkers[model].z end
	end

	for i = 1,6 do
		self.m_Markers[i] = createMarker(pos, "corona", 0.14, 200, 0, 0, 0)
		self.m_Markers[i]:attach(self.m_Vehicle, -1+(i*0.3), offsetY, offsetZ)
	end

	self.m_Markers[7] = createMarker(pos, "corona", 0.1, 200, 0, 0, 0)
	self.m_Markers[7]:attach(self.m_Vehicle, -1+0.1, offsetY, offsetZ)

	self.m_Markers[8] = createMarker(pos, "corona", 0.1, 200, 0, 0, 0)
	self.m_Markers[8]:attach(self.m_Vehicle, -1+(6*0.3), offsetY, offsetZ)
end
