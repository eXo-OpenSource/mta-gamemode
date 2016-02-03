-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Casino.lua
-- *  PURPOSE:     Casino singleton class
-- *
-- ****************************************************************************
Casino = inherit(Singleton)

function Casino:constructor()
	InteriorEnterExit:new(Vector3(1471.36, -1178.09, 23.92), Vector3(2233.99, 1714.685, 1012.38), 0, 0, 1)
	--Blip:new("Casino.png", 1471.36, -1178.09) -- Todo Add PNG

end
