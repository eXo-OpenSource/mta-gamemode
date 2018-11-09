-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ArmsDealerGUI.lua
-- *  PURPOSE:     Arrest GUI class
-- *
-- ****************************************************************************
ArmsDealerGUI = inherit(GUIForm)
inherit(Singleton, ArmsDealerGUI)

function ArmsDealerGUI:constructor(title, col, callback)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 25)
	self.m_Height = grid("y", 10)
	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Waffenhandel", true, true, self)
	self.m_Window:deleteOnClose(true)

	self.m_ShopChanger = GUIGridChanger:new(1, 2, 15, 1, self.m_Window)

	self.m_InfoLabel = GUIGridLabel:new(1, 1, 16, 1, "Es wurden 0 Performance-Tunings gefunden für 0 Modelle!", self.m_Window)
	self.m_NameSearch = GUIGridEdit:new(1, 2, 11, 1, self.m_Window):setCaption("Vorlage-Name")
	self.m_NameSearch.onChange = function () self:onSearch() end

	self.m_ModelSearch = GUIGridEdit:new(12, 2, 2, 1, self.m_Window):setCaption("Modell"):setNumeric(true)
	self.m_ModelSearch.onChange = function () self:onSearch() end
	
	self.m_SearchButton = GUIGridIconButton:new(14, 2, FontAwesomeSymbols.Search, self.m_Window):setTooltip("Nach Vorlage anhand von Modell & Name suchen!", "top")
	self.m_RefreshButton = GUIGridIconButton:new(15, 2, FontAwesomeSymbols.Refresh, self.m_Window):setTooltip("Vorlagen manuell vom Server aktualisieren!", "top")
	self.m_SearchButton.onLeftClick = function () self:onSearch() end
	self.m_RefreshButton.onLeftClick = function() self:refresh() end

	self.m_TemplateGrid = GUIGridGridList:new(1, 3, 15, 7, self.m_Window)
	self.m_TemplateGrid:addColumn(_"Waffen", 0.7)
	self.m_TemplateGrid:addColumn(_"Preis", 0.3)

	GUIGridRectangle:new(1, 10, 11, 1, Color.Grey, self.m_Window)
	self.m_TemplateInfoLabel = GUIGridLabel:new(1, 10, 11, 1, "Vorlage #", self.m_Window):setAlignX("center")


end

function ArmsDealerGUI:destructor() 

end