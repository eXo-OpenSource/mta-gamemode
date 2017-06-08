-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/Main.lua
-- *  PURPOSE:     Entry script
-- *
-- *****************************************************************************
Main = {}

function Main.resourceStart()
	-- Instantiate Core
	core = Core:new()
	
	setWorldSpecialPropertyEnabled("extraairresistance",false)
end
addEventHandler("onClientResourceStart", resourceRoot, Main.resourceStart, true, "high+99999")

function Main.resourceStop()
	-- Delete the core
	delete(core)
end
addEventHandler("onClientResourceStop", resourceRoot, Main.resourceStop, true, "low-999999")
