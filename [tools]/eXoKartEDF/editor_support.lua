function isEditor()
	-- see if editor resource running
	if g_IsEditor == nil then
		local editorRes = getResourceFromName( "editor" )
		g_IsEditor = editorRes and getResourceState( editorRes ) == 'running'
	end
	return g_IsEditor
end

if isEditor() then
	local karts = {}
	local checkpoints = {}
	local showhits = false
	local checkpointAlpha = 0
	local calcTime = false
	
	for _, spawnpoint in pairs(getElementsByType"spawnpoint") do
		local position = Vector3(exports.edf:edfGetElementPosition(spawnpoint))
		local rotation = Vector3(exports.edf:edfGetElementRotation(spawnpoint))
	
		local kart = createVehicle(571, position, rotation)
		table.insert(karts, kart)
	end
	
	for _, checkpoint in pairs(getElementsByType"checkpoint") do
		local position = Vector3(exports.edf:edfGetElementPosition(checkpoint))
		local size = exports.edf:edfGetElementProperty(checkpoint, "size")
		
		local marker = createMarker(position, "cylinder", size, 0, 135, 255, checkpointAlpha)
		table.insert(checkpoints, marker)
		
		addEventHandler("onMarkerHit", marker,
			function(hitElement)
				if not showhits then return end
				if getElementType(hitElement) ~= "vehicle" then return end
				if not getVehicleOccupant(hitElement) then return end
								
				for k, v in pairs(checkpoints) do
					if v == source then
						outputChatBox(("Hit Checkpoint ID %d"):format(k), getVehicleOccupant(hitElement), 255, 80, 0)
					end
				end
			end
		)
	end
		
	addCommandHandler("hits",
		function()
			showhits = not showhits
			outputChatBox(("show hits: %s"):format(tostring(showhits)))
		end
	)

	addCommandHandler("marker",
		function()
			checkpointAlpha = checkpointAlpha > 0 and 0 or 150
			for k, v in pairs(checkpoints) do
				setMarkerColor(v, 0, 135, 255, checkpointAlpha)
			end
			
			outputChatBox(("Set checkpoint alpha to: %d"):format(checkpointAlpha))
		end
	)	
	
end

