-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIProgressBar.lua
-- *  PURPOSE:     GUI ProgressBar class
-- *
-- ****************************************************************************
GUIProgressBar = inherit(GUIElement)

function GUIProgressBar:constructor(posX, posY, width, height, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)
	
	self.m_Progress = 0
end

function GUIProgressBar:setProgress(progress)
	assert(progress >= 0 and progress <= 100, "Invalid range passed to GUIProgressbar.setProgress")
	
	self.m_Progress = progress
	self:anyChange()
end

function GUIProgressBar:getProgress()
	return self.m_Progress
end

function GUIProgressBar:drawThis()
	dxSetBlendMode("modulate_add")
	
	-- Draw background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, Color.DarkBlue)
	
	-- Draw actual progress bar
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width * self.m_Progress/100, self.m_Height, Color.White)
	
	dxSetBlendMode("blend")
end
