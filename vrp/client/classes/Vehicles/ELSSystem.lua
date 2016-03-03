-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/ELSSystem.lua
-- *  PURPOSE:     Emergency Lightning System Client
-- *
-- *******************************************

ELSSystem = inherit( Singleton )
addRemoteEvents{ "updateVehicleELS", "updateVehicleBlink", "onClientELSVehicleDestroy", "onVehicleYelp" }

--CONSTANTS--
local R_COLOR_STATE_1 = {0,0,200}
local R_COLOR_STATE_2 = {200,0,0}
local R_COLOR_STATE_N = {255,255,255}

function ELSSystem:constructor( )
  	self.m_Vehicles = {  }
    self.m_Vehicles_Blink = { }
    addEventHandler( "updateVehicleELS", localPlayer, bind( ELSSystem.updateVehicleELS, self))
    addEventHandler( "updateVehicleBlink", localPlayer, bind( ELSSystem.updateBlink, self))
    self.m_DestrucBind = function( vehicle ) self:onVehicleDestroy( vehicle ) end
    addEventHandler( "onClientELSVehicleDestroy", localPlayer, self.m_DestrucBind)
    addEventHandler( "onVehicleYelp", localPlayer, bind( ELSSystem.onVehicleYelp, self))
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
      self.m_Vehicles[vehicle] = {}
      self.m_Vehicles[vehicle][2] = 1
      self.m_Vehicles[vehicle][1] = setTimer( bind( ELSSystem.switchLights, self), period, 0, vehicle)
  else
      if self.m_Vehicles[vehicle] then
          local isTimer = isTimer( self.m_Vehicles[vehicle][1] )
          if isTimer then
            killTimer( self.m_Vehicles[vehicle][1] )
          end
          local r,g,b = R_COLOR_STATE_N[1],R_COLOR_STATE_N[2],R_COLOR_STATE_N[3]
          if isElement( vehicle ) then
              setVehicleHeadLightColor ( vehicle, r, g, b)
              setVehicleOverrideLights( vehicle, 2)
              setVehicleLightState ( vehicle,0,0)
              setVehicleLightState ( vehicle,1,0)
          end
      end
  end
end

function ELSSystem:onVehicleDestroy( vehicle )
    if self.m_Vehicles[vehicle] then
      local isTimer = isTimer( self.m_Vehicles[vehicle][1] )
      if isTimer then
        killTimer( self.m_Vehicles[vehicle][1] )
      end
    end
    if self.m_Vehicles_Blink[vehicle] then
      if isTimer( self.m_Vehicles_Blink[vehicle][1] )  then
        killTimer(  self.m_Vehicles_Blink[vehicle][1] )
      end
    end
end

function ELSSystem:onVehicleYelp( vehicle )
  if self.m_YelpSound then
    if isElement( self.m_YelpSound ) then
      stopSound( self.m_YelpSound )
      self.m_YelpSound = nil
    end
  end
  local x, y, z = getElementPosition( vehicle )
  self.m_YelpSound  = playSound3D( "files/audio/yelp.ogg",x,y,z)
  setSoundMaxDistance ( self.m_YelpSound , 30)
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

