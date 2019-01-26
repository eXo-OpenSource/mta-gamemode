-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/QuestionBox.lua
-- *  PURPOSE:     ShortMessage box class
-- *
-- ****************************************************************************
ShortMessageQuestion = inherit(Object)
inherit(Singleton, ShortMessageQuestion)

addRemoteEvents{"questionShortMessage", "questionShortMessageClose"}

function ShortMessageQuestion:constructor(text, yesCallback, noCallback)
	self.m_Question = ShortMessage:new(("%s \n(Linksklick Ja, Rechtsklick Nein)"):format(text), "Frage", nil, -1)

	self.m_Question.onLeftClick = function() if yesCallback then yesCallback() end delete(self) end
	self.m_Question.onRightClick = function() if noCallback then noCallback() end delete(self) end
end

function ShortMessageQuestion:destructor()
	self.m_Question:delete()
end

addEventHandler("questionShortMessage", root,
	function(id, text)
		ShortMessageQuestion:new(text,
			function()
				triggerServerEvent("questionShortMessageAccept", root, id)
			end,
			function()
				triggerServerEvent("questionShortMessageDiscard", root, id)
			end
		)
	end
)

addEventHandler("questionShortMessageClose", root,
	function()
		delete(ShortMessageQuestion:getSingleton())
	end
)
