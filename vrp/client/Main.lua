-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/Main.lua
-- *  PURPOSE:     Entry script
-- *
-- *****************************************************************************
_setTimer = setTimer
bindTable = {}
timerTable = {}

function setTimer(...)
	local func = unpack(arg)
	if func and type(func) == "function" then 	
		local timer = _setTimer(unpack(arg))
		timerTable[timer] = debug.traceback()
		return timer
	end
end

function getTimerTrace(timer)
	return timerTable[timer] 
end


function printTimerTrace(timer)
	outputConsole("  ")
	outputConsole(">>> TRACE for Timer >>>")
	outputConsole(getTimerTrace(timer))
	outputConsole("<<<<<<<<<<<<<<<<<<<<<<<")
	outputConsole("  ")
end


Main = {}

function Main.resourceStart()
	-- Instantiate Core
	core = Core:new()
	
	setWorldSpecialPropertyEnabled("extraairresistance",false)
	setPlayerHudComponentVisible("all", false)
end
addEventHandler("onClientResourceStart", resourceRoot, Main.resourceStart, true, "high+99999")

function Main.resourceStop()
	-- Delete the core
	delete(core)
end
addEventHandler("onClientResourceStop", resourceRoot, Main.resourceStop, true, "low-999999")
