ShowLevel = inherit(DXElement)

level = 0
nextlevel = 0
restEXP = 0
neededEXP = 0


addEvent("setLevel", true)
addEventHandler("setLevel", getRootElement(), function(level_, restEXP_, neededEXP_)
	level = level_
	restEXP = restEXP_
	neededEXP = neededEXP_
	outputChatBox(level)
	outputChatBox(restEXP)
	outputChatBox(neededEXP)
end
)





screenW, screenH = guiGetScreenSize()

function ShowLevel:constructor()
	DXElement.constructor(self, 600, 40, 400, 20)
	
	self.m_WorldLeft = new(DXImage, "world.png", 510, 10, 80, 80)
	self.m_EXPLeiste = new(DXBox, self.m_X, self.m_Y, self.m_Width, self.m_Height)
	self.m_WorldRight = new(DXImage, "world.png", 1010, 10, 80, 80)
	self.m_Experience = new(DXLabel,restEXP.."/"..neededEXP, 600, 60, 1000, 90)
	self.m_LevelNow = new(DXLabel,level, 510, 10, 590, 90)
	nextlevel = level+1
	self.m_LevelNext = new(DXLabel,nextlevel, 1010, 10, 1090, 90)
	weite = self.m_Width/100
	weite1 = weite*(restEXP/100)
	self.m_EXPLeisteFill = new(DXBox, self.m_X, self.m_Y, weite1, self.m_Height)
	
	setTimer(function()
		self.m_Experience:setText("Hallo")
	end, 500, 0)
	
	-- Properties
		
		-- EXP Leiste
			self.m_EXPLeiste:setColor(2, 17, 39, 255)
			
			self.m_EXPLeisteFill:setColor(19, 64, 121, 255)
	
		-- Experience
			self.m_Experience:setFont(gtaonlinefont[15])
			self.m_Experience:setColor(0, 0, 0, 255)
			self.m_Experience:setAlignX("center")
			self.m_Experience:setAlignY("center")
			
		-- Level Now
			self.m_LevelNow:setFont(gtaonlinefont[50])
			self.m_LevelNow:setColor(255, 255, 255, 255)
			self.m_LevelNow:setAlignX("center")
			self.m_LevelNow:setAlignY("center")
			
		-- Level Next
			self.m_LevelNext:setFont(gtaonlinefont[50])
			self.m_LevelNext:setColor(255, 255, 255, 255)
			self.m_LevelNext:setAlignX("center")
			self.m_LevelNext:setAlignY("center")
	-- Properties
end