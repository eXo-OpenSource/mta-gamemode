-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIElements/KarmaBar.lua
-- *  PURPOSE:     Special progressbar which supports positive as well as negative values
-- *
-- ****************************************************************************
KarmaBar = inherit(Singleton)
inherit(DxElement, KarmaBar)

function KarmaBar:constructor()
	GUIElement.constructor(self, screenWidth/2-(screenWidth*0.31)/2 / ASPECT_RATIO_MULTIPLIER, screenHeight*0.01, screenWidth*0.31 / ASPECT_RATIO_MULTIPLIER, screenHeight*0.03)
	
	self:setVisible(false)
end

function KarmaBar:drawThis()
	local progress = localPlayer:getKarma()
	dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, "files/images/Bar_hover.png")
	dxDrawImageSection(self.m_AbsoluteX+self.m_Width/2, self.m_AbsoluteY, progress/100*self.m_Width/2, self.m_Height, 250, 0, progress/100*500/2, 25, "files/images/Bar.png")
end
