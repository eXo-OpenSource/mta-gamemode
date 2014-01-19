-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/debug.lua
-- *  PURPOSE:     Debug stuff
-- *
-- ****************************************************************************

DEBUG = true
GUI_DEBUG = false
addCommandHandler("gui_debug", function() GUI_DEBUG = not GUI_DEBUG end)

--- Validates the parameters of a function
-- @param funcName The name of the function
-- @param ... The parameters' types
function checkArgs(funcName, ...)
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
			--[[local debugInfo = debug.getinfo(3)
			local errorMsg = ("Bad argument #%d @ %s %s:%d %s expected, got %s"):format(k, funcName, debugInfo.short_src, debugInfo.currentline, typeName, type(paramValue))]]
			
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
end

function outputTable(tab)
	if DEBUG then
		outputDebugString("Begin: "..tostring(tab))
		for k, v in pairs(tab) do
			outputDebugString("key = "..tostring(k)..", value = "..tostring(v))
		end
		outputDebugString("End")
	end
end

-- Hacked in from runcode
function runString (commandstring, outputTo, source)
	local sourceName
	if source then
		sourceName = getPlayerName(source)
	else
		sourceName = "Console"
	end
	outputChatBox(sourceName.." executed command: "..commandstring)
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
		outputChatBox("Error: "..errorMsg)
		return
	end
	--Finally, lets execute our function
	results = { pcall(commandFunction) }
	if not results[1] then
		--It failed.
		outputChatBox("Error: "..results[2])
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
		outputChatBox("Command results: "..resultsString)
	elseif not errorMsg then
		outputChatBox("Command executed!")
	end
end

function outputDebug(errmsg)
	if DEBUG then
		outputDebugString((triggerServerEvent and "CLIENT " or "SERVER ")..tostring(errmsg))
	end
end

LOREM_IPSUM = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
