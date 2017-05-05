addEventHandler("onResourceStart", resourceRoot,
	function()
		if _DEBUG then
			for i,v in ipairs(getElementsByType("player")) do
				bindKey(v, "delete", "down", 
					function(player, key, state)
						restartResource(resourceRoot)
					end
				)
			end
			
			-- set up some test helicopters at the desert airfield
			helicopterIDs = {417, 487, 488, 497, 447, 469, 425, 548, 563}
				
			for i = 1, #helicopterIDs do
				local v = createVehicle(helicopterIDs[i], 426 - (i * 8), 2490, 19)
				setElementFrozen(v, true)
			end
				
			for i = 1, #helicopterIDs do
				local v = createVehicle(487, 426 - (i * 8), 2515, 17 + (i * 0.4))
				setElementFrozen(v, true)
			end
			
			testVehicle = createVehicle(487, 370, 2500, 19, 0, 0, 90)
			setElementFrozen(testVehicle, true)
				
			elements = {}
				
			local v = createVehicle(487, 425, 2500, 17, 0, 0, 90)
			local p = createPed(0, 426, 2500, 20)
			warpPedIntoVehicle(p, v)

			elements[#elements + 1] = {p = p, v = v, h = 24, l = 20}			
				
			local v = createVehicle(487, 410, 2500, 17, 0, 0, 90)
			local p = createPed(0, 426, 2500, 20)
			warpPedIntoVehicle(p, v)

			elements[#elements + 1] = {p = p, v = v, h = 21, l = 20}
			
			v = createVehicle(487, 395, 2500, 17, 0, 0, 90)
			p = createPed(0, 426, 2500, 20)
			warpPedIntoVehicle(p, v)
			
			elements[#elements + 1] = {p = p, v = v, h = 25, l = 21}	

			addCommandHandler("grabstate", 
				function(player, _, name, state, side, line)
					local target = player
				
					if name and #name > 0 then
						target = getPlayerFromName(name)
					end
					
					if target and isElement(target) then
						setPlayerGrabState(target, state == "true", testVehicle, tonumber(side) or 0, tonumber(line) or 0.5)
					end
				end
			)
			
			addCommandHandler("grabcheck",
				function(player, _, name)
					local target = player
				
					if name and #name > 0 then
						target = getPlayerFromName(name)
					end
					
					if target and isElement(target) then
						outputDebugString("grabcheck: isPlayerGrabbingHeli("..getPlayerName(target)..") > "..tostring(isPlayerGrabbingHeli(target)))
					end
				end
			)
			
			addCommandHandler("grabdata",
				function(player, _, name)
					local target = player
				
					if name and #name > 0 then
						target = getPlayerFromName(name)
					end
					
					if target and isElement(target) then
						local vehicle, side, linePercent, legsUp = getPlayerGrabData(player)
						outputDebugString("vehicle: "..tostring(vehicle)..", side: "..tostring(side)..", line: "..tostring(linePercent)..", legsUp: "..tostring(legsUp))
					end
				end
			)
			
			addCommandHandler("grabplayers",
				function(player, _, side, line)
					local players = getPlayersGrabbingHeli(testVehicle, tonumber(side), tonumber(line))
					
					if players then
						for i,p in ipairs(players) do
							outputDebugString("grabplayers: getPlayersGrabbingHeli(testVehicle, "..tostring(side)..", "..tostring(line)..") > "..getPlayerName(p))
						end
					end
				end
			)
		end
	end
)

addEvent("onClientReady", true)
addEventHandler("onClientReady", resourceRoot,
	function()
		if _DEBUG then
			triggerClientEvent(client, "clientDebugElements", resourceRoot, elements)
		end
	end
)