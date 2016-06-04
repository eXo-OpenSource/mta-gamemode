Neon = {}

function Neon.initalize()
    Neon.Image = dxCreateTexture("files/images/Other/Neon.png")
    Neon.Vehicles = {}
    Neon.getNeonTable()
    addEventHandler("onClientElementStreamIn",getRootElement(),Neon.VehiclestreamedIn)
    addEventHandler("onClientElementStreamOut",getRootElement(),Neon.VehiclestreamedOut)
    addEventHandler("onClientPreRender", getRootElement(), Neon.Render)
end

function Neon.getPositionFromElementAtOffset(element, x, y, z)
  if not x or not y or not z then
    return x, y, z
  end
  local matrix = getElementMatrix(element)
  local offX = x * matrix[1][1] + y * matrix[2][1] + z * matrix[3][1] + matrix[4][1]
  local offY = x * matrix[1][2] + y * matrix[2][2] + z * matrix[3][2] + matrix[4][2]
  local offZ = x * matrix[1][3] + y * matrix[2][3] + z * matrix[3][3] + matrix[4][3]
  return Vector3(offX, offY, offZ)
end

function Neon.findRotation (x,y,rz,dist,rot)
    local x = x+dist*math.cos(math.rad(rz+rot))
    local y = y+dist*math.sin(math.rad(rz+rot))

    return x,y
end

function Neon.getVehicleWheelPositions(vehicle)
	local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(vehicle)
	if minX and minY and minZ and maxX and maxY and maxZ then
		local wheel1 = Neon.getPositionFromElementAtOffset(vehicle, minX, maxY, minZ)
		local wheel2 = Neon.getPositionFromElementAtOffset(vehicle, minX, -maxY, minZ)
		local wheel3 = Neon.getPositionFromElementAtOffset(vehicle, maxX, maxY, minZ)
		local wheel4 = Neon.getPositionFromElementAtOffset(vehicle, maxX, -maxY, minZ)
		return wheel1, wheel2, wheel3, wheel4
	end
	return Vector3(0, 0, 0, 0), Vector3(0, 0, 0, 0), Vector3(0, 0, 0, 0), Vector3(0, 0, 0, 0)
end

function Neon.getNeonTable()
	for index, veh in ipairs(getElementsByType("vehicle", getRootElement(), true)) do
		if veh:getVehicleType() == VehicleType.Automobile then
			if getElementData(veh,"Neon") == 1 then
				Neon.Vehicles[veh] = true
			end
		end
	end
end

function Neon.VehiclestreamedIn()
	local veh = source
	if getElementType(veh) == "vehicle" then
		if veh:getVehicleType() == VehicleType.Automobile then
			if getElementData(veh,"Neon") == 1 then
				Neon.Vehicles[veh] = true
			end
		end
	end
end

function Neon.VehiclestreamedOut(veh)
	local veh = source
	if getElementType(veh) == "vehicle" then
		if veh:getVehicleType() == VehicleType.Automobile then
			if getElementData(veh,"Neon") == 1 then
				Neon.Vehicles[veh] = nil
			end
		end
	end
end


function Neon.Render()
	for veh in pairs(Neon.Vehicles) do
		if isElement(veh) then
			if isElementStreamedIn(veh) then
				if (getElementData(veh,"Neon") == 1 and getVehicleOverrideLights ( veh ) == 2) then
					local NeonColor = getElementData(veh,"NeonColor")
					if NeonColor then
						local pos = veh:getPosition()
                        local _, _, rotZ = getElementRotation(veh)

						local r,g,b = unpack(NeonColor)
						local wheel1, wheel2, wheel3, wheel4 = Neon.getVehicleWheelPositions(veh)

                        local x,y,z = interpolateBetween(wheel1, wheel3, 0.5, "Linear")
						local x1,y1,z1 = interpolateBetween(wheel2, wheel4, 0.5, "Linear")

						local dist = getDistanceBetweenPoints3D(x, y, z ,x1, y1, z1)

						local rx,ry = 	Neon.findRotation(pos.x, pos.y, rotZ, dist/2,90)
						local rxy,ryy = Neon.findRotation(pos.x, pos.y, rotZ, dist/2,-90)

						local ez = getGroundPosition(rxy, ryy, pos.z)
						local ez1 = getGroundPosition(rx, ry, pos.z)

						local middlex,middley,middlez = interpolateBetween(rx,ry,ez1+0.05, rxy,ryy,ez+0.05,0.5, "Linear")
						local dist1 = getDistanceBetweenPoints3D(pos, middlex,middley,middlez)*1.5

						local ap = 255/dist1
						if ap > 220 then ap = 220 end
						dxDrawMaterialLine3D (rx,ry,ez1+0.05, rxy,ryy, ez+0.05, Neon.Image, 3, tocolor(r,g,b,ap), pos)
					end
				end
			end
		else
			Neon.Vehicles[veh] = nil
		end
	end
end
