function abseilStart()
	if getElementData(source,"abseiling") == "" then
		local veh = getPedOccupiedVehicle(source)
		if veh then
			if getVehicleType(veh) == "Helicopter" then
				local seat = getPedOccupiedVehicleSeat(source)
				setElementData(source,"abseiling",tostring(seat))
				setElementData(source,"abseilspeed",-0.25)
				
				removePedFromVehicle(source)
				
				--setVehicleDoorState(veh,seat+2,4)
				setVehicleDoorOpenRatio(veh,seat+2,1,500)
				
				local ped = createPed(0,0,0,0)
				warpPedIntoVehicle(ped,veh,seat)
				
				setElementData(source,"abseilped",ped)
				setElementData(ped,"isabseilped",true)
				
				triggerClientEvent("doStartAbseil",source,veh,seat,ped)
				
				setTimer(abseil,3400,1,source,veh,seat,ped)
			end
		end
	end
end
addEvent("doStartPlayerAbseil",true)
addEventHandler("doStartPlayerAbseil",getRootElement(),abseilStart)

function abseilCancel()
	if getElementData(source,"abseiling") == "true" then
		local ped = getElementData(source,"abseilped")
		triggerClientEvent("doCancelAbseil",source)
		if getPedOccupiedVehicleSeat(ped) == 0 then
			triggerClientEvent("doAddVehicleToWatch",getPedOccupiedVehicle(ped))
		else
			if getElementData(ped,"isabseilped") == true then
				destroyElement(ped)
			end
		end
	end
end
addEvent("doCancelPlayerAbseil",true)
addEventHandler("doCancelPlayerAbseil",getRootElement(),abseilCancel)

function abseil(player,veh,seat,ped)
	setElementData(player,"abseiling","true")
	detachElements(player,ped)
end

function possetting(x,y,z)
	if client then
		setElementPosition(client,x,y,z)
		setPedAnimation(client,"ped","abseil",-1,false,false,false)
		local x,y,z = getElementVelocity(client)
		setElementVelocity(client,x,y,-0.25)
	end
end
addEvent("doSetPos",true)
addEventHandler("doSetPos",getRootElement(),possetting)

function stopAbseilAnimation(ped)
	setPedAnimation(source)
	if getPedOccupiedVehicleSeat(ped) == 0 then
		if getElementData(ped,"isabseilped") == true then
			triggerClientEvent("doAddVehicleToWatch",getPedOccupiedVehicle(ped))
		end
	else
		if getElementData(ped,"isabseilped") == true then
			destroyElement(ped)
		end
	end
end
addEvent("doForceStopAbseiling",true)
addEventHandler("doForceStopAbseiling",getRootElement(),stopAbseilAnimation)

function deletePiltoDummy()
	local ped = getVehicleOccupant(source,0)
	if ped then
		if getElementData(ped,"isabseilped") == true then
			destroyElement(getVehicleOccupant(source,0))
			triggerClientEvent("doRemoveVehicleToWatch",source)
		end
	end
end
addEvent("doRemovePilotDummy",true)
addEventHandler("doRemovePilotDummy",getRootElement(),deletePiltoDummy)

function checkForDummiesToDelete()
	local ped = getVehicleOccupant(source,0)
	if ped then
		if getElementType(ped) == "ped" then
			if getElementData(ped,"isabseilped") == true then
				destroyElement(ped)
			end
		end
	end
end
addEventHandler("onVehicleExplode",getRootElement(),checkForDummiesToDelete)