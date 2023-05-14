-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/QuestionBox.lua
-- *  PURPOSE:     Serverside QuestionBox class
-- *
-- ****************************************************************************
ShortMessageQuestion = inherit(Object)
ShortMessageQuestion.Map = {}
ShortMessageQuestion.Count = 0

function ShortMessageQuestion.initalize()
	addRemoteEvents{"questionShortMessageAccept", "questionShortMessageDiscard"}
	addEventHandler("questionShortMessageAccept", root, ShortMessageQuestion.Accept)
	addEventHandler("questionShortMessageDiscard", root, ShortMessageQuestion.Discard)
end

function ShortMessageQuestion:constructor(player, target, msg, yesEvent, noEvent, color, ...)
	local additionalParameters = {...}
	local id = ShortMessageQuestion.Count+1
	self.m_Id = id
	ShortMessageQuestion.Map[id] = {
		["player"] = player,
		["target"] = target,
		["yesEvent"] = yesEvent,
		["noEvent"] = noEvent,
		["additionalParameters"] = additionalParameters,
		["object"] = self
	}
	target:triggerEvent("questionShortMessage", id, msg, color)
end

function ShortMessageQuestion:destructor()
	if ShortMessageQuestion.Map[self.m_Id] then
		ShortMessageQuestion.Map[self.m_Id] = nil
	end
end

function ShortMessageQuestion.Accept(id)
	if not ShortMessageQuestion.Map[id] then
		client:sendError(_("Die Anfrage ist abgelaufen und kann daher nicht mehr akzeptiert werden!", client))
		return
	end

	local yesEvent = ShortMessageQuestion.Map[id]["yesEvent"]
	if ShortMessageQuestion.Map[id]["target"] == client and yesEvent then
		if type(yesEvent) == "function" then
			yesEvent(unpack(ShortMessageQuestion.Map[id]["additionalParameters"]))
		else
			triggerEvent(ShortMessageQuestion.Map[id]["yesEvent"], client, unpack(ShortMessageQuestion.Map[id]["additionalParameters"]))
		end

		delete(ShortMessageQuestion.Map[id]["object"])
	end
end

function ShortMessageQuestion.Discard(id)
	if not ShortMessageQuestion.Map[id] then
		client:sendError(_("Die Anfrage ist abgelaufen und kann daher nicht mehr abgelehnt werden!", client))
		return
	end

	local noEvent = ShortMessageQuestion.Map[id]["noEvent"]
	if ShortMessageQuestion.Map[id]["target"] == client and noEvent then
		if type(noEvent) == "function" then
			noEvent(unpack(ShortMessageQuestion.Map[id]["additionalParameters"]))
		else
			triggerEvent(ShortMessageQuestion.Map[id]["noEvent"], client, unpack(ShortMessageQuestion.Map[id]["additionalParameters"]))
		end

		delete(ShortMessageQuestion.Map[id]["object"])
	end
end


