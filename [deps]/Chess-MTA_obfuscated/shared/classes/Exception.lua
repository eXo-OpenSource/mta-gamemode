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
	local catchFunc = t[2]
	local info = {tryFunc, catchFunc}
	
	Exception.Stack:push(info)
	
	pcall(tryFunc)
end

function catch(t)
	return t[1]
end

function throw(exception)
	local exInfo = Exception.Stack:pop()
	
	-- Call catch handler and pass our exception
	error(exInfo[2](exception)())
	return exInfo[2](exception)
end

-- Test
print("Main:Enter")
try
{
	function()
		print("Try1:Enter")
		
		try
		{
			function()
				print("Try2:Enter")
				throw(Exception:new("InvalidFunctionException2"))
			end;
			catch
			{	function()
				print("Try2:Caught")
				end
			};
		}
		
		throw(Exception:new("InvalidFunctionException"))
		print("Try2:Exit")
	end;
	catch
	{	function(e)
		print("Try1:Caught")
		end
	}
}
print("Main:Exit")
