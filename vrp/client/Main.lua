_setTimer = setTimer
bindTable = {}
timerTable = {}
lastCall = getTickCount()
spamTimerTable = {}
TIMER_SPAM_TIME = 200
function setTimer(...)
	if lastCall + TIMER_SPAM_TIME > getTickCount() then 
		local traceback = debug.traceback()
		local hash = md5(traceback)
		spamTimerTable[hash] = traceback
	end
	lastCall = getTickCount();
	local func = unpack(arg)
	if func and type(func) == "function" then 	
		local timer = _setTimer(unpack(arg))
		timerTable[timer] = func
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
