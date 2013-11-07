-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        shared/classes/Object.lua
-- *  PURPOSE:     Base class of everything
-- *
-- ****************************************************************************
Object = {}

function Object:new(...)
	return new(self, ...)
end

function Object:delete(...)
	return delete(self, ...)
end

function Object:load(...)
	return load(self, ...)
end

function Object:getId()
	return self.m_Id
end

--[[
	Possible signatures:
		- Object:rpc(RPC, ...)
		- Object:rpc([sendTo = root], RPC, ...) (server-only)
--]]
function Object:rpc(arg1, arg2, ...)
	local args = {...}
	local sendTo = root
	local rpc
	
	if type(arg1) == "userdata" then
		sendTo = arg1
		rpc = arg2
	else
		rpc = arg1
		table.insert(args, 1, arg2)
	end
	
	if self.m_Id or isElement(self) then
		if triggerServerEvent then
			return triggerServerEvent("onRPC", resourceRoot, rpc, self.m_Id or self, unpack(args))
		else
			return triggerClientEvent(sendTo, "onRPC", resourceRoot, rpc, self.m_Id or self, unpack(args))
		end
	end
	
	error("RPC on non-existing counterside element called")
end
