--[[ Heligrab - Client ]]--


helicopterOffsets = {
	-- News Chopper
	[488] = {
		x = 1.15,
		z = -1.05,
		front = 2.9,
		back = -1.1,
		-- defaults to facing inward (0) regardless of side/vehicle, facing adds to the default rotation (ie: 180 means facing out regardless of side/vehicle)
		facing = 0,
		-- default leg state (for vehicles that support it)
		legs = "down",
		-- number of people that can grab this vehicle simultaneously, call toggleHangingWeightLimit(false) serverside to remove this
		limit = 6
	},
	-- Police Maverick
	[497] = {
		x = 1.15,
		z = -1.05,
		front = 3.0,
		back = -1.1,
		facing = 0,
		legs = "down",
		limit = 8
	},
	-- Cargobob					
	[548] = {
		x = 1.8,
		z = .2,
		front = 3.6,
		back = -0.8,
		facing = 180,
		legs = "up",
		limit = 6
	},
	-- Raindance					
	[563] = {
		x = 1.25,
		z = -1.2,
		front = 1.7,
		back = 1.1,
		facing = 0,
		legs = "down",
		limit = 2
	},
	-- Seasparrow					
	[447] = {
		x = 1.2,
		z = -0.6,
		front = 2.3,
		back = -1.8,
		facing = 0,
		legs = "down",
		limit = 6
	},
	-- Hunter					
	[425] = {
		x = 2.4,
		z = -0.9,
		front = 1.4,
		back = -0.1,
		facing = 0,
		legs = "down",
		limit = 2
	},
	-- Leaviathan					
	[417] = {
		x = 2.7,
		z = 0.0,
		front = 1.8,
		back = -1.1,
		facing = 0,
		legs = "down",
		limit = 4
	},
	-- Sparrow					
	[469] = {
		x = 1.15,
		z = -0.9,
		front = 2.6,
		back = -0.6,
		facing = 0,
		legs = "down",
		limit = 6
	},
	-- Maverick					
	[487] = {
		x = 1.15,
		z = -1.05,
		front = 3.0,
		back = -1.1,
		facing = 0,
		legs = "down",
		limit = 8
	}		
}



-- distance your hands must be from the helicopter to be able to grab
local grabDistance = 1.2
-- completely ignore any vehicle further away than this when looking for grabs
local trackDistance = 5
-- distance the grab point must be from the ground before you are automatically dropped
local groundDropDistance = 1.5
-- distance the grab point must be away from the ground before you lift your legs up
local feetUpDistance = 3
-- whether the helicopters will be limited in how many people they can carry
local hangingWeightLimit = true
local showChatMessages = false
local chatColour

local updateTimer
local removedFromVehicle = false




-- these are no longer necessary in the newer mta versions
-- keep them for backwards compatibility
addEvent("receiveServerData", true)
addEventHandler("receiveServerData", resourceRoot, 
	function(weightLimit, inputPresets, chatMessages, colour)
		setHangingWeightLimit(weightLimit)
		
		showChatMessages = chatMessages
		chatColour = colour

		-- kept for backwards compatibility, but defaults to no binds/commands
		if inputPresets.hangCommands then
			for _,command in ipairs(inputPresets.hangCommands) do
				addCommandHandler(command, attemptGrabStart)
			end	
		end	
		
		if inputPresets.hangBinds then
			for _,bind in ipairs(inputPresets.hangBinds) do
				bindKey(bind, "down", attemptGrabStart)
			end
		end
		
		if inputPresets.dropCommands then
			for _,command in ipairs(inputPresets.dropCommands) do
				addCommandHandler(command, attemptGrabStop)
			end	
		end	
		
		if inputPresets.dropBinds then
			for _,bind in ipairs(inputPresets.dropBinds) do
				bindKey(bind, "down", attemptGrabStop)
			end
		end
		
		addCommandHandler("grab", attemptGrabStart)
		addCommandHandler("drop", attemptGrabStop)
		
		-- set grab to every jump key
		for key, state in pairs(getBoundKeys("jump")) do 
			bindKey(key, "down", "grab")
		end
		--bindKey("lshift", "down", "grab", "")
		
		bindKey("backspace", "down", "drop", "")
	end
)


