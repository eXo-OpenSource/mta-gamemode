GroupSaleVehicles = {}

function GroupSaleVehicles.initalize()
    GroupSaleVehicles.loadVehicles()
    addEventHandler("onClientElementStreamIn", getRootElement(), GroupSaleVehicles.VehiclestreamedIn)
    addEventHandler("onClientElementStreamOut", getRootElement(), GroupSaleVehicles.VehiclestreamedOut)

	addEventHandler("onClientElementDataChange", getRootElement(),
		function(dataName)
			if dataName == "forSale" or dataName == "forSalePrice" then
				if isElementStreamedIn(source) then
					if getElementData(source,"forSale") == true then
						GroupSaleVehicles.loadSpeekBubble(source)
						return
					end
				end
				GroupSaleVehicles.destroySpeekBubble(source)
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
	if SpeakBubble3D.Map[veh] then
		delete(SpeakBubble3D.Map[veh])
	end

	SpeakBubble3D.Map[veh] = SpeakBubble3D:new(veh, _"Zu Verkaufen!", _("Preis: %d$", getElementData(veh, "forSalePrice")))
end



function GroupSaleVehicles.destroySpeekBubble(veh)
	if SpeakBubble3D.Map[veh] then
		delete(SpeakBubble3D.Map[veh])
	end
end
addEvent("groupSaleVehiclesDestroyBubble", true)
addEventHandler("groupSaleVehiclesDestroyBubble", root, GroupSaleVehicles.destroySpeekBubble)
