GroupSaleVehicles = {}

function GroupSaleVehicles.initalize()
    GroupSaleVehicles.loadVehicles()
    addEventHandler("onClientElementStreamIn", getRootElement(), GroupSaleVehicles.VehiclestreamedIn)
    addEventHandler("onClientElementStreamOut", getRootElement(), GroupSaleVehicles.VehiclestreamedOut)

	addEventHandler("onClientElementDataChange", getRootElement(),
		function(dataName)
			if dataName == "forSale" then
				if isElementStreamedIn(source) then
					if getElementData(source,"forSale") == true then
						GroupSaleVehicles.loadSpeekBubble(veh)
						return
					end
				end
				GroupSaleVehicles.destroySpeekBubble(veh)
			end
	end)
end

function GroupSaleVehicles.loadVehicles()
	for index, veh in ipairs(getElementsByType("vehicle", getRootElement(), true)) do
		if getElementData(veh, "OwnerType") == "group" and getElementData(veh, "forSale") == true then
			GroupSaleVehicles.loadSpeekBubble(veh)
		end
	end
end

function GroupSaleVehicles.VehiclestreamedIn()
	local veh = source
	if getElementType(veh) == "vehicle" then
		if getElementData(veh, "OwnerType") == "group" and getElementData(veh, "forSale") == true then
			GroupSaleVehicles.loadSpeekBubble(veh)
		end
	end
end

function GroupSaleVehicles.VehiclestreamedOut(veh)
	local veh = source
	if getElementType(veh) == "vehicle" then
		if getElementData(veh, "OwnerType") == "group" and getElementData(veh, "forSale") == true then
			GroupSaleVehicles.destroySpeekBubble(veh)
		end
	end
end

function GroupSaleVehicles.loadSpeekBubble(veh)
	if not SpeakBubble3D.Map[veh] then
		SpeakBubble3D.Map[veh] = SpeakBubble3D:new(veh, "Zu Verkaufen!", _("Preis: ", getElementData(veh, "forSalePrice")))
	end
end

function GroupSaleVehicles.destroySpeekBubble(veh)
	if not SpeakBubble3D.Map[veh] then
		delete(SpeakBubble3D.Map[veh])
	end
end