function setHangingWeightLimit(state)
	if state == true or state == false then
		hangingWeightLimit = state
	end
end
addEvent("toggleHangingWeightLimit", true)
addEventHandler("toggleHangingWeightLimit", root, setHangingWeightLimit)


addEventHandler("onClientResourceStart", resourceRoot,
	function()
		-- ask the server for the current hanging weight limit value and the binds/commands
		triggerServerEvent("requestServerData", resourceRoot)
	end
)


addEventHandler("onClientResourceStop", resourceRoot,
	function()
		local hangVehicle = getElementData(localPlayer, "heligrab.vehicle")
		
		if hangVehicle then
			stopGrab()
		end
	end
)




function attemptGrabStart()
	if not getElementData(localPlayer, "heligrab.vehicle") then
		if isPlayerDead(localPlayer) or getElementHealth(localPlayer) <= 0.2 then
			return
		end
			
		-- dont want people grabbing whilst inside the helicopter (or another vehicle if they can get close enough)
		if isPedInVehicle(localPlayer) then
			if showChatMessages then
				outputChatBox("You are already inside a vehicle!", chatColour[1], chatColour[2], chatColour[3])
			end
			return
		end
			
		local target = findBestGrabVehicle()

		debugOutput(string.format("attemptGrabStart() - vehicle: %s, dist: %.2f (/ %.2f)", tostring(target.vehicle), target.distance, grabDistance))
		
		if target.vehicle and target.distance <= grabDistance then		
			-- trace a line from the grab point down groundDropDistance+0.2 (slightly below the height level at which you'd automatically be dropped)
			local collision,_,_,_,element = processLineOfSight(target.point[1], target.point[2], target.point[3],
																target.point[1], target.point[2], target.point[3] - (groundDropDistance + 0.2),
																true, true, false, true, false, true, false, false, target.vehicle)
				
			-- if it collides with the player then ignore it
			if collision and element == localPlayer then 
				collision = false 
			end
				
			-- the grab point is too close to the ground (or an element) and we dont want people hanging onto grounded helicopters
			if collision then		
				if showChatMessages then
					outputChatBox("That helicopter has barely left the ground yet!", chatColour[1], chatColour[2], chatColour[3])
				end
				return
			end
					
			if hangingWeightLimit then
				-- limit the number of people hanging per helicopter
				local count = 0
				
				for _,player in ipairs(getElementsByType("player", root, true)) do
					local hangVehicle = getElementData(player, "heligrab.vehicle")
					if hangVehicle and hangVehicle == target.vehicle then
						count = count + 1
					end
				end
								
				if count >= helicopterOffsets[getElementModel(target.vehicle)].limit then 
					if showChatMessages then
						outputChatBox("That helicopter can't take any more weight!", chatColour[1], chatColour[2], chatColour[3])
					end
					return
				end		
			end

			triggerEvent("makePlayerGrabVehicle", localPlayer, target.vehicle, target.side, target.linePercent)
		end
	end
end


function attemptGrabStop()
	triggerEvent("stopPlayerGrab", localPlayer, getElementData(localPlayer, "heligrab.vehicle"), nil, "manual")
end


function findBestGrabVehicle()
	local target = {distance = 9999}

	for i,vehicle in ipairs(getElementsByType("vehicle", root, true)) do
		if isElementOnScreen(vehicle) and helicopterOffsets[getElementModel(vehicle)] then
			-- no point getting the player position just for this check, so get one hand position now (which we will be using again later anyway)
			local leftHandX, leftHandY, leftHandZ = getPedBonePosition(localPlayer, 36)
			local vx, vy, vz = getElementPosition(vehicle)		
			
			-- if its within range to begin checking
			if getDistanceBetweenPoints3D(vx, vy, vz, leftHandX, leftHandY, leftHandZ) < trackDistance then								
				local matrix = getElementMatrix(vehicle)
				local vID = getElementModel(vehicle)
							
				local offset = {}
				offset.x = helicopterOffsets[vID].x
				offset.front = helicopterOffsets[vID].front
				offset.back = helicopterOffsets[vID].back
				offset.z = helicopterOffsets[vID].z
							
				-- Get the transformation of the 4 points (left/right side of the helicopter)
				local right = {}
				right.frontX = offset.x * matrix[1][1] + offset.front * matrix[2][1] + offset.z * matrix[3][1] + matrix[4][1]
				right.frontY = offset.x * matrix[1][2] + offset.front * matrix[2][2] + offset.z * matrix[3][2] + matrix[4][2]
				right.frontZ = offset.x * matrix[1][3] + offset.front * matrix[2][3] + offset.z * matrix[3][3] + matrix[4][3]
													
				right.backX = offset.x * matrix[1][1] + offset.back * matrix[2][1] + offset.z * matrix[3][1] + matrix[4][1]
				right.backY = offset.x * matrix[1][2] + offset.back * matrix[2][2] + offset.z * matrix[3][2] + matrix[4][2]
				right.backZ = offset.x * matrix[1][3] + offset.back * matrix[2][3] + offset.z * matrix[3][3] + matrix[4][3]

				local left = {}
				left.frontX = -offset.x * matrix[1][1] + offset.front * matrix[2][1] + offset.z * matrix[3][1] + matrix[4][1]
				left.frontY = -offset.x * matrix[1][2] + offset.front * matrix[2][2] + offset.z * matrix[3][2] + matrix[4][2]
				left.frontZ = -offset.x * matrix[1][3] + offset.front * matrix[2][3] + offset.z * matrix[3][3] + matrix[4][3]
													
				left.backX = -offset.x * matrix[1][1] + offset.back * matrix[2][1] + offset.z * matrix[3][1] + matrix[4][1]
				left.backY = -offset.x * matrix[1][2] + offset.back * matrix[2][2] + offset.z * matrix[3][2] + matrix[4][2]
				left.backZ = -offset.x * matrix[1][3] + offset.back * matrix[2][3] + offset.z * matrix[3][3] + matrix[4][3]							
																					
				local rightHandX, rightHandY, rightHandZ = getPedBonePosition(localPlayer, 26)
				
				-- should really check both hands against each side, but its a barely noticable loss
				right.point, right.linePercent, right.dist = getPointIntersectOnLine(rightHandX, rightHandY, rightHandZ, right.frontX, right.frontY, right.frontZ, right.backX, right.backY, right.backZ)
				left.point, left.linePercent, left.dist = getPointIntersectOnLine(leftHandX, leftHandY, leftHandZ, left.frontX, left.frontY, left.frontZ, left.backX, left.backY, left.backZ)
																										
				-- if the right side is closer (or they are both equal distance, in which case default to right)
				if right.dist <= left.dist then					
					-- if the distance to the right side of this helicopter is less than the distance to the currently targeted helicopter (or they are equal, in which case default to this new one)
					if right.dist < target.distance then
						target.vehicle = vehicle
						target.distance = right.dist
						target.side = 1
						target.point = right.point
						target.linePercent = right.linePercent
					end
				else	
					if left.dist < target.distance then
						target.vehicle = vehicle
						target.distance = left.dist	
						target.side = 0
						target.point = left.point
						target.linePercent = left.linePercent
					end
				end	
			end
		end		
	end
	
	return target
end


function grabVehicle(vehicle, side, linePercent)
	debugOutput("grabVehicle( "..tostring(vehicle)..", "..tostring(side)..", "..tostring(linePercent))
	
	local hangVehicle = getElementData(source, "heligrab.vehicle")
	
	-- already hanging and changing to new position, so drop and immediately re-attach
	if hangVehicle and ((vehicle ~= hangVehicle) or (side ~= getElementData(source, "heligrab.side")) or (linePercent ~= getElementData(source, "heligrab.linePercent"))) then	
		triggerEvent("stopPlayerGrab", source, hangVehicle, nil, "changing hang")
	end	

	setElementData(source, "heligrab.vehicle", vehicle)
	setElementData(source, "heligrab.side", side)
	setElementData(source, "heligrab.linePercent", linePercent)
							
	-- not sure if these are entirely necessary
	setElementVelocity(source, 0, 0, 0)
	setPedAnimation(source, nil, nil)	

	local vID = getElementModel(vehicle)
												
	local x = helicopterOffsets[vID].x
	if side and side == 0 then 
		x = -x 
	end
							
	local diff = math.abs(helicopterOffsets[vID].front - helicopterOffsets[vID].back)		

	setElementData(localPlayer, "heligrab.offsets", {x = x, y = helicopterOffsets[vID].back + (diff*(math.abs(linePercent-1))), z = helicopterOffsets[vID].z}, false)

	triggerServerEvent("playerGrabVehicle", resourceRoot, vehicle)
	
	removedFromVehicle = false

	-- originally this was done on render, however 50ms is sufficient 
	updateTimer = setTimer(updateGrabbingEffect, 50, 0)				
end
addEvent("makePlayerGrabVehicle", true)
addEventHandler("makePlayerGrabVehicle", localPlayer, grabVehicle)


function stopPlayerGrab(vehicle, force, reason, broadcast)
	local hangVehicle = getElementData(source, "heligrab.vehicle")
	
	if hangVehicle or force then
		debugOutput("stopPlayerGrab("..tostring(vehicle)..", "..tostring(force)..", "..tostring(reason)..")")
		
		if source == localPlayer then
			local inVehicle = false

			-- helis that we get warped into (and dont trigger onClientVehicleEnter) when on the surface of the water are a pain
			-- those with their drop key bound to enter_exit will be put into the drivers seat when they drop, this will remove them
			-- Seasparrow & Leviathon
			if (getElementModel(hangVehicle) == 447 or getElementModel(hangVehicle) == 417) then
				inVehicle = true
			end		

			stopGrab()	
			
			if broadcast or broadcast == nil then
				-- tell everyone else we're dropping
				triggerServerEvent("playerDropFromHeli", localPlayer, vehicle, reason, false, inVehicle)	
			end
			
			setElementData(localPlayer, "heligrab.vehicle", nil)
			setElementData(localPlayer, "heligrab.side", nil)
			setElementData(localPlayer, "heligrab.linePercent", nil)
			setElementData(localPlayer, "heligrab.legsUp", nil)
		else		
			if vehicle then
				detachElements(source, vehicle)
			end
			
			setPedAnimation(source, nil)
		end
	end
end
addEvent("stopPlayerGrab", true)
addEventHandler("stopPlayerGrab", root, stopPlayerGrab)


addCommandHandler("forcedrop",
	function()
		triggerEvent("stopPlayerGrab", localPlayer, getElementData(localPlayer, "heligrab.vehicle"), true, "force drop")
	end
)


function stopGrab()
	local hangVehicle = getElementData(localPlayer, "heligrab.vehicle")
	
	if hangVehicle then
		detachElements(localPlayer, hangVehicle)
	end
	
	setPedAnimation(localPlayer, nil)	
				
	killUpdateTimer()

	removedFromVehicle = false
end


-- check distance from the ground for legs/auto drops/collisions
-- local player
function updateGrabbingEffect()
	local hangVehicle = getElementData(localPlayer, "heligrab.vehicle")
	
	if hangVehicle then		
		-- uh oh, we are hanging but also inside a vehicle, can happen with the warp code used to put players into vehicles that sit on water (seasparrow, leviathan) 
		-- as onClientEnterVehicle isnt triggered in this case (if your enter_passenger key is also your grab key)
		if not removedFromVehicle and isPedInVehicle(localPlayer) then
			-- remove ourselves from the vehicle
			triggerServerEvent("removeHangingPedFromVehicle", resourceRoot)
			removedFromVehicle = true
			
			debugOutput("updateHangingEffect() -> removedFromVehicle")
		end
		
	
		-- get the position feetUpDistance below the grab point and the grab point
		local matrix = getElementMatrix(hangVehicle)
		
		local offsets = getElementData(localPlayer, "heligrab.offsets")
		
		local dropX = offsets.x * matrix[1][1] + offsets.y * matrix[2][1] + offsets.z - feetUpDistance * matrix[3][1] + matrix[4][1]
		local dropY = offsets.x * matrix[1][2] + offsets.y * matrix[2][2] + offsets.z - feetUpDistance * matrix[3][2] + matrix[4][2]
		local dropZ = offsets.x * matrix[1][3] + offsets.y * matrix[2][3] + offsets.z - feetUpDistance * matrix[3][3] + matrix[4][3]	
		
		local grabX = offsets.x * matrix[1][1] + offsets.y * matrix[2][1] + offsets.z * matrix[3][1] + matrix[4][1]
		local grabY = offsets.x * matrix[1][2] + offsets.y * matrix[2][2] + offsets.z * matrix[3][2] + matrix[4][2]
		local grabZ = offsets.x * matrix[1][3] + offsets.y * matrix[2][3] + offsets.z * matrix[3][3] + matrix[4][3]	
		
		local collision, cX, cY, cZ, cElement = processLineOfSight(grabX, grabY, grabZ, dropX, dropY, dropZ, true, true, false, true, false, true, false, false, localPlayer)
		
		-- if the collision that was found is the helicopter itself (eg: when hanging on a cargobob) then ignore it		
		if collision and cElement == hangVehicle then
			collision = false
		end
		
		local legsUp = getElementData(localPlayer, "heligrab.legsUp")
		
		if collision then
			local dist = getDistanceBetweenPoints3D(grabX, grabY, grabZ, cX, cY, cZ)
			-- approx player height, player is too close to something (either a collision or the ground) so drop
			if dist <= groundDropDistance then
				triggerEvent("stopPlayerGrab", localPlayer, hangVehicle, nil, "collision")
				return
			end
			
			if dist <= (groundDropDistance + feetUpDistance) then
				local _,anim = getPedAnimation(localPlayer)
				-- lift up the legs
				if anim ~= "FIN_LegsUp_Loop" and not legsUp then
					setElementData(localPlayer, "heligrab.legsUp", true)
				end		
				return
			end
		else			
			local _,anim = getPedAnimation(localPlayer)
			-- no collision, not near the ground so set default leg state
			if helicopterOffsets[getElementModel(hangVehicle)].legs == "down" then
				if anim ~= "FIN_Hang_Loop" and legsUp then
					setElementData(localPlayer, "heligrab.legsUp", false)
				end
			elseif helicopterOffsets[getElementModel(hangVehicle)].legs == "up" then
				if anim ~= "FIN_LegsUp_Loop" and not legsUp then
					setElementData(localPlayer, "heligrab.legsUp", true)
				end						
			end		
		end
	end
end


addEventHandler("onClientRender", root,
	function()
		-- check attachments, animations and rotations for all players
		for _,p in ipairs(getElementsByType("player", root, true)) do
			local vehicle = getElementData(p, "heligrab.vehicle") 
			if vehicle then		
				local side = getElementData(p, "heligrab.side")
				local legsUp = getElementData(p, "heligrab.legsUp")
				
				-- attach to heli
				if not isElementAttached(p) then
					local x = helicopterOffsets[getElementModel(vehicle)].x
					if side and side == 0 then 
						x = -x 
					end
											
					local diff = math.abs(helicopterOffsets[getElementModel(vehicle)].front - helicopterOffsets[getElementModel(vehicle)].back)		
					
					attachElements(p, vehicle, x, helicopterOffsets[getElementModel(vehicle)].back + (diff * (math.abs(getElementData(p, "heligrab.linePercent") - 1))), helicopterOffsets[getElementModel(vehicle)].z)	
				end
				
				-- set the hanging animation, check for leg up/down changes
				local _,anim = getPedAnimation(p)
				if anim == "FIN_Hang_Loop" then
					if legsUp == true then
						setPedAnimation(p, "FINALE", "FIN_LegsUp_Loop", -1, true, false, false)
					end
				elseif anim == "FIN_LegsUp_Loop" then
					if legsUp == false then
						setPedAnimation(p, "FINALE", "FIN_Hang_Loop", -1, true, false, false)
					end			
				else
					if legsUp then
						setPedAnimation(p, "FINALE", "FIN_LegsUp_Loop", -1, true, false, false)
					else
						setPedAnimation(p, "FINALE", "FIN_Hang_Loop", -1, true, false, false)
					end
				end		

				-- set hanging rotation
				local _,_,rz = getElementRotation(vehicle)
				local zrot = 90
				
				if side and side == 0 then 
					zrot = -90 
				end
				
				setPedRotation(p, rz + zrot + helicopterOffsets[getElementModel(vehicle)].facing)			
			end
		end
		
		if _DEBUG_DRAW_HANG_LINES then
			local px, py, pz = getElementPosition(localPlayer)
			
			for i,vehicle in ipairs(getElementsByType("vehicle", root, true)) do
				local vx, vy, vz = getElementPosition(vehicle)
				
				if getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz) < 50 then
					local matrix = getElementMatrix(vehicle)
					local vID = getElementModel(vehicle)
					
					if helicopterOffsets[vID] then
						local offset = {}
						offset.x = helicopterOffsets[vID].x
						offset.front = helicopterOffsets[vID].front
						offset.back = helicopterOffsets[vID].back
						offset.z = helicopterOffsets[vID].z	
					
						-- get the transformation of the 4 points (left/right side of the helicopter)
						local right = {}
						right.frontX = offset.x * matrix[1][1] + offset.front * matrix[2][1] + offset.z * matrix[3][1] + matrix[4][1]
						right.frontY = offset.x * matrix[1][2] + offset.front * matrix[2][2] + offset.z * matrix[3][2] + matrix[4][2]
						right.frontZ = offset.x * matrix[1][3] + offset.front * matrix[2][3] + offset.z * matrix[3][3] + matrix[4][3]
															
						right.backX = offset.x * matrix[1][1] + offset.back * matrix[2][1] + offset.z * matrix[3][1] + matrix[4][1]
						right.backY = offset.x * matrix[1][2] + offset.back * matrix[2][2] + offset.z * matrix[3][2] + matrix[4][2]
						right.backZ = offset.x * matrix[1][3] + offset.back * matrix[2][3] + offset.z * matrix[3][3] + matrix[4][3]

						local left = {}
						left.frontX = -offset.x * matrix[1][1] + offset.front * matrix[2][1] + offset.z * matrix[3][1] + matrix[4][1]
						left.frontY = -offset.x * matrix[1][2] + offset.front * matrix[2][2] + offset.z * matrix[3][2] + matrix[4][2]
						left.frontZ = -offset.x * matrix[1][3] + offset.front * matrix[2][3] + offset.z * matrix[3][3] + matrix[4][3]
															
						left.backX = -offset.x * matrix[1][1] + offset.back * matrix[2][1] + offset.z * matrix[3][1] + matrix[4][1]
						left.backY = -offset.x * matrix[1][2] + offset.back * matrix[2][2] + offset.z * matrix[3][2] + matrix[4][2]
						left.backZ = -offset.x * matrix[1][3] + offset.back * matrix[2][3] + offset.z * matrix[3][3] + matrix[4][3]			

						dxDrawLine3D(right.frontX, right.frontY, right.frontZ, right.backX, right.backY, right.backZ, 0xCCFF00AA, 20)
						dxDrawLine3D(left.frontX, left.frontY, left.frontZ, left.backX, left.backY, left.backZ, 0xCCFF00AA, 20)
					end
				end
			end
		end
		
		if _DEBUG_DRAW_HANG_DATA then
			dxDrawText(string.format("Heligrab hang data:"), 5, 385, 50, 50, tocolor(255, 50, 0), 1, "default-bold")
			
			if getElementData(localPlayer, "heligrab.vehicle") then
				dxDrawText(string.format("vehicle: %s", getVehicleName(getElementData(localPlayer, "heligrab.vehicle"))), 5, 415, 50, 50, tocolor(255, 50, 0), 1, "default-bold")
				dxDrawText(string.format("side: %s", tostring(getElementData(localPlayer, "heligrab.side"))), 5, 430, 50, 50, tocolor(255, 50, 0), 1, "default-bold")	
				dxDrawText(string.format("linePercent: %.4f", tostring(getElementData(localPlayer, "heligrab.linePercent"))), 5, 445, 50, 50, tocolor(255, 50, 0), 1, "default-bold")	
				dxDrawText(string.format("legsUp: %s", tostring(getElementData(localPlayer, "heligrab.legsUp"))), 5, 460, 50, 50, tocolor(255, 50, 0), 1, "default-bold")	
				
				dxDrawText(string.format("in vehicle: %s", tostring(isPedInVehicle(localPlayer))), 5, 500, 50, 50, tocolor(255, 50, 0), 1, "default-bold")	
			else
				dxDrawText("vehicle: none", 5, 415, 50, 50, tocolor(255, 50, 0), 1, "default-bold")
				dxDrawText("side: none", 5, 430, 50, 50, tocolor(255, 50, 0), 1, "default-bold")	
				dxDrawText("linePercent: none", 5, 445, 50, 50, tocolor(255, 50, 0), 1, "default-bold")	
				dxDrawText("legsUp: none", 5, 460, 50, 50, tocolor(255, 50, 0), 1, "default-bold")
			end
		end		
	end
)


