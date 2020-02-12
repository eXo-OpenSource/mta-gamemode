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
	setPlayerHudComponentVisible("all", false)
end
addEventHandler("onClientResourceStart", resourceRoot, Main.resourceStart, true, "high+99999")

function Main.resourceStop()
	-- Delete the core
	delete(core)
end
addEventHandler("onClientResourceStop", resourceRoot, Main.resourceStop, true, "low-999999")

addEventHandler("onClientDebugMessage", root,
	function(msg, level, file, line)
		if GIT_BRANCH == "release/production" and level <= 2 then
			-- get trace back of type {filepath, line} (adapted from traceback())
			local sentryLevel = "debug"
			if level == 1 then sentryLevel = "error" elseif level == 2 then sentryLevel = "warning" end

			local trace = {}
			local traceLevel = 2
			table.insert(trace, {file, line or "not specified", nil})
			while true do
				local info = debug.getinfo(traceLevel, "Sl")
				if not info then break end
				if info.what ~= "C" and info.source then -- skip c functions as they don't have info
					if not info.source:find("classlib.lua") and not info.source:find("tail call") then -- skip tail calls and classlib traceback (e.g. pre-calling destructor) as it is useless for debugging
						if trace[1][1] ~= info.source:gsub("@", "") then -- for some reason messages get duplicated, but we need to collect the message from file, line as it skips it sometimes in traceback
							table.insert(trace, {info.source, info.currentline or "not specified", info.name})
						end
					end
				end
				traceLevel = traceLevel + 1
			end

			Sentry:getSingleton():handleException(msg, sentryLevel, trace)
		end
	end
)
