MapLoadGUI = inherit(GUIForm)
inherit(Singleton, MapLoadGUI)

function MapLoadGUI:constructor()

	self.m_MaxProgress = screenWidth*.4
	self.m_ProgressValue = 0
	self.m_ProgressVisual = 0

	GUIForm.constructor(self, 0, 0, screenWidth, screenHeight)
	
	GUIRectangle:new(0, 0, screenWidth, screenHeight, Color.Black, self)
	self.m_Loading = LoadingCube:new(screenWidth/2 - screenWidth*.1, screenHeight/2 - screenWidth*.1, screenWidth*.2, screenWidth*.2, self)

	self.m_Text = GUILabel:new(screenWidth/2 - screenWidth*.2, screenHeight/2+screenWidth*.15+screenHeight*.025, screenWidth*.4, screenHeight*.05, "Status", self):setAlignX("center"):setFont(VRPFont(40))
	
	self.m_ProgressBarBack = GUIRectangle:new((screenWidth/2 - screenWidth*.2) - 1, (screenHeight/2+screenWidth*.15) - 1, (screenWidth*.4) + 2, screenHeight*.025 + 2, Color.Grey, self)
	
	self.m_Progress = GUIRectangle:new((screenWidth/2 - screenWidth*.2), (screenHeight/2+screenWidth*.15), 0, screenHeight*.025, Color.LightBlue, self)
	fadeCamera(false)

	self.m_Render = bind(self.onFrame, self)
	addEventHandler("onClientRender", root, self.m_Render)
end

function MapLoadGUI:destructor() 
	GUIForm.destructor(self)
end

function MapLoadGUI:setProgress(prog) -- 0 to 1
	local width, height = self:getSize() 
	local currentProgress = width / self.m_MaxProgress
	local delta = (prog - currentProgress) 
	self.m_ProgressValue = prog 
end

function MapLoadGUI:onFrame() 
	self.m_ProgressVisual = self.m_ProgressVisual + self.m_MaxProgress*.05
	if self.m_ProgressVisual >  (self.m_MaxProgress * self.m_ProgressValue)  then 
		self.m_ProgressVisual =  (self.m_MaxProgress * self.m_ProgressValue) 
	end
	self.m_Progress:setSize(self.m_ProgressVisual, screenHeight*.025)
end


function MapLoadGUI:setStatus(text)
	self.m_Text:setText(text)
end

function MapLoadGUI:destructor() 
	self.m_Loading:delete()
	GUIForm.destructor(self) 
	removeEventHandler("onClientRender", root, self.m_Render)
	fadeCamera(true)
end