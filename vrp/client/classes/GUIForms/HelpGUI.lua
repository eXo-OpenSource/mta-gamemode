-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/HelpGUI.lua
-- *  PURPOSE:     HelpGUI GUI
-- *
-- ****************************************************************************
HelpGUI = inherit(GUIForm)
inherit(Singleton, HelpGUI)

function HelpGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 28)
	self.m_Height = grid("y", 16)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)

	-- GUIForm.constructor(self, screenWidth/2 - screenWidth*0.5/2, screenHeight/2 - screenHeight*0.65/2, screenWidth*0.5, screenHeight*0.65)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Hilfe", true, true, self)
	-- "https://forum.exo-reallife.de/exo-api?token=%s"
	self.m_WebView = GUIGridWebView:new(1, 1, 27, 15, ("https://forum.exo-reallife.de/index.php?exo-api&token=%s"):format(localPlayer:getSessionId()), true, self.m_Window)

	--[[
	self.m_Grid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.25, self.m_Height*0.9, self.m_Window)
	self.m_Grid:addColumn("", 0.95)
	self.m_WebView = GUIWebView:new(self.m_Width*0.28, self.m_Height*0.08, self.m_Width*0.7, self.m_Height*0.9, "http://mta/local/files/html/help.htm", true, self.m_Window)
	-- self.m_ContentLabel = GUIScrollableText:new(self.m_Width*0.28, self.m_Height*0.08, self.m_Width*0.7, self.m_Height*0.9, "", self.m_Height*0.04, self.m_Window)

	self.m_Items = {}

	for index, data in pairs(Help:getSingleton():getText()) do
		self.m_Grid:addItemNoClick(data.category)

		for index, helpText in pairs(data.childs) do
			self.m_Items[helpText.title] = self.m_Grid:addItem("  "..helpText.title)
			self.m_Items[helpText.title].onLeftClick = function()
				if HUDUI:getSingleton().m_Visible then
					HUDUI:getSingleton():refreshHandler()
					HUDUI:setEnabled(false)
				end

				self.m_Window:setTitleBarText(helpText.title.." - Hilfe")
				self.m_WebView:callEvent("onTextChange", helpText.text)
				-- self.m_ContentLabel:setText(text)
			end
		end
	end

	self.m_WebView:setAjaxHandler(function(get)
		if get["method"] then
			if get["method"] == "gps" then
				GPS:getSingleton():startNavigationTo(Vector3(get["x"], get["y"], 0))
			end

			if get["method"] == "cutscene" then
				if localPlayer.vehicle then
					ErrorBox:new(_"Bitte erst aus dem Fahrzeug aussteigen!")
					return
				end

				CutscenePlayer:getSingleton():playCutscene(get["scene"],
					function()
						fadeCamera(true)
						setCameraTarget(localPlayer)
					end, 0)
				delete(self)
			end
		end
	end)

	self.m_WebView.onDocumentReady = function()
		local item = self.m_Grid:getItems()[2]
		self.m_Grid:onInternalSelectItem(item)
		item.onLeftClick()
	end
	]]
end

function HelpGUI:select(title)
	if self.m_Items[title] then
		self.m_Grid:onInternalSelectItem(self.m_Items[title])
		self.m_Items[title].onLeftClick()
	end
end

function HelpGUI:isBackgroundBlurred()
	return true
end
