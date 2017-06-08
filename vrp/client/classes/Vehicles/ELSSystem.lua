-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/ELSSystem.lua
-- *  PURPOSE:     Emergency Lightning System Client
-- *
-- *******************************************

ELSSystem = inherit( Singleton )
addRemoteEvents{ "updateVehicleELS", "updateVehicleBlink", "onClientELSVehicleDestroy", "onVehicleYelp" }


function ELSSystem:constructor( )
  	self.m_Vehicles = {  }
    self.m_Vehicles_Blink = { }
    self.m_Enabled = core:get("Vehicles", "ELS", true)
    addEventHandler( "updateVehicleELS", localPlayer, bind( ELSSystem.updateVehicleELS, self))
    addEventHandler( "updateVehicleBlink", localPlayer, bind( ELSSystem.updateBlink, self))
    self.m_DestrucBind = function( vehicle ) self:onVehicleDestroy( vehicle ) end
    addEventHandler( "onClientELSVehicleDestroy", localPlayer, self.m_DestrucBind)
    addEventHandler( "onVehicleYelp", localPlayer, bind( ELSSystem.onVehicleYelp, self))
end

function ELSSystem:destructor( )

end

function ELSSystem:updateVehicleELS( vehicle, state, period)
  if state and self.m_Enabled then
    if self.m_Vehicles[vehicle] then
      if isTimer( self.m_Vehicles[vehicle][1] ) then
				killTimer( self.m_Vehicles[vehicle][1] )
			end
    end
      setVehicleOverrideLights( vehicle, 2)
      self.m_Vehicles[vehicle] = {}
      self.m_Vehicles[vehicle][2] = 1
      self.m_Vehicles[vehicle][1] = setTimer( bind( ELSSystem.switchLights, self), period, 0, vehicle)
  else
      if self.m_Vehicles[vehicle] then
          if  isTimer( self.m_Vehicles[vehicle][1] ) then
            killTimer( self.m_Vehicles[vehicle][1] )
          end
          if isElement( vehicle ) then
              setVehicleHeadLightColor ( vehicle, 255, 255, 255)
              setVehicleOverrideLights( vehicle, 2)
              setVehicleLightState ( vehicle,0,0)
              setVehicleLightState ( vehicle,1,0)
          end
      end
  end
end

function ELSSystem:onVehicleDestroy( vehicle )
    if self.m_Vehicles[vehicle] then
      if  isTimer( self.m_Vehicles[vehicle][1] ) then
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
  if not self.m_Enabled then return false end
  local state = self.m_Vehicles[vehicle][2]
  local r,g,b
  --blau  rot   weiß  rot   blau  weiß
  --1     2      3    4     5     6

  if state == 1 or state == 5 then --blue
		setVehicleHeadLightColor ( vehicle, 0, 0, 255)
		setVehicleLightState ( vehicle,0,1)
		setVehicleLightState ( vehicle,1,0)
  elseif state == 2 or state == 4 then -- red
    setVehicleHeadLightColor ( vehicle, 200, 0, 0)
    setVehicleLightState ( vehicle, 0, 0)
    setVehicleLightState ( vehicle, 1, 1)
  else --white
    setVehicleHeadLightColor (vehicle, 255, 255, 255)
		setVehicleLightState ( vehicle,0,0)
		setVehicleLightState ( vehicle,1,0)
  end
  self.m_Vehicles[vehicle][2] = self.m_Vehicles[vehicle][2] + 1
  if self.m_Vehicles[vehicle][2] == 7 then self.m_Vehicles[vehicle][2] = 1 end
end

function ELSSystem:updateBlink( vehicle , marker, state)
  if not self.m_Enabled then return false end
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
		self.m_Vehicles_Blink[vehicle] = { }
		self.m_Vehicles_Blink[vehicle][2] = 1
  		self.m_Vehicles_Blink[vehicle][3] = marker
  		self.m_Vehicles_Blink[vehicle][1] = setTimer( bind( ELSSystem.setBlinkAll, self),250,0,vehicle)
  		self.m_Vehicles_Blink[vehicle][4] = "blink"
  else
      if self.m_Vehicles_Blink[vehicle] then
        if isTimer( self.m_Vehicles_Blink[vehicle][1] )  then
          killTimer(  self.m_Vehicles_Blink[vehicle][1] )
        end
        if isElement( marker[1] ) and isElement(marker[2]) and isElement(marker[3] ) and isElement(marker[4] ) and isElement(marker[5] ) and isElement(marker[6] ) then
					setMarkerColor(marker[1],200,0,0,0)
					setMarkerColor(marker[2],200,0,0,0)
					setMarkerColor(marker[3],200,0,0,0)
					setMarkerColor(marker[4],150,0,0,0)
					setMarkerColor(marker[5],0,0,200,0)
					setMarkerColor(marker[6],0,0,200,0)
					self.m_Vehicles_Blink[vehicle][2] = 0
				end
      end
  end
end

