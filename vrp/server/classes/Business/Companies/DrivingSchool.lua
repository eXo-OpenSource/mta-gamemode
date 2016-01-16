DrivingSchool = inherit(Company)

function DrivingSchool:constructor()
  outputDebug(("[%s] Extra-class successfully loaded! (Id: %d)"):format(self:getName(), self:getId()))

  -- Normal Car
  for i = 1, 4, 1 do -- 426
    AutomaticVehicleSpawner:new(551, 1197.302 + (i-1)*4, -1828.698, 13.13, 0, 0, 180, bind(self.onVehicleSpawn, self), nil, function (...) return self:onVehiceEnter(...) end)
  end

  -- Motorcycle
  for i = 1, 4, 1 do
    AutomaticVehicleSpawner:new(521, 1213.302 + (i-1)*2, -1828.698, 13.13, 0, 0, 180, bind(self.onVehicleSpawn, self), nil, function (...) return self:onVehiceEnter(...) end)
  end

  -- Helicopter
  for i = 1, 2, 1 do
    AutomaticVehicleSpawner:new(487, 1909.57 + (i-1)*12, -2244.180, 13.8, 0, 0, 180, bind(self.onVehicleSpawn, self), nil, function (...) return self:onVehiceEnter(...) end)
  end

  -- Plane
  AutomaticVehicleSpawner:new(593, 1933.5, -2244.180, 14.1, 0, 0, 180, bind(self.onVehicleSpawn, self), nil, function (...) return self:onVehiceEnter(...) end)
  AutomaticVehicleSpawner:new(489, 1895.3, -2244.35, 13.6, 0, 0, 180, bind(self.onVehicleSpawn, self), nil, function (...) return self:onVehiceEnter(...) end)
end

function DrivingSchool:destructor()
end

function DrivingSchool:onVehicleSpawn(veh)
  -- Adjust Color and Owner Text
  veh:setData("OwnerName", self:getName(), true)
  veh:setColor(255, 255, 255)

  -- Adjust variant
  if veh:getModel() == 521 then
    veh:setVariant(4, 4)
  end
end

function DrivingSchool:onVehiceEnter(player)
  if player:getCompany() ~= self then
    player:sendError(_("Du darfst dieses Fahrzeug nicht fahren!", player))
    return false
  end

  return true
end