function ELSSystem:updateBlink( vehicle , marker, state)
  if state == "right" then
      if self.m_Vehicles_Blink[vehicle] then
        if isTimer( self.m_Vehicles_Blink[vehicle][1] )  then
          killTimer(  self.m_Vehicles_Blink[vehicle][1] )
        end
      end
      self.m_Vehicles_Blink[vehicle] = { }
      self.m_Vehicles_Blink[vehicle][2] = 1
      self.m_Vehicles_Blink[vehicle][3] = marker
      self.m_Vehicles_Blink[vehicle][1] = setTimer( bind( ELSSystem.setBlinkRight, self),250,0,vehicle)
      self.m_Vehicles_Blink[vehicle][4] = "right"
  elseif state == "left" then
      if self.m_Vehicles_Blink[vehicle] then
        if isTimer( self.m_Vehicles_Blink[vehicle][1] )  then
          killTimer(   self.m_Vehicles_Blink[vehicle][1] )
        end
      end
      self.m_Vehicles_Blink[vehicle] = { }
      self.m_Vehicles_Blink[vehicle][2] = 3
      self.m_Vehicles_Blink[vehicle][3] = marker
      self.m_Vehicles_Blink[vehicle][1] = setTimer( bind( ELSSystem.setBlinkLeft, self),250,0,vehicle)
      self.m_Vehicles_Blink[vehicle][4] = "left"
  elseif state == "blink" then
      if self.m_Vehicles_Blink[vehicle] then
        if isTimer( self.m_Vehicles_Blink[vehicle][1] )  then
          killTimer(   self.m_Vehicles_Blink[vehicle][1] )
        end
      end
      self.m_Vehicles_Blink[vehicle][2] = 3
  		self.m_Vehicles_Blink[vehicle][3] = marker
  		self.m_Vehicles_Blink[vehicle][1] = setTimer( bind( ELSSystem.setBlinkAll, self),100,0,vehicle)
  		self.m_Vehicles_Blink[vehicle][4] = "blink"
  else
      if self.m_Vehicles_Blink[vehicle] then
        if isTimer( self.m_Vehicles_Blink[vehicle][1] )  then
          killTimer(  self.m_Vehicles_Blink[vehicle][1] )
        end
        if isElement( marker[1] ) and isElement(marker[2]) and isElement(marker[3] ) and isElement(marker[4] ) and isElement(marker[5] ) and isElement(marker[6] ) then
					setMarkerColor(marker[1],200,200,0,0)
					setMarkerColor(marker[2],200,200,0,0)
					setMarkerColor(marker[3],200,200,0,0)
					setMarkerColor(marker[4],200,200,0,0)
					setMarkerColor(marker[5],200,200,0,0)
					setMarkerColor(marker[6],200,200,0,0)
					setMarkerColor(marker[7],200,200,0,0)
					setMarkerColor(marker[8],200,200,0,0)
					self.m_Vehicles_Blink[vehicle][2] = 0
				end
      end
  end
end

function ELSSystem:setBlinkLeft( vehicle )
  local marker = self.m_Vehicles_Blink[vehicle][3]
  local state = self.m_Vehicles_Blink[vehicle][2]
  if state == 1 then
    setMarkerColor(marker[7] ,200,200,0,255)
		setMarkerColor(marker[8] ,200,200,0,0)
		setMarkerColor(marker[6] ,200,200,0,255)
		setMarkerColor(marker[5] ,200,200,0,255)
		setMarkerColor(marker[4] ,200,0,0,0)
		setMarkerColor(marker[3] ,200,0,0,0)
		setMarkerColor(marker[2] ,200,200,0,0)
		setMarkerColor(marker[1] ,200,200,0,0)
    self.m_Vehicles_Blink[vehicle][2] = 2
  elseif state == 2 then
    setMarkerColor(marker[7] ,200,200,0,0)
		setMarkerColor(marker[8] ,200,200,0,0)
		setMarkerColor(marker[6] ,200,200,0,0)
		setMarkerColor(marker[5] ,200,200,0,0)
		setMarkerColor(marker[4] ,200,200,0,255)
		setMarkerColor(marker[3] ,200,200,0,255)
		setMarkerColor(marker[2] ,0,0,200,0)
		setMarkerColor(marker[1] ,200,200,0,0)
    self.m_Vehicles_Blink[vehicle][2] = 3
  elseif state == 3 then
    setMarkerColor(marker[7] ,200,200,0,255)
    setMarkerColor(marker[8] ,200,200,0,0)
    setMarkerColor(marker[6] ,200,200,0,0)
    setMarkerColor(marker[5] ,200,200,0,0)
    setMarkerColor(marker[4] ,200,200,0,0)
    setMarkerColor(marker[3] ,200,200,0,0)
    setMarkerColor(marker[2] ,200,200,0,255)
    setMarkerColor(marker[1] ,200,200,0,255)
    self.m_Vehicles_Blink[vehicle][2] = 1
  end
