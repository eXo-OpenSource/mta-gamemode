-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ScoreGUI.lua
-- *  PURPOSE:     ScoreGUI
-- *
-- ****************************************************************************
ScoreGUI = inherit(GUIForm)
inherit(Singleton, ScoreGUI)

addRemoteEvents{"showScore", "hideScore"}

function ScoreGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-200/2, 10, 200, 60, false)
	GUIRectangle:new(0, 0, self.m_Width, self.m_Height, Color.Black, self)
	self.m_ScoreLabel= GUILabel:new(0, 10, self.m_Width, 40, "Score: 0", self):setAlignX("center"):setAlignY("center")

	addRemoteEvents{"setScore"}
	addEventHandler("setScore", root , bind(self.setScore, self))

end

function ScoreGUI:setScore(score)
	self.m_ScoreLabel:setText(_("Score: %d", score))
end

addEventHandler("showScore", root,
	function()
		ScoreGUI:new()
	end
)

addEventHandler("hideScore", root,
	function()
		ScoreGUI:getSingleton():delete()
	end
)
