GroupRentVehicles = {}

function GroupRentVehicles.initalize()
    GroupRentVehicles.loadVehicles()

	addEventHandler("onClientElementDataChange", getRootElement(),
		function(dataName)
			if dataName == "forRent" or dataName == "forRentRate" then
				if isElementStreamedIn(source) then
					if getElementData(source,"forRent") == true then
						GroupRentVehicles.loadSpeekBubble(source)
						return
					end
				end
				GroupRentVehicles.destroySpeekBubble(source)
			end
	end)
end

function GroupRentVehicles.loadVehicles()
	for index, veh in ipairs(getElementsByType("vehicle", getRootElement(), true)) do
		if getElementData(veh, "OwnerType") == "group" and getElementData(veh, "forRent") == true then
			GroupRentVehicles.loadSpeekBubble(veh)
		end
	end
end

function GroupRentVehicles.VehiclestreamedIn(veh)
	if getElementType(veh) == "vehicle" then
		if getElementData(veh, "OwnerType") == "group" and getElementData(veh, "forRent") == true then
			GroupRentVehicles.loadSpeekBubble(veh)
		end
	end
end

function GroupRentVehicles.VehiclestreamedOut(veh)
	if getElementType(veh) == "vehicle" then
		if getElementData(veh, "OwnerType") == "group" and getElementData(veh, "forRent") == true then
			GroupRentVehicles.destroySpeekBubble(veh)
		end
	end
end

function GroupRentVehicles.loadSpeekBubble(veh)
	if SpeakBubble3D.Map[veh] then
		delete(SpeakBubble3D.Map[veh])
	end

	SpeakBubble3D.Map[veh] = SpeakBubble3D:new(veh, _"Zu vermieten!", _("Preis: %d$ pro Stunde", getElementData(veh, "forRentRate")))
	SpeakBubble3D.Map[veh]:setBorderColor(Color.Orange)
	SpeakBubble3D.Map[veh]:setTextColor(Color.Orange)
end



function GroupRentVehicles.destroySpeekBubble(veh)
	if SpeakBubble3D.Map[veh] then
		delete(SpeakBubble3D.Map[veh])
	end
end
addEvent("groupRentVehiclesDestroyBubble", true)
addEventHandler("groupRentVehiclesDestroyBubble", root, GroupRentVehicles.destroySpeekBubble)
