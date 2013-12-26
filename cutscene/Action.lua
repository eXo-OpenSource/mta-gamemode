Action = inherit(Object)

function Action.create(data)
	local type = data.type
	local action = data.action
	assert(Action[type], "Invalid Type")
	assert(Action[type][action], "Invalid Action")
	
	local action = Action[type][action]:new(data)
	action.type = data.type
	action.action = data.action
	action.starttick = data.starttick
	action.duration = data.duration
	if data.duration then
		action.stoptick = data.starttick + data.duration
	end
	return action
end