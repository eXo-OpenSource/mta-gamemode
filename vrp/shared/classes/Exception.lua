-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/Exception.lua
-- *  PURPOSE:     Exception utility class (EXPERIMENTAL AND NOT INTENDED FOR PRODUCTIVE USE ATM)
-- *
-- ****************************************************************************
Exception = inherit(Object)
Exception.Stack = Stack:new()

function Exception:constructor(message, code)
	self.m_Message = message
	self.m_Code = code
end

function Exception:getMessage()
	return self.m_Message
end

function Exception:getCode()
	return self.m_Code
end

function try(t)
	local tryFunc = t[1]
	local catchFunc = t[2]()
	local info = {tryFunc, catchFunc}
	
	Exception.Stack:push(info)
end

function catch(t)
	return t[1]
end

function throw(exception)
	local exInfo = Exception.Stack:pop()
	
	-- Call catch handler and pass our exception
	return exInfo[2](exception)
end

-- Test
try
{
	function()
		throw(Exception:new("Bla"))
	end;
	catch
	{
		function(e) outputDebugString(e.getMessage()..debug.traceback()) end
	}
}
