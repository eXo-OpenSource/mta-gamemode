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
  addEventHandler("onVehicleEnter", vehicle, bind( ELSSystem.onEnterVehicle, self))
end

function ELSSystem:destructor( )

end


function ELSSystem:onEnterVehicle( controller, seat)
    bindKey(controller, "z","up", bind( ELSSystem.setLightPeriod, self), 400)
		bindKey(controller, "z","down", bind( ELSSystem.setLightPeriod, self), 100)
		bindKey(controller, ",","up", bind( ELSSystem.setBlink, self), "left")
		bindKey(controller, ".","up", bind( ELSSystem.setBlink, self), "right")
		bindKey(controller, "-","up", bind( ELSSystem.setBlink, self), "off")
end

function ELSSystem:setLightPeriod( _, _, state, period)
  local yelp = false
  if state == "up" then
    self.m_LightSystem = not self.m_LightSystem
  else
      yelp = true
  end
  local syncer = getElementSyncer ( self.m_Vehicle )
  if syncer then
    syncer:triggerEvent("updateVehicleELS", self.m_Vehicle, self.m_LightSystem , period)
  end
end

function ELSSystem:setBlink( _,_, state, dir )
  local syncer = getElementSyncer ( self.m_Vehicle )
  if syncer then
    syncer:triggerEvent("updateVehicleBlink", self.m_Vehicle, self.m_Markers , dir)
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
