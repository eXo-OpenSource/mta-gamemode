-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/CharmaBar.lua
-- *  PURPOSE:     Special progressbar which supports positive as well as negative values
-- *
-- ****************************************************************************
VRPCharmaBar = inherit(DxElement)

function VRPCharmaBar:constructor()
	GUIElement.constructor(self, screenWidth/2-(screenWidth*0.31)/2 / ASPECT_RATIO_MULTIPLIER, screenHeight*0.01, screenWidth*0.31 / ASPECT_RATIO_MULTIPLIER, screenHeight*0.03)
	
	self.m_Progress = 0
end

function VRPCharmaBar:setProgress(progress)
	assert(progress >= -100 and progress <= 100)
	self.m_Progress = progress
	self:anyChange()
end

function VRPCharmaBar:getProgress()
	return self.m_Progress
end

function VRPCharmaBar:drawThis()
	dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, "files/images/Bar_hover.png")
	dxDrawImageSection(self.m_AbsoluteX+self.m_Width/2, self.m_AbsoluteY, self.m_Progress/100*self.m_Width/2, self.m_Height, 250, 0, self.m_Progress/100*500/2, 25, "files/images/Bar.png")
end
