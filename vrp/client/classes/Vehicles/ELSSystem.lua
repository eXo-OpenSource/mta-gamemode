-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/ELSSystem.lua
-- *  PURPOSE:     Emergency Lightning System Client
-- *
-- *******************************************

ELSSystem = inherit( Singleton )
addRemoteEvents{ "updateVehicleELS" }

--CONSTANTS--
local R_COLOR_STATE_1 = {0,0,200}
local R_COLOR_STATE_2 = {200,0,0}
local R_COLOR_STATE_N = {255,255,255}

function ELSSystem:constructor( )
  	self.m_Vehicles = {  }
    addEventHandler( "updateVehicleELS", localPlayer, bind( ELSSystem.updateVehicleELS, self))
end

function ELSSystem:destructor( )

end

function ELSSystem:updateVehicleELS( vehicle, state, period)
  if state then
    if self.m_Vehicles[vehicle] then
      local isTimer = isTimer( self.m_Vehicles[vehicle][1] )
      if isTimer then
				killTimer( self.m_Vehicles[vehicle][1] )
			end
    end
      setVehicleOverrideLights( vehicle, 2)
		  setVehicleOverrideLights( vehicle, 2)
      self.m_Vehicles[vehicle] = {}
      self.m_Vehicles[vehicle][2] = 1
      self.m_Vehicles[vehicle][1] = setTimer( bind( ELSSystem.switchLights, self), period, 0, vehicle)
  else
      if self.m_Vehicles[vehicle] then
          local isTimer = isTimer( self.m_Vehicles[vehicle][1] )
          if isTimer then
            killTimer( self.m_Vehicles[vehicle][1] )
            local r,g,b = R_COLOR_STATE_N[1],R_COLOR_STATE_N[2],R_COLOR_STATE_N[3]
            if isElement( vehicle ) then
                setVehicleHeadLightColor ( vehicle, r, g, b)
					      setVehicleLightState ( vehicle, 0, 1)
					      setVehicleLightState ( vehicle, 1, 1)
            end
          end
      end
  end
end

function ELSSystem:switchLights( vehicle )
  local state = self.m_Vehicles[vehicle][2]
  local r,g,b
  if state == 1 or state == 4 then
    r,g,b = R_COLOR_STATE_1[1],R_COLOR_STATE_1[2],R_COLOR_STATE_1[3]
		setVehicleHeadLightColor ( vehicle, r,g,b)
		setVehicleLightState ( vehicle,0,1)
		setVehicleLightState ( vehicle,1,0)
    if state == 1 then
			setVehicleLightState ( vehicle,0,1)
			setVehicleLightState ( vehicle,1,0)
		else
			setVehicleLightState ( vehicle,0,0)
			setVehicleLightState ( vehicle,1,1)
		end
    self.m_Vehicles[vehicle][2] = self.m_Vehicles[vehicle][2] + 1
  elseif state == 2 or state == 5 then
    r,g,b = R_COLOR_STATE_2[1],R_COLOR_STATE_2[2],R_COLOR_STATE_2[3]
    setVehicleHeadLightColor ( vehicle, r, g, b)
    if i_state == 2 then
      setVehicleLightState ( vehicle, 0, 0)
      setVehicleLightState ( vehicle, 1, 1)
    else
      setVehicleLightState ( vehicle, 0, 1)
      setVehicleLightState ( vehicle, 1, 0)
    end
    self.m_Vehicles[vehicle][2] = self.m_Vehicles[vehicle][2] + 1
  elseif state == 3 or state == 6 then
    r,g,b = R_COLOR_STATE_N[1],R_COLOR_STATE_N[2],R_COLOR_STATE_N[3]
		setVehicleHeadLightColor ( vehicle, r,g,b)
		setVehicleLightState ( vehicle,0,0)
		setVehicleLightState ( vehicle,1,0)
    self.m_Vehicles[vehicle][2] = self.m_Vehicles[vehicle][2] + 1
    if self.m_Vehicles[vehicle][2] == 7 then self.m_Vehicles[vehicle][2] = 1 end
  end
end
