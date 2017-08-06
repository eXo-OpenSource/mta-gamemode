addEventHandler("onElementInteriorChange", root, function() 
	outputChatBox("hii")
	if getElementType(source) == "player" then 
		triggerClientEvent("interior_fix:onIntChange", source, getElementInterior(source))
	end
end)

addEventHandler("onElementDimensionChange", root, function() 
	if getElementType(source) == "player" then 
		triggerClientEvent("interior_fix:onDimChange", source, getElementDimension(source))
	end
end)