local localplayer = getLocalPlayer()
setElementData(localplayer,"abseiling","")
local vehiclesToWatch = {}
local tick

function abseilBind()
	local data = getElementData(localplayer,"abseiling")
	if data == "" then
		local veh = getPedOccupiedVehicle(localplayer)
		if veh and getPedOccupiedVehicleSeat(localPlayer) ~= 0 then
			if getVehicleType(veh) == "Helicopter" then
				local vx,vy,vz = getElementPosition(veh)
				if not processLineOfSight(vx,vy,vz,vx,vy,vz-10,true,true,false,true,false,true,true,false,veh) then
					triggerServerEvent("doStartPlayerAbseil",localplayer)
				end
			end
		end
	elseif data == "true" then
		triggerServerEvent("doCancelPlayerAbseil",localplayer)
	end
end
addCommandHandler("rope",abseilBind)

function startAbseil(veh,seat,ped)
	setElementCollidableWith(source,veh,false)
	setElementCollidableWith(source,ped,false)

	if source == localplayer then
		addEventHandler("onClientPlayerDamage",source,cancelDamage)
		setCameraClip(true,false)
	end

	setElementAlpha(ped,0)

	---[[
	if seat == 0  then
		attachElements(source,ped,0.5,0,0.85)
	elseif seat == 1 then
		attachElements(source,ped,-0.5,0,0.85)
	elseif seat == 2 then
		attachElements(source,ped,-0.10,0,0.85)
	elseif seat == 3 then
		attachElements(source,ped,0.10,0,0.85)
	end
	setPedAnimation(source,"SWAT","swt_vent_02",-1,false,false,false)
	--]]
	--[[
	if seat == 0  then
		attachElements(source,ped,0.15,0,0.85)
	elseif seat == 1 then
		attachElements(source,ped,-0.15,0,0.85)
	elseif seat == 2 then
		attachElements(source,ped,-0.10,0,0.85)
	elseif seat == 4 then
		attachElements(source,ped,0.10,0,0.85)
	end
	setPedAnimation(source,"SWAT","swt_vent_01",-1,false,false,false)
	--]]
	setTimer(abseil,3400,1,source,veh,seat,ped)
end
addEvent("doStartAbseil",true)
addEventHandler("doStartAbseil",getRootElement(),startAbseil)

function abseil(player,veh,seat,ped)
	addEventHandler("onClientPlayerWasted",player,deathAnim)

	local x,y,z = getPedBonePosition(player,2)
	local rx,ry,rz = getElementRotation(player)
	detachElements(player,ped)

	if player == localplayer then
		triggerServerEvent("doSetPos",player,x,y,z)
	end

	setElementPosition(player,x,y,z)
	--setElementRotation(player,0,0,getPedRotation(player))
	setPedAnimation(player,"ped","abseil",-1,false,false,true)

	setElementCollidableWith(player,veh,true)
	setElementCollidableWith(player,ped,true)

	if player == localplayer then
		setElementCollidableWith(player,veh,true)
		setElementCollidableWith(player,ped,true)
		removeEventHandler("onClientPlayerDamage",localplayer,cancelDamage)
	end

	if player == localplayer then
		setCameraClip(true,true)
	end
end

function render()
	tick = tick or getTickCount()
	local nowtick = getTickCount()
	for i, v in pairs(getElementsByType("player", root, true)) do --fix
		local data = getElementData(v,"abseiling")
		if data ~= "" then
			local ped = getElementData(v,"abseilped")
			if ped then
				local veh = getPedOccupiedVehicle(ped)
				if tonumber(data) == 0 or tonumber(data) == 2 then
					setPedRotation(v,getPedRotation(ped)+90)
				elseif tonumber(data) == 1 or tonumber(data) == 3 then
					setPedRotation(v,getPedRotation(ped)-90)
				elseif data == "true" then
					local x,y,z = getElementPosition(v)
					local b1x,b1y,b1z = getPedBonePosition(v,36)
					local b2x,b2y,b2z = getPedBonePosition(v,25)
					local z3 = getGroundPosition(b2x,b2y,b2z)
					local px4,py4,pz4 = getElementPosition(ped)

					dxDrawLine3D(b1x,b1y,b1z,px4,py4,pz4,tocolor(0,0,0,255),2,false,0)
					dxDrawLine3D(b1x,b1y,b1z,b2x,b2y,b2z,tocolor(0,0,0,255),2,false,0)
					dxDrawLine3D(b2x,b2y,b2z,b2x,b2y,z3,tocolor(0,0,0,255),2,false,0)

					if not isPedOnGround(v) and not (isElementInWater(v) or testLineAgainstWater(x,y,z+1,x,y,z-1)) then
						if v == localplayer then
							local _,_,vvelz = getElementVelocity(veh)
							local vx,vy,_ = getElementPosition(getElementData(v,"abseilped"))
							local px,py,_ = getElementPosition(v)
							local sx,sy = 0.1*(vx-px),0.1*(vy-py)

							local speed = tonumber(getElementData(v,"abseilspeed"))

							if getPedControlState("forwards") and not getPedControlState("backwards") then
								speed = speed - (getTickCount()-tick)*0.0005
								if speed < -0.4 then
									speed = -0.4
								end
							elseif getPedControlState("backwards") and not getPedControlState("forwards") then
								speed = speed + (getTickCount()-tick)*0.0005
								if speed > -0.1 then
									speed = -0.1
								end
							end

							setElementData(v,"abseilspeed",speed)

							setElementVelocity(v,sx,sy,speed+vvelz)
						end
					else
						setElementData(v,"abseiling","")
						setElementData(v,"abseilped","")
						setElementData(v,"abseilspeed",-0.25)

						setPedAnimation(v)
						removeEventHandler("onClientPlayerWasted",v,deathAnim)
						if v == localplayer then
							triggerServerEvent("doForceStopAbseiling",v,ped)
						else
							setElementCollidableWith(v,veh,true)
							setElementCollidableWith(v,ped,true)

							removeEventHandler("onClientPlayerDamage",v,cancelDamage)
						end
					end
				end
			end
		end
	end
	for i,v in ipairs(vehiclesToWatch) do
		if isElement(v) then
			local x,y,z = getElementPosition(v)
			local gz = getGroundPosition(x,y,z)
			if gz then
				if z - gz <= 2 then
					triggerServerEvent("doRemovePilotDummy",v)
					table.remove(vehiclesToWatch,i)
				end
			end
		else
			table.remove(vehiclesToWatch,i)
		end
	end
	tick = nowtick
end
addEventHandler("onClientRender",getRootElement(),render)

function cancelDamage()
	cancelEvent()
end

function deathAnim()
	if getElementData(source,"abseiling") == "true" then
		local ped = getElementData(source,"abseilped")
		local veh = getPedOccupiedVehicle(ped)

		setElementData(source,"abseiling","")
		setElementData(source,"abseilped","")
		setElementData(source,"abseilspeed",-0.25)

		setPedAnimation(source,"ped","KO_shot_front",-1,false,false,false)
		removeEventHandler("onClientPlayerWasted",source,deathAnim)
		if source == localplayer then
			triggerServerEvent("doForceStopAbseiling",source,ped)
		else
			setElementCollidableWith(source,veh,true)
			setElementCollidableWith(source,ped,true)
			removeEventHandler("onClientPlayerDamage",source,cancelDamage)
		end
	end
end

function cancelAbseiling()
	local ped = getElementData(source,"abseilped")
	setElementData(source,"abseiling","")
	setElementData(source,"abseilped","")
	setElementData(source,"abseilspeed",-0.25)

	setPedAnimation(source)
	removeEventHandler("onClientPlayerWasted",source,deathAnim)
	if source == localplayer then
		triggerServerEvent("doForceStopAbseiling",source,ped)
	else
		setElementCollidableWith(source,veh,true)
		setElementCollidableWith(source,ped,true)
		removeEventHandler("onClientPlayerDamage",source,cancelDamage)
	end
end
addEvent("doCancelAbseil",true)
addEventHandler("doCancelAbseil",getRootElement(),cancelAbseiling)

function getMatrixOffsets(element,x,y,z)
	local matrix = getElementMatrix(element)
	local offX = x * matrix[1][1] + y * matrix[2][1] + z * matrix[3][1] + matrix[4][1]
	local offY = x * matrix[1][2] + y * matrix[2][2] + z * matrix[3][2] + matrix[4][2]
	local offZ = x * matrix[1][3] + y * matrix[2][3] + z * matrix[3][3] + matrix[4][3]
	return offX, offY, offZ
end

function addVehicleToWatch()
	table.insert(vehiclesToWatch,source)
end
addEvent("doAddVehicleToWatch",true)
addEventHandler("doAddVehicleToWatch",getRootElement(),addVehicleToWatch)

function removeVehicleToWatch()
	for i,v in ipairs(vehiclesToWatch) do
		if v == source then
			table.remove(vehiclesToWatch,i)
			break
		end
	end
end
addEvent("doRemoveVehicleToWatch",true)
addEventHandler("doRemoveVehicleToWatch",getRootElement(),removeVehicleToWatch)