function getPointIntersectOnLine(px, py, pz, x1, y1, z1, x2, y2, z2)	
	local line_direction = {x2 - x1, y2 - y1, z2 - z1}
	
	local t = dot(line_direction, {px - x1, py - y1, pz - z1}) / dot(line_direction, line_direction)
	
	if t > 1 then t = 1 end
	if t < 0 then t = 0 end

	local p = {x1 + ((x2 - x1) * t), y1 + ((y2 - y1) * t),z1 + ((z2 - z1) * t)}
	
	return p, t, getDistanceBetweenPoints3D(p[1], p[2], p[3], px, py, pz)
end


function dot(p1, p2)
	return p1[1] * p2[1] + p1[2] * p2[2] + p1[3] * p2[3]
end



addEventHandler("onClientElementDestroy", root,
	function()
		if getElementType(source) == "vehicle" and getVehicleType(source) == "Helicopter" then
			local hangVehicle = getElementData(localPlayer, "heligrab.vehicle")
			
			if hangVehicle and hangVehicle == source then
				triggerEvent("stopPlayerGrab", localPlayer, hangVehicle, false, "vehicle destroyed")
			end		
		end
	end
)


function onClientVehicleStartEnter(player, seat)
	if player == localPlayer and getElementData(player, "heligrab.vehicle") then
		cancelEvent()		
	end
end
addEventHandler("onClientVehicleStartEnter", root, onClientVehicleStartEnter)	


function onClientPlayerWasted()
	-- died whilst hanging, so drop
	if source == localPlayer then
		local hangVehicle = getElementData(source, "heligrab.vehicle")
		
		if hangVehicle then
			triggerEvent("stopPlayerGrab", localPlayer, hangVehicle, false, "died")
		end
	end
end
addEventHandler("onClientPlayerWasted", root, onClientPlayerWasted)	


function killUpdateTimer()
	if updateTimer then
		if isTimer(updateTimer) then
			killTimer(updateTimer)
		end
		
		updateTimer = nil
	end
end





