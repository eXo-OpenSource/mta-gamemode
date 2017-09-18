Neon = {}

function Neon.initalize()
    Neon.Image = dxCreateTexture("files/images/Other/Neon.png")
    Neon.Vehicles = {}
    Neon.getNeonTable()
	Neon.toggle(core:get("Vehicles", "Neon", true))

	addEventHandler("onClientElementDataChange", getRootElement(),
		function(dataName)
			if dataName == "Neon" or dataName == "NeonColor" then
				if isElementStreamedIn(source) and getElementType(source) == "vehicle" then
					if getElementData(source,"Neon") == true then
						Neon.Vehicles[source] = true
					end
				end
			end
	end)
end

function Neon.getVehicleWheelPositions(vehicle)
	local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(vehicle)
	if minX and minY and minZ and maxX and maxY and maxZ then
		local wheel1 = vehicle.matrix:transformPosition(minX, maxY, minZ)
		local wheel2 = vehicle.matrix:transformPosition(minX, -maxY, minZ)
		local wheel3 = vehicle.matrix:transformPosition(maxX, maxY, minZ)
		local wheel4 = vehicle.matrix:transformPosition(maxX, -maxY, minZ)
		return wheel1, wheel2, wheel3, wheel4
	end
	return false
end

function Neon.getNeonTable()
	for index, veh in ipairs(getElementsByType("vehicle", getRootElement(), true)) do
		if veh:getVehicleType() == VehicleType.Automobile then
			if getElementData(veh,"Neon") == true then
				Neon.Vehicles[veh] = true
			end
		end
	end
end

function Neon.VehiclestreamedIn(veh)
	if getVehicleType(veh) == VehicleType.Automobile then
		if getElementData(veh,"Neon") == true then
			Neon.Vehicles[veh] = true
		end
	end
end

function Neon.VehiclestreamedOut(veh)
	if getVehicleType(veh) == VehicleType.Automobile then
		if getElementData(veh,"Neon") == true then
			Neon.Vehicles[veh] = nil
		end
	end
end

function Neon.findRotation(x,y,rz,dist,rot)
    local x = x+dist*math.cos(math.rad(rz+rot))
    local y = y+dist*math.sin(math.rad(rz+rot))
    return x,y
 end

function Neon.Render()
	for veh in pairs(Neon.Vehicles) do
		if isElement(veh) then
			if isElementStreamedIn(veh) then
				if (getElementData(veh,"Neon") == true and getVehicleOverrideLights ( veh ) == 2) then
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


function Neon.toggle(state)
	if state and not Neon.ms_Active then
		addEventHandler("onClientPreRender", getRootElement(), Neon.Render)
		Neon.ms_Active = true
	elseif not state and Neon.ms_Active then
		removeEventHandler("onClientPreRender", getRootElement(), Neon.Render)
		Neon.ms_Active = false
	end
end