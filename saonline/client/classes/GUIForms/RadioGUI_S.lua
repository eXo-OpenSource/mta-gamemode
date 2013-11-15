addEventHandler("onResourceStart", getResourceRootElement(), function()
	
end)

function reload_car_radios(vehicle)
	local cars = getElementsByType("vehicle")
	for i, car in ipairs(cars) do
		if vehicle == car then
			local car_radio_url = getElementData(car, "now_radio_played")
			if car_radio_url then
				--triggerClientEvent("play_car_radio_out", getRootElement(), car_radio_url, car)
			end
		end
	end
end
addEvent("car_radio_changed", true)
addEventHandler("car_radio_changed", getRootElement(), reload_car_radios)

addEvent("radio_load_success", true)
addEventHandler("radio_load_success", getRootElement(), function()
	outputServerLog("* [ERFOLGREICH] Radiosystem erfolgreich geladen!")
end)