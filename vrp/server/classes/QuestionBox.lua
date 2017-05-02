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
	outputChatBox("initalize")
end

function QuestionBox:constructor(player, target, msg, yesEvent, noEvent, ...)
	local additionalParameters = {...}
	local id = QuestionBox.Count+1
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

function QuestionBox.Accept(id)
	if QuestionBox.Map[id]["target"] == client and QuestionBox.Map[id]["yesEvent"] then
		triggerEvent(QuestionBox.Map[id]["yesEvent"], client, unpack(QuestionBox.Map[id]["additionalParameters"]))
		delete(QuestionBox.Map[id]["object"])
	end
end

function QuestionBox.Discard(id)
	if QuestionBox.Map[id]["target"] == client and QuestionBox.Map[id]["noEvent"] then
		triggerEvent(QuestionBox.Map[id]["noEvent"], client, unpack(QuestionBox.Map[id]["additionalParameters"]))
		delete(QuestionBox.Map[id]["object"])
	end
end


