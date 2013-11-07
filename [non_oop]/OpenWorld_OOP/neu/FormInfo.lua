FormInfo = inherit(DXElement)

screenW, screenH = guiGetScreenSize()

function FormInfo:constructor(playerusername)
	showCursor(true)
	DXElement.constructor(self, (screenW - screenW) / 2, (screenH - screenH) / 2, screenW, screenH)
	self.m_Background = new(DXWindow, self.m_X, self.m_Y, self.m_Width, self.m_Height)
	self.m_LeisteOben = new(DXBox, 125, 37, 1350, 187)
	self.m_Servername = new(DXLabel,"GTA:SA Online", 148, 74, 387, 106)
	self.m_Avatar = new(DXImage, "avatar-default.png", 1380, 47, 85, 85)
	self.m_Nickname = new(DXLabel, playerusername, 1131, 47, 1370, 75)
	self.m_Status = new(DXLabel, "Inhaber", 1131, 75, 1370, 103)
	self.m_Geld = new(DXLabel, "BANK $10000    CASH $500", 1131, 103, 1370, 131)

	
	-- Properties
		-- Background
			self.m_Background:setColor(2, 17, 39, 255)
		
		-- Leiste Oben
			self.m_LeisteOben:setColor(0, 0, 0, 170)
	
		-- Servername
			self.m_Servername:setColor(255, 255, 255, 255)
			self.m_Servername:setFont(gtaonlinefont[30])
			self.m_Servername:setAlignX("left")
			self.m_Servername:setAlignY("top")
			
		-- Nickname
			self.m_Nickname:setFont(gtaonlinefont[12])
			self.m_Nickname:setAlignX("right")
			self.m_Nickname:setAlignY("center")
			
		-- Status
			self.m_Status:setFont(gtaonlinefont[12])
			self.m_Status:setAlignX("right")
			self.m_Status:setAlignY("center")
			
		-- Geld
			self.m_Geld:setFont(gtaonlinefont[12])
			self.m_Geld:setAlignX("right")
			self.m_Geld:setAlignY("center")
	-- Properties
end