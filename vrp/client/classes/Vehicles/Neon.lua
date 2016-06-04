Neon = {}

Neon.Image = dxCreateTexture("files/images/Other/Neon.png")
Neon.Vehicles = {}

function Neon.getPositionFromElementAtOffset(element, x, y, z)
  if not x or not y or not z then
    return x, y, z
  end
  local matrix = getElementMatrix(element)
  local offX = x * matrix[1][1] + y * matrix[2][1] + z * matrix[3][1] + matrix[4][1]
  local offY = x * matrix[1][2] + y * matrix[2][2] + z * matrix[3][2] + matrix[4][2]
  local offZ = x * matrix[1][3] + y * matrix[2][3] + z * matrix[3][3] + matrix[4][3]
  return offX, offY, offZ
end

function Neon.findRotation (x,y,rz,dist,rot)
    local x = x+dist*math.cos(math.rad(rz+rot))
    local y = y+dist*math.sin(math.rad(rz+rot))

    return x,y
end

function Neon.getVehicleWheelPositions(vehicle)
	local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(vehicle)
	if minX and minY and minZ and maxX and maxY and maxZ then
		local x1, y1, z1 = Neon.getPositionFromElementAtOffset(vehicle, minX, maxY, minZ)
		local x2, y2, z2 = Neon.getPositionFromElementAtOffset(vehicle, minX, -maxY, minZ)
		local x3, y3, z3 = Neon.getPositionFromElementAtOffset(vehicle, maxX, maxY, minZ)
		local x4, y4, z4 = Neon.getPositionFromElementAtOffset(vehicle, maxX, -maxY, minZ)
		return x1, y1, z1,x2, y2, z2,x3, y3, z3,x4, y4, z4
	end
	return 0,0,0,0,0,0,0,0,0
end

function Neon.getNeonTable()
	for index, veh in ipairs(getElementsByType("vehicle", getRootElement(), true)) do
		if veh:getVehicleType() == VehicleType.Automobile then
			if getElementData(veh,"Neon") == 1 then
				outputChatBox("neon")
				Neon.Vehicles[veh] = true
			end
		end
	end
end
Neon.getNeonTable()

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
addEventHandler("onClientElementStreamIn",getRootElement(),Neon.VehiclestreamedIn)

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
addEventHandler("onClientElementStreamOut",getRootElement(),Neon.VehiclestreamedOut)

addEventHandler("onClientPreRender", getRootElement(),
    function()
		for veh in pairs(Neon.Vehicles) do
			if isElement(veh) then
				if isElementStreamedIn(veh) then
					if (getElementData(veh,"Neon") == 1 and getVehicleOverrideLights ( veh ) == 2) then
						local NeonColor = getElementData(veh,"NeonColor")
						if NeonColor then
							local x,y,z = getElementPosition(veh)
							local xsss,ysss,zsss = getElementPosition(veh)
							local ez = getGroundPosition(x,y,z)
							local model = getElementModel(veh)

							local r,g,b = unpack(NeonColor)

							local x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4 = Neon.getVehicleWheelPositions(veh)
							local x,y,z = interpolateBetween (x1,y1,z1,x3,y3,z3,0.5, "Linear")
							local x1,y1,z1 = interpolateBetween (x2,y2,z2,x4,y4,z4,0.5, "Linear")

							local dist = getDistanceBetweenPoints3D(x,y,z,x1,y1,z1 )

							local _,_,z = getElementPosition(veh)
							local xrx,yry,zrz = getElementRotation(veh)
							local rx,ry = 	Neon.findRotation (xsss,ysss,zrz,dist/2,90)
							local rxy,ryy = Neon.findRotation (xsss,ysss,zrz,dist/2,-90)
							--local rx,ry,rxy,ryy = findrotation (xsss,ysss,zrz,dist/2)
							local ez = getGroundPosition(rxy,ryy,z)
							local ez1 = getGroundPosition(rx,ry,z)
							local zghround = getGroundPosition(xsss,ysss,zsss)

							local middlex,middley,middlez = interpolateBetween (rx,ry,ez1+0.05, rxy,ryy,ez+0.05,0.5, "Linear")
							local dist1 = getDistanceBetweenPoints3D(xsss,ysss,zsss,middlex,middley,middlez)*1,5

							local ap = 255/dist1
							if (ap > 255) then ap = 255 end
							if ap > 220 then ap = 220 end
							state = dxDrawMaterialLine3D (rx,ry,ez1+0.05, rxy,ryy,ez+0.05, Neon.Image, 2.5, tocolor(r,g,b,ap),xsss,ysss,zsss)
						end
					end
				end
			else
				Neon.Vehicles[veh] = nil
			end
		end
	end
)