function ELSSystem:setBlinkLeft( vehicle )
  if not self.m_Enabled then return false end
  local marker = self.m_Vehicles_Blink[vehicle][3]
  local state = self.m_Vehicles_Blink[vehicle][2]
  if state == 1 then
		setMarkerColor(marker[6] ,200,200,0.255)
		setMarkerColor(marker[5] ,200,200,0,255)
		setMarkerColor(marker[4] ,0,0,200,0)
		setMarkerColor(marker[3] ,0,0,200,0)
		setMarkerColor(marker[2] ,0,0,200,0)
		setMarkerColor(marker[1] ,0,0,200,0)
    self.m_Vehicles_Blink[vehicle][2] = 2
  elseif state == 2 then
		setMarkerColor(marker[6] ,200,0,0,0)
		setMarkerColor(marker[5] ,200,0,0,0)
		setMarkerColor(marker[4] ,200,200,0,255)
		setMarkerColor(marker[3] ,200,200,0,255)
		setMarkerColor(marker[2] ,0,0,200,0)
		setMarkerColor(marker[1] ,200,200,0,0)
    self.m_Vehicles_Blink[vehicle][2] = 3
  elseif state == 3 then
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
  if not self.m_Enabled then return false end
  local marker = self.m_Vehicles_Blink[vehicle][3]
  local state = self.m_Vehicles_Blink[vehicle][2]
  if state == 1 then
		setMarkerColor(marker[6] ,200,0,0,0)
		setMarkerColor(marker[5] ,200,0,0,0)
		setMarkerColor(marker[4] ,200,0,0,0)
		setMarkerColor(marker[3] ,200,200,0,0)
		setMarkerColor(marker[2] ,200,200,0,255)
		setMarkerColor(marker[1] ,200,200,0,255)
    self.m_Vehicles_Blink[vehicle][2] = 2
  elseif state == 2 then
    setMarkerColor(marker[6] ,200,0,0,0)
    setMarkerColor(marker[5] ,200,0,0,0)
    setMarkerColor(marker[4] ,200,200,0,255)
    setMarkerColor(marker[3] ,200,200,0,255)
    setMarkerColor(marker[2] ,0,0,200,0)
    setMarkerColor(marker[1] ,200,200,0,0)
    self.m_Vehicles_Blink[vehicle][2] = 3
  elseif state == 3 then
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
  if not self.m_Enabled then return false end
  local marker = self.m_Vehicles_Blink[vehicle][3]
  local state = self.m_Vehicles_Blink[vehicle][2]
  if state == 1 then
		setMarkerColor(marker[1] ,255,0,0,255)
		setMarkerColor(marker[2] ,255,0,0,255)
		setMarkerColor(marker[3] ,255,0,0,255)
		setMarkerColor(marker[4] ,0,0,255,0)
		setMarkerColor(marker[5] ,0,0,255,0)
		setMarkerColor(marker[6] ,0,0,255,0)
    self.m_Vehicles_Blink[vehicle][2] = 2
  elseif state == 2 then
		setMarkerColor(marker[1] ,255,0,0,0)
		setMarkerColor(marker[2] ,255,0,0,0)
		setMarkerColor(marker[3] ,255,0,0,0)
		setMarkerColor(marker[4] ,0,0,255,255)
		setMarkerColor(marker[5] ,0,0,255,255)
		setMarkerColor(marker[6] ,0,0,255,255)
    self.m_Vehicles_Blink[vehicle][2] = 3
   elseif state == 3 then
    setMarkerColor(marker[1] ,255,0,0,255)
		setMarkerColor(marker[2] ,255,0,0,0)
		setMarkerColor(marker[3] ,255,0,0,255)
		setMarkerColor(marker[4] ,0,0,255,0)
		setMarkerColor(marker[5] ,0,0,255,255)
		setMarkerColor(marker[6] ,0,0,255,0)
    self.m_Vehicles_Blink[vehicle][2] = 4
  elseif state == 4 then
		setMarkerColor(marker[1] ,255,0,0,0)
		setMarkerColor(marker[2] ,255,0,0,255)
		setMarkerColor(marker[3] ,255,0,0,0)
		setMarkerColor(marker[4] ,0,0,255,255)
		setMarkerColor(marker[5] ,0,0,255,0)
		setMarkerColor(marker[6] ,0,0,255,255)
    self.m_Vehicles_Blink[vehicle][2] = 1
  end
end


function ELSSystem:toggle(state)
  if state ~= self.m_Enabled then
    if not state then
      for veh, data in pairs(self.m_Vehicles) do
        if isTimer(data[1]) then killTimer(data[1]) end
        setVehicleHeadLightColor(veh, 255, 255, 255)
        setVehicleLightState(veh, 0, 0)
        setVehicleLightState(veh, 1, 0)
      end
      for veh, data in pairs(self.m_Vehicles_Blink) do
        if isTimer(data[1]) then killTimer(data[1]) end
        if data[3] then
          for i, marker in pairs(data[3]) do
            setMarkerColor(marker, 0, 0, 0, 0)
          end
        end
      end
    end
    self.m_Enabled = not self.m_Enabled
  end
end