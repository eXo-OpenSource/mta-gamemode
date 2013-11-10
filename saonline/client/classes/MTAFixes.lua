-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        client/classes/MTAFixes.lua
-- *  PURPOSE:     MTA fixes class
-- *
-- ****************************************************************************
MTAFixes = inherit(Singleton)

function MTAFixes:constructor()
	self:dft_pathnode_teleport()
end

function MTAFixes:dft_pathnode_teleport()
	--[[
		GTA teleports the player to the closest pedestrian path node if the line of sight between the ped and the vehicle is not clear.
		This collides (for whatever reason) with our attached container object.
		
		GTA Code:
		if (!isLineOfSightClear(vecVehiclePosition, vecPedPosition, true, false, false, true, false, false)) // Checks the line of sight for buildings and objects
			WarpPedToClosestPathNode(pPed, posZ, pVehicle, 1.0f);
			
		Address (gta_sa.exe): 0x647CD6
		NOTE: Nopping the jnz at 0x647CE0 fixes the problem, but disables this mechanism entirely
		==> Lua Fix: Let's teleport the player back
	]]
	
	addEventHandler("onClientPlayerVehicleExit", localPlayer,
		function(vehicle, seat)
			-- Enable the fix for the DFT-30 (if objects are attached)
			if getElementModel(vehicle) == 578 and #getAttachedElements(vehicle) > 0 then
				local x, y, z = getPositionFromElementOffset(vehicle, -2.15 * (seat == 0 and 1 or -1), 3.6, -0.63)
				setElementPosition(localPlayer, x, y, z)
			end
		end
	)
end
