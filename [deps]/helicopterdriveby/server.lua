local playerVehicle = {}

function isAvilableVehicle(id)
	if id and type(id) == "number" then
		if Settings["AvilableVehicles"][id] then
			return true
		end
	end
	return false
end

function getPlayerSeat(player)
	if isPedInVehicle(player) then
		local vehicle = getPedOccupiedVehicle(player)
		if isAvilableVehicle(getElementModel(vehicle)) then
			local p1 = getVehicleOccupant(vehicle, 0)
			local p2 = getVehicleOccupant(vehicle, 1)
			local p3 = getVehicleOccupant(vehicle, 2)
			local p4 = getVehicleOccupant(vehicle, 3)
			if player == p1 then
				return false
			elseif player == p2 then
				return 2
			elseif player == p3 then
				return 3
			elseif player == p4 then
				return 4
			end
		end
	end
	return false
end

function glueToHeli(player)
	if isPedInVehicle(player) then
		local vehicle = getPedOccupiedVehicle(player)
		local vehicleID = getElementModel(vehicle)
		if isAvilableVehicle(vehicleID) then
			if not getElementData(player, "HeliGlue") then
				if player ~= getVehicleController(vehicle) then
					local seat = getPlayerSeat(player)
					if seat ~= false then
						removePlayerFromVehicle(player)
						if seat == 2 then
							attachElements(player, vehicle, 1.2, 1.5, 0)
						elseif seat == 3 then
							attachElements(player, vehicle, -1.2, 0, 0)
						elseif seat == 4 then
							attachElements(player, vehicle, 1.2, 0, 0)
						end
						setElementData(player, "HeliGlue", true)
						toggleControl(player, "enter_exit", false)
						playerVehicle[player] = {}
						playerVehicle[player] = {vehicle, seat, player}
						triggerClientEvent(player, "HDB:Camera", player, true)
					end
				end
			end
		end
	end
end

function unglueFromHeli(player)
	local HeliGlue = getElementData(player, "HeliGlue") or false
	if HeliGlue then
		if not isPedInVehicle(player) then
			if playerVehicle[player] and #playerVehicle[player] ~= 0 then
				local vehicle, seat = playerVehicle[player][1], playerVehicle[player][2]
				if isElement(vehicle) then
					detachElements(player)
					warpPedIntoVehicle(player, vehicle, seat-1)
					setElementData(player, "HeliGlue", false)
					toggleControl(player, "enter_exit", true)
					playerVehicle[player] = {}
					setPedWeaponSlot(player, 0)
					triggerClientEvent(player, "HDB:Camera", player, false)
				end
			end
		end
	end
end

function eject(player)
	local HeliGlue = getElementData(player, "HeliGlue") or false
	if HeliGlue then
		if not isPedInVehicle(player) then
			if playerVehicle[player] and #playerVehicle[player] ~= 0 then
				local vehicle, seat = playerVehicle[player][1], playerVehicle[player][2]
				if isElement(vehicle) then
					detachElements(player)
					setElementData(player, "HeliGlue", false)
					playerVehicle[player] = {}
					setPedWeaponSlot(player, 0)
					triggerClientEvent(player, "HDB:Camera", player, false)
				end
			end
		end
	end
end

addEventHandler("onResourceStart", resourceRoot,
	function()
		for _,player in ipairs(getElementsByType("player")) do
			setElementData(player, "HeliGlue", false)
			playerVehicle[player] = {}
		end
	end
)

addEvent("HelicopterDriveBy:toggle", true)
addEventHandler("HelicopterDriveBy:toggle", root, function() 
	if client then 
		if not getElementData(client, "HeliGlue") then
			glueToHeli(client)
		else 
			unglueFromHeli(client)
		end
	end
end)

addEventHandler("onPlayerLogin", root,
	function()
		setElementData(source, "HeliGlue", false)
		playerVehicle[source] = {}
	end
)

addEvent("HelicopterDriveBy:onClientWasted", true)
addEventHandler("HelicopterDriveBy:onClientWasted", root,
	function()
		unglueFromHeli(client)
	end
)


addEventHandler("onVehicleExplode", root,
	function()
		for _,player in ipairs(getElementsByType("player")) do
			if playerVehicle[player][1] == source then
				unglueFromHeli(value[3])
			end
		end
	end
)
