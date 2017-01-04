-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/ELSSystem.lua
-- *  PURPOSE:     Emergency Lightning System
-- *
-- ****************************************************************************

ELSSystem = inherit( Object )

local CustomSirens =
{
	[560] = {0.7,0.2},
	[426] = {0.6,0.2},
	[420] = {0.6,0.2},
}

function ELSSystem:constructor( vehicle , type )
  self.m_Vehicle = vehicle
  self:createBlinkMarkers( )
  self.m_LightSystem = false
  local model = getElementModel(vehicle)
  if CustomSirens[model] then
	addVehicleSirens(vehicle,2,3,true)
	setVehicleSirens ( vehicle, 1, 0-CustomSirens[model][2]/2, 0.000, CustomSirens[model][1], 255,0, 0, 255, 255 )
	setVehicleSirens ( vehicle, 2, 0+CustomSirens[model][2]/2, 0.000, CustomSirens[model][1], 0,0, 255, 255, 255 )
  end
  addEventHandler("onVehicleEnter", vehicle, bind( ELSSystem.onEnterVehicle, self))
  addEventHandler("onVehicleExit", vehicle, bind( ELSSystem.onLeaveVehicle, self))
end

function ELSSystem:destructor( )
  local controller = getVehicleOccupant ( self.m_Vehicle )
  unbindKey(controller, "z","up",  self.m_BindLight , 400)
  unbindKey(controller, "z","down", self.m_BindLight, 100)
  unbindKey(controller, ",","up", self.m_BindBlink, "left")
  unbindKey(controller, ".","up", self.m_BindBlink, "right")
  unbindKey(controller, "-","up", self.m_BindBlink, "off")
  for i = 1,8 do
    if self.m_Markers[i] then
      destroyElement( self.m_Markers[i] )
    end
  end
  local all = getElementsByType( "player" )
  for key, player in ipairs( all ) do
    player:triggerEvent( "onClientELSVehicleDestroy", self.m_Vehicle )
  end
end

function ELSSystem:onLeaveVehicle( controller, seat )
	if not controller:getType() == "player" then return end

	if seat == 0 then
		unbindKey(controller, "z","up",  self.m_BindLight , 400)
		unbindKey(controller, "z","down", self.m_BindLight, 100)
		unbindKey(controller, ",","up", self.m_BindBlink, "left")
		unbindKey(controller, ".","up", self.m_BindBlink, "right")
		unbindKey(controller, "-","up", self.m_BindBlink, "off")
	end
end

function ELSSystem:onEnterVehicle( controller, seat)
	if not controller:getType() == "player" then return end

	local type_ = getVehicleType(getPedOccupiedVehicle(controller))
	if type_ ~= VehicleType.Boat and type_ ~= VehicleType.Helicopter and type_ ~= VehicleType.Plane then
		self.m_BindLight = bind(self.setLightPeriod, self)
		bindKey(controller, "z","up",  self.m_BindLight , 400)
		bindKey(controller, "z","down", self.m_BindLight, 100)
		self.m_BindBlink = bind(self.setBlinkBind, self)
		bindKey(controller, ",","up", self.m_BindBlink, "left")
		bindKey(controller, ".","up", self.m_BindBlink, "right")
		bindKey(controller, "horn","up", self.m_BindBlink, "blink")
		bindKey(controller, "-","up", self.m_BindBlink, "off")
	end
end

function ELSSystem:setLightPeriod( _, _, state, period)
  	local yelp = false
	if state == "up" then
		self.m_LightSystem = not self.m_LightSystem
	else
		yelp = true
	end

  	triggerClientEvent(root, "updateVehicleELS", root, self.m_Vehicle, self.m_LightSystem , period)

  	if yelp then
		triggerClientEvent(root, "onVehicleYelp", root, self.m_Vehicle )
	end
end

function ELSSystem:setBlinkBind(_, _, _, dir )
   	self:setBlink(dir)
end

function ELSSystem:setBlink(dir)
    triggerClientEvent(root, "updateVehicleBlink", root, self.m_Vehicle, self.m_Markers , dir)
end

function ELSSystem:createBlinkMarkers( )
  self.m_Markers = {  }
  local x,y,z = getElementPosition( self.m_Vehicle )
  local oy = - 2
  local oz = 0.4
  local i_mod  = getElementModel( self.m_Vehicle )
  if i_mod == 490 then oy = -3  end
  if i_mod == 599 then oy = -2.7 end
  if i_mod == 427 then oy = -3.87;oz = 1.5 end
  for i = 1,6 do
    self.m_Markers[i] = createMarker(x, y, z,"corona",0.2, 200, 0, 0, 0)
    attachElements(self.m_Markers[i],self.m_Vehicle, -1+(i*0.3), oy, oz)
  end
  self.m_Markers[7] = createMarker(x,y,z,"corona",0.1,200, 0, 0, 0)
  attachElements(self.m_Markers[7],self.m_Vehicle, -1+0.1, oy, oz)

  self.m_Markers[8] = createMarker(x, y, z,"corona", 0.1, 200, 0, 0, 0)
  attachElements(self.m_Markers[8],self.m_Vehicle, -1+(6*0.3), oy, oz)
end
