addEventHandler("onElementInteriorChange", root, function() 
	if source and isElement(source) then
		if getElementType(source) == "player" then 
			triggerClientEvent("interior_fix:onIntChange", source, getElementInterior(source))
		end
	end
end)

addEventHandler("onElementDimensionChange", root, function() 
	if source and isElement(source) then
		if getElementType(source) == "player" then 
			triggerClientEvent("interior_fix:onDimChange", source, getElementDimension(source))
		end
	end
end)