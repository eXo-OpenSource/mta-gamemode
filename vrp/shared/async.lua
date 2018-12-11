-- ****************************************************************************
-- *
-- *  PROJECT:     	vRoleplay
-- *  FILE:        	shared/Async.lua
-- *  PURPOSE:     	Helper library for asyncronous data processing
-- *
-- ****************************************************************************
Async = { id = false; threads = {}}

function Async.create(func)
	local t = setmetatable({}, { __index = Async, __call = Async.__call })

	t:constructor(func)
	return function(...) return t:continue(...) end
end

function Async.constructor(self, func)
	self.m_Fn = func
	self.m_Id = #Async.threads+1
	Async.threads[self.m_Id] = self
	self.m_IsRunning = false
end

function Async.__call(self, ...)
	self:continue(...)
end

function Async.wait()
	Async.id = false
	coroutine.yield()
	return unpack(Async.threads[Async.id].m_Args)
end

function Async.waitFor(element)
	assert(Async.id, "Not within async execution, cannot wait")
	Async.threads[Async.id].m_Element = element
	local id = Async.id
	return function(...) return Async.continueAsync(id, ...) end
end

function Async.continueAsync(id, ...)
	return Async.threads[id]:continue(...)
end

function Async:continue(...)
	Async.id = self.m_Id

	if not self.m_Trace then
		self.m_Trace = {}
		local traceLevel = 1
		while true do
			if debug and type(debug) ~= "number" then -- debug changes to a number value when called between async calls / find out why
				local info = debug.getinfo(traceLevel, "Sl")
				if not info then break end
				if info.what ~= "C" and info.source then -- skip c functions as they don't have info
					if not info.source:find("classlib.lua") and not info.source:find("tail call") then -- skip tail calls and classlib traceback (e.g. pre-calling destructor) as it is useless for debugging
						table.insert(self.m_Trace, {info.source, info.currentline or "not specified"})
					end
				end
			end
			traceLevel = traceLevel + 1
		end
	end

	if not self.m_IsRunning then
		self.m_Coroutine = coroutine.create(self.m_Fn)
		self.m_IsRunning = true

		if coroutine.status(self.m_Coroutine) == "dead" then
			outputDebugString("Coroutine died: " .. inspect(self.m_Trace), 1)
		end

		assert(coroutine.resume(self.m_Coroutine, ...))
		return
	else
		self.m_Args = {...}
		if self.m_Element then
			if not self.m_Element then
				-- abandon the coroutine so the gc can clear it
				Async.threads[Async.id] = nil
				self.m_Coroutine  = nil
				return
			end
			self.m_Element = nil
		end
	end

	if coroutine.status(self.m_Coroutine) == "dead" then
		outputDebugString("Coroutine died: " .. inspect(self.m_Trace), 1)
	end

	assert(coroutine.resume(self.m_Coroutine))
end


function bindAsync(func, ...)
	return bind(function(...) Async.create(func)(...) end, ...)
end
