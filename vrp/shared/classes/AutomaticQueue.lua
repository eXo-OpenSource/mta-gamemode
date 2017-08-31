-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/AutomaticQueue.lua
-- *  PURPOSE:     Automatic running Queue's for Objects
-- *
-- ****************************************************************************
AutomaticQueue = inherit(Queue)

function AutomaticQueue:constructor()
	Queue.constructor(self)
end

function AutomaticQueue:destructor()
	Queue.destructor(self)
end

function AutomaticQueue:push(object)
	assert(object.trigger, "Non supported object")
	Queue.push(self, object)
end

function AutomaticQueue:prepare(priority, async)
	local handle = bind(AutomaticQueue.run, self)
	if async then
		self.m_Async = true
		return Async.create(handle)
	end

	local thread = Thread:new(handle, priority or THREAD_PRIORITY_HIGH)
	return function(...) return thread:start(...) end
end

function AutomaticQueue:run()
	while (not self:empty()) do
		self:pop():trigger()
		if not self.m_Async then
			Thread.pause()
		end
	end
	self:clear()
end
