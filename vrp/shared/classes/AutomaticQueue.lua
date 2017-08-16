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
	assert(object.trigger, "No trigger method found!")
	Queue.push(self, object)
end

function AutomaticQueue:start(priority, async)
	local handle = bind(AutomaticQueue.perform, self)
	if async then
		return Async.create(handle)
	end

	local thread = Thread:new(handle, priority or THREAD_PRIORITY_HIGH)
	return thread.start
end

function AutomaticQueue:perform()
	while (not self:empty()) do
		self:pop():trigger()
	end
end
