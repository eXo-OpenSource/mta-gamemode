-- FILE: 	mapEditorScriptingExtension_c.lua
-- PURPOSE:	Prevent the map editor feature set being limited by what MTA can load from a map file by adding a script file to maps
-- VERSION:	RemoveWorldObjects (v1) AutoLOD (v1)

local function requestLODsClient()
	triggerServerEvent("requestLODsClient", resourceRoot)
	triggerServerEvent("requestBreakablesClient", resourceRoot)
end
addEventHandler("onClientResourceStart", resourceRoot, requestLODsClient)

local function setLODsClient(lodTbl)
	for i, model in pairs(lodTbl) do
		engineSetModelLODDistance(model, 300)
	end
end
addEvent("setLODsClient", true)
addEventHandler("setLODsClient", resourceRoot, setLODsClient)

local function setBreakablesClient(breakableTbl)
	for i, model in pairs(breakableTbl) do
		setObjectBreakable(model, false)
	end
end
addEvent("setBreakablesClient", true)
addEventHandler("setBreakablesClient", resourceRoot, setBreakablesClient)
