CompanyInfoGUI = inherit(GUIForm)

function CompanyInfoGUI:constructor(Id)
  self.m_Company = CompanyManager:getSingleton():getFromId(Id)
  GUIForm.constructor(self, screenWidth/2 - screenWidth*0.35/2, screenHeight/2 - screenHeight*0.45/2, screenWidth*0.35, screenHeight*0.45)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Company", true, true, self)
end
