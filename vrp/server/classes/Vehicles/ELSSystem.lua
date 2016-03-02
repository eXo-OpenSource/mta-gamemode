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
  addEventHandler("onVehicleEnter", vehicle, bind( ELSSystem.onEnterVehicle, self))
end

function ELSSystem:destructor( )

end


function ELSSystem:onEnterVehicle( controller, seat)
    bindKey(controller, "z","up",bind( ELSSystem.setLightPeriod, self), 400)
		bindKey(controller, "z","down",bind( ELSSystem.setLightPeriod, self), 100)
		--bindKey(controller, ",","up",VLC.setBlink,source,"left")
		--bindKey(controller, ".","up",VLC.setBlink,source,"right")
		--bindKey(controller, "-","up",VLC.setBlink,source,"off")
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
