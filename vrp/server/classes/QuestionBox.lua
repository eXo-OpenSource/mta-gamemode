-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/QuestionBox.lua
-- *  PURPOSE:     Serverside QuestionBox class
-- *
-- ****************************************************************************
QuestionBox = inherit(Object)
QuestionBox.Map = {}
QuestionBox.Count = 0

function QuestionBox.initalize()
	addRemoteEvents{"questionBoxAccept", "questionBoxDiscard"}
	addEventHandler("questionBoxAccept", root, QuestionBox.Accept)
	addEventHandler("questionBoxDiscard", root, QuestionBox.Discard)
end

function QuestionBox:constructor(player, target, msg, yesEvent, noEvent, ...)
	local additionalParameters = {...}
	local id = QuestionBox.Count+1
	self.m_Id = id
	QuestionBox.Map[id] = {
		["player"] = player,
		["target"] = target,
		["yesEvent"] = yesEvent,
		["noEvent"] = noEvent,
		["additionalParameters"] = additionalParameters,
		["object"] = self
	}
	target:triggerEvent("questionBox", id, msg)
end

function QuestionBox:destructor()
	if QuestionBox.Map[self.m_Id] then
		QuestionBox.Map[self.m_Id] = nil
	end
end

function QuestionBox.Accept(id)
	if not QuestionBox.Map[id] then
		client:sendError(_("Die Anfrage ist abgelaufen und kann daher nicht mehr akzeptiert werden!", client))
		return
	end

	local yesEvent = QuestionBox.Map[id]["yesEvent"]
	if QuestionBox.Map[id]["target"] == client and yesEvent then
		if type(yesEvent) == "function" then
			yesEvent(unpack(QuestionBox.Map[id]["additionalParameters"]))
		else
			triggerEvent(QuestionBox.Map[id]["yesEvent"], client, unpack(QuestionBox.Map[id]["additionalParameters"]))
		end

		delete(QuestionBox.Map[id]["object"])
	end
end

function QuestionBox.Discard(id)
	if not QuestionBox.Map[id] then
		client:sendError(_("Die Anfrage ist abgelaufen und kann daher nicht mehr abgelehnt werden!", client))
		return
	end

	local noEvent = QuestionBox.Map[id]["noEvent"]
	if QuestionBox.Map[id]["target"] == client and noEvent then
		if type(noEvent) == "function" then
			noEvent(unpack(QuestionBox.Map[id]["additionalParameters"]))
		else
			triggerEvent(QuestionBox.Map[id]["noEvent"], client, unpack(QuestionBox.Map[id]["additionalParameters"]))
		end

		delete(QuestionBox.Map[id]["object"])
	end
end


