Action = inherit(Object)

function Action.create(data, scene)
	local type = split(data.action, ".")[1]
	local action = split(data.action, ".")[2]
	
	assert(Action[type], "Invalid Type")
	assert(Action[type][action], "Invalid Action")
	
	local action = Action[type][action]:new(data, scene)
	action.type = data.type
	action.action = data.action
	action.starttick = data.starttick
	action.duration = data.duration
	if data.duration then
		action.stoptick = data.starttick + data.duration
	else
		action.stoptick = data.stoptick
	end
	return action
end