---------------------------------------
-- Section: Garbage place tool
---------------------------------------
bindKey("f2", "down",
	function()
		local x, y, z = getElementPosition(localPlayer)
		z = getGroundPosition(x, y, z) + 0.1
	
		triggerServerEvent("garbageAdd", localPlayer, x, y, z)
	end
)