end

function ELSSystem:setBlinkRight( vehicle )
  local marker = self.m_Vehicles_Blink[vehicle][3]
  local state = self.m_Vehicles_Blink[vehicle][2]
  if state == 1 then
    setMarkerColor(marker[7] ,200,200,0,0)
		setMarkerColor(marker[8] ,200,200,0,255)
		setMarkerColor(marker[6] ,200,0,0,0)
		setMarkerColor(marker[5] ,200,0,0,0)
		setMarkerColor(marker[4] ,200,0,0,0)
		setMarkerColor(marker[3] ,200,200,0,0)
		setMarkerColor(marker[2] ,200,200,0,255)
		setMarkerColor(marker[1] ,200,200,0,255)
    self.m_Vehicles_Blink[vehicle][2] = 2
  elseif state == 2 then
    setMarkerColor(marker[7] ,200,200,0,0)
    setMarkerColor(marker[8] ,200,200,0,0)
    setMarkerColor(marker[6] ,200,0,0,0)
    setMarkerColor(marker[5] ,200,0,0,0)
    setMarkerColor(marker[4] ,200,200,0,255)
    setMarkerColor(marker[3] ,200,200,0,255)
    setMarkerColor(marker[2] ,0,0,200,0)
    setMarkerColor(marker[1] ,200,200,0,0)
    self.m_Vehicles_Blink[vehicle][2] = 3
  elseif state == 3 then
    setMarkerColor(marker[7] ,200,200,0,0)
  	setMarkerColor(marker[8] ,200,200,0,255)
  	setMarkerColor(marker[6] ,200,200,0,255)
  	setMarkerColor(marker[5] ,200,200,0,255)
  	setMarkerColor(marker[4] ,200,0,0,0)
  	setMarkerColor(marker[3] ,200,0,0,0)
  	setMarkerColor(marker[2] ,200,200,0,0)
  	setMarkerColor(marker[1] ,200,200,0,0)
    self.m_Vehicles_Blink[vehicle][2] = 1
  end
end

function ELSSystem:setBlinkAll( vehicle )
  local marker = self.m_Vehicles_Blink[vehicle][3]
  local state = self.m_Vehicles_Blink[vehicle][2]
  if state == 1 then
    setMarkerColor(marker[7] ,200,200,0,0)
		setMarkerColor(marker[8] ,200,200,0,0)
		setMarkerColor(marker[6] ,200,0,0,255)
		setMarkerColor(marker[5] ,200,0,0,255)
		setMarkerColor(marker[4] ,200,0,0,0)
		setMarkerColor(marker[3] ,200,0,0,0)
		setMarkerColor(marker[2] ,200,200,0,0)
		setMarkerColor(marker[1] ,200,200,0,0)
    self.m_Vehicles_Blink[vehicle][2] = 2
  elseif state == 2 then
    setMarkerColor(marker[7] ,200,200,0,0)
		setMarkerColor(marker[8] ,200,200,0,0)
		setMarkerColor(marker[6] ,200,200,0,0)
		setMarkerColor(marker[5] ,200,200,0,0)
		setMarkerColor(marker[4] ,0,0,200,255)
		setMarkerColor(marker[3] ,0,0,200,255)
		setMarkerColor(marker[2] ,0,0,200,0)
		setMarkerColor(marker[1] ,200,200,0,0)
    self.m_Vehicles_Blink[vehicle][2] = 3
  elseif state == 3 then
    setMarkerColor(marker[7] ,200,200,0,0)
    setMarkerColor(marker[8] ,200,200,0,0)
  	setMarkerColor(marker[6] ,200,200,0,0)
		setMarkerColor(marker[5] ,200,200,0,0)
  	setMarkerColor(marker[4] ,200,200,0,0)
  	setMarkerColor(marker[3] ,200,200,0,0)
  	setMarkerColor(marker[2] ,200,0,0,255)
  	setMarkerColor(marker[1] ,200,0,0,255)
    self.m_Vehicles_Blink[vehicle][2] = 1
  end
end
