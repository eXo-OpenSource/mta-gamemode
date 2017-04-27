function abseilStart()
	if getElementData(client, "abseiling") == "" then
		local veh = getPedOccupiedVehicle(client)
		if veh then
			if getVehicleType(veh) == "Helicopter" then
				local seat = getPedOccupiedVehicleSeat(client)
				setElementData(client, "abseiling", tostring(seat))
				setElementData(client, "abseilspeed", -0.25)

				removePedFromVehicle(client)

				--setVehicleDoorState(veh,seat+2,4)
				setVehicleDoorOpenRatio(veh, seat+2, 1, 500)

				local ped = createPed(0, 0, 0, 0)
				warpPedIntoVehicle(ped, veh, seat)

				setElementData(client, "abseilped",ped)
				setElementData(ped, "isabseilped", true)

				triggerClientEvent("doStartAbseil", client, veh, seat, ped)

				setTimer(abseil, 3400, 1, client, veh, seat, ped)
			end
		end
	end
end
addEvent("doStartPlayerAbseil", true)
addEventHandler("doStartPlayerAbseil", getRootElement(), abseilStart)

function abseilCancel()
	if getElementData(client, "abseiling") == "true" then
		local ped = getElementData(client, "abseilped")
		triggerClientEvent("doCancelAbseil", client)
		if getPedOccupiedVehicleSeat(ped) == 0 then
			triggerClientEvent("doAddVehicleToWatch", getPedOccupiedVehicle(ped))
		else
			if getElementData(ped,"isabseilped") == true then
				destroyElement(ped)
			end
		end
	end
end
addEvent("doCancelPlayerAbseil",true)
addEventHandler("doCancelPlayerAbseil", getRootElement(), abseilCancel)

function abseil(player, veh, seat, ped)
	setElementData(player, "abseiling", "true")
	detachElements(player, ped)
end

function possetting(x, y, z)
	setElementPosition(client, x, y, z)
	setPedAnimation(client, "ped", "abseil", -1, false, false, false)
	local x, y, z = getElementVelocity(client)
	setElementVelocity(client, x, y, -0.25)
end
addEvent("doSetPos", true)
addEventHandler("doSetPos", getRootElement(), possetting)

function stopAbseilAnimation(ped)
	setPedAnimation(client)
	if getPedOccupiedVehicleSeat(ped) == 0 then
		if getElementData(ped, "isabseilped") == true then
			triggerClientEvent("doAddVehicleToWatch", getPedOccupiedVehicle(ped))
		end
	else
		if getElementData(ped, "isabseilped") == true then
			destroyElement(ped)
		end
	end
end
addEvent("doForceStopAbseiling", true)
addEventHandler("doForceStopAbseiling", getRootElement(), stopAbseilAnimation)

function deletePiltoDummy()
	local ped = getVehicleOccupant(client, 0)
	if ped then
		if getElementData(ped,"isabseilped") == true then
			destroyElement(getVehicleOccupant(client, 0))
			triggerClientEvent("doRemoveVehicleToWatch", client)
		end
	end
end
addEvent("doRemovePilotDummy", true)
addEventHandler("doRemovePilotDummy", getRootElement(), deletePiltoDummy)

function checkForDummiesToDelete()
	local ped = getVehicleOccupant(client, 0)
	if ped then
		if getElementType(ped) == "ped" then
			if getElementData(ped, "isabseilped") == true then
				destroyElement(ped)
			end
		end
	end
end
addEventHandler("onVehicleExplode", getRootElement(), checkForDummiesToDelete)
