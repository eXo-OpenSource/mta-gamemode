-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/debug.lua
-- *  PURPOSE:     Debug stuff
-- *
-- ****************************************************************************
DEBUG = GIT_BRANCH ~= "release/production"

if triggerClientEvent then
	outputServerLog(("\n\nDebug information:\nDEBUG = %s\nBRANCH = %s\nVERSION = %s\n"):format(tostring(DEBUG), tostring(GIT_BRANCH), tostring(GIT_VERSION)))
end

--- Validates the parameters of a function
-- @param funcName The name of the function
-- @param ... The parameters' types
function checkArgs(funcName, ...)
	-- Ignore this in non-debug mode
	--[[
	if not DEBUG then
		return
	end

	local argTypes = {...}
	local isMethodCall = false

	for k, typeNames in ipairs(argTypes) do
		local paramName, paramValue = debug.getlocal(2, isMethodCall and k+1 or k)

		if paramName == "self" then
			isMethodCall = true
			paramName, paramValue = debug.getlocal(2, k+1)
		end

		if paramName == nil or paramValue == nil then
			outputDebugString(debug.traceback())
			if triggerServerEvent then -- Are we clientside?
				outputConsole(debug.traceback())
			end
			error("Invalid amount of arguments")
		end

		local validArguments = false
		local paramType = type(paramValue)

		if type(typeNames) == "table" then
			for k, v in ipairs(typeNames) do
				if paramType == v then
					validArguments = true
				end
			end
		else
			if paramType == typeNames then
				validArguments = true
			end
		end

		if not validArguments then
			-- ToDo: Fix this (stack level is different, because sometimes our calls go through the metatable stuff, sometimes not)
			--local debugInfo = debug.getinfo(3)
			local errorMsg = ("Bad argument #%d @ %s %s:%d %s expected, got %s"):format(k, funcName, debugInfo.short_src, debugInfo.currentline, typeName, type(paramValue))

			-- Temp fix: Print the whole stack traceback
			local errorMsg = debug.traceback().."\n      '"..paramName.."' got "..paramType..", expected "..tostring(typeNames)
			if outputServerLog then
				outputServerLog(errorMsg)
			else
				outputConsole(errorMsg)
				outputDebugString(errorMsg, 0)
			end
		end
	end
	]]
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

-- Hacked in from runcode
function runString(commandstring, source, suppress)
	local sourceName, output, outputPlayer
	if getPlayerName(source) ~= "Console" then
		sourceName = getPlayerName(source)
		output = function (msg)
			if not suppress then
				if SERVER then
					Admin:getSingleton():sendMessage(msg, 255, 51, 51)
				else
					outputChatBox(msg, 255, 51, 51)
				end
			end
		end
		outputPlayer = source
	else
		sourceName = "Console"
		output = function (msg)
			Admin:getSingleton():sendMessage(msg, 255, 51, 51)
		end
		outputPlayer = nil

	end
	output(sourceName.." executed command: "..commandstring, outputPlayer)
	local notReturned
	--First we test with return
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
			local resultType = type(results[i])
			if isElement(results[i]) then
				resultType = "element:"..getElementType(results[i])
			end
			resultsString = resultsString..tostring(results[i]).." ["..resultType.."]"
		end
		output("Command results: "..resultsString, outputPlayer)
	elseif not errorMsg then
		output("Command executed!", outputPlayer)
	end
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

function outputDebug(errmsg)
	if DEBUG then
		local className, methodName, currentline = getDebugInfo(3)
		 outputDebugString(("%s [%s:%s (%s)] %s"):format(SERVER and "SERVER" or "CLIENT", className, methodName, currentline, tostring(errmsg)), 3)
	end
end

LOREM_IPSUM = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
