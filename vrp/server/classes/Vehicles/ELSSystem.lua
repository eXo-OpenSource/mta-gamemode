-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/ELSSystem.lua
-- *  PURPOSE:     Emergency Lightning System
-- *
-- ****************************************************************************

ELSSystem = inherit( Object )

function ELSSystem:constructor( vehicle , type )
  self.m_Vehicle = vehicle
  self:createBlinkMarkers( )
  self.m_LightSystem = false
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
  if seat == 0 then
    unbindKey(controller, "z","up",  self.m_BindLight , 400)
    unbindKey(controller, "z","down", self.m_BindLight, 100)
    unbindKey(controller, ",","up", self.m_BindBlink, "left")
		unbindKey(controller, ".","up", self.m_BindBlink, "right")
		unbindKey(controller, "-","up", self.m_BindBlink, "off")
  end
end

function ELSSystem:onEnterVehicle( controller, seat)
	local type_ = getVehicleType(getPedOccupiedVehicle(controller))
	if type_ ~= VehicleType.Boat and type_ ~= VehicleType.Helicopter and type_ ~= VehicleType.Plane then
		self.m_BindLight = bind( ELSSystem.setLightPeriod, self)
		bindKey(controller, "z","up",  self.m_BindLight , 400)
		bindKey(controller, "z","down", self.m_BindLight, 100)
		self.m_BindBlink = bind( ELSSystem.setBlink, self)
		bindKey(controller, ",","up", self.m_BindBlink, "left")
		bindKey(controller, ".","up", self.m_BindBlink, "right")
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
  local all = getElementsByType( "player" )
  for key, player in ipairs( all ) do
    player:triggerEvent("updateVehicleELS", self.m_Vehicle, self.m_LightSystem , period)
  end
  if yelp then

    for key, player in ipairs( all ) do
      player:triggerEvent( "onVehicleYelp", self.m_Vehicle )
    end
  end
end

function ELSSystem:setBlink( _,_, state, dir )
  local all = getElementsByType( "player" )
  for key, player in ipairs( all ) do
    player:triggerEvent("updateVehicleBlink", self.m_Vehicle, self.m_Markers , dir)
  end
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
  attachElements(self.m_Markers[7],self.m_Vehicle, -1+0.3, oy, oz)

  self.m_Markers[8] = createMarker(x, y, z,"corona", 0.1, 200, 0, 0, 0)
  attachElements(self.m_Markers[8],self.m_Vehicle, -1+(6*0.3), oy, oz)
end
