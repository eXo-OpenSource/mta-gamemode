FormInfo = inherit(DXElement)

function FormInfo:constructor()
	DXElement.constructor(self, (screenW - screenW) / 2, (screenH - screenH) / 2, screenW, screenH)
	self.m_Background = GUIWindow:new(self.m_X, self.m_Y, self.m_Width, self.m_Height)
	self.m_LeisteOben = GUIWindow:new(125, 37, 1350, 187)
	self.m_Servername = GUILabel:new("GTA:SA ONLINE", 148, 74, 387, 106)
	
	-- Properties
	self.m_Background:setColor(255, 0, 0, 255)
	
	self.m_LeisteOben:setColor(0, 0, 0, 170)
	
	self.m_Servername:setColor(255, 255, 255, 255)
	self.m_Servername:setFont("arial")
	self.m_Servername:setAlignX("left")
	self.m_Servername:setAlignY("top")
end