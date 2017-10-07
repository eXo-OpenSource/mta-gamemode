-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
SkribbleGUI = inherit(GUIForm)
inherit(Singleton, SkribbleGUI)
addRemoteEvents{"skribbleSyncLobbyInfos", "skribbleShowInfoText", "skribbleChoosingWord"}

function SkribbleGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 25)
	self.m_Height = grid("y", 16)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"eXo Skribble", true, true, self)

	GUIGridRectangle:new(1, 1, 24, 1, Color.LightGrey, self.m_Window)
	GUIGridLabel:new(1, 1, 1, 1, FontAwesomeSymbols.Clock, self.m_Window):setFont(FontAwesome(30)):setFontSize(1):setAlignX("center")

	self.m_TimeRemain = GUIGridLabel:new(2, 1, 1, 1, "80", self.m_Window)
	self.m_RoundLabel = GUIGridLabel:new(1, 1, 5, 1, "", self.m_Window):setAlignX("right")
	self.m_GuessingWord = GUIGridLabel:new(10, 1, 10, 1, "", self.m_Window)

	self.m_PlayersGrid = GUIGridGridList:new(1, 2, 5, 14, self.m_Window)
	self.m_PlayersGrid:addColumn(_"Spieler", .6)
	self.m_PlayersGrid:addColumn(_"Punkte", .4)

	self.m_Skribble = GUIGridSkribble:new(6, 2, 19, 13, self.m_Window)

	self.m_Background = GUIGridRectangle:new(6, 2, 19, 13, Color.Clear, self.m_Window)
	self.m_InfoLabel = GUIGridLabel:new(6, 2, 19, 13, "", self.m_Window):setAlign("center", "center"):setFont(VRPFont(50)):setAlpha(0)

	self.m_ChangeColor = GUIGridIconButton:new(6, 15, FontAwesomeSymbols.Brush, self.m_Window)
	self.m_ChangeColor.onLeftClick = bind(SkribbleGUI.changeColor, self)

	local erase = GUIGridIconButton:new(7, 15, FontAwesomeSymbols.Erase, self.m_Window)
	erase.onLeftClick = function() self.m_Skribble:setDrawColor(Color.White) end

	local clearDraw = GUIGridIconButton:new(8, 15, FontAwesomeSymbols.Trash, self.m_Window)
	clearDraw.onLeftClick = function() if self.m_CurrentDrawing == localPlayer then self.m_Skribble:clear() end end

	-- About the slider range:
	-- GUISkribble draws a FontAwesome text/symbol
	-- The FontAwesome font height will devided by 2. dxCreateFont height ist limited to 5 - 150 (https://github.com/multitheftauto/mtasa-blue/blob/b2227c359092ce530cdf9727466b88bec8282cd0/Client/core/Graphics/CRenderItem.DxFont.cpp#L96)
	local slider = GUIGridSlider:new(20, 15, 5, 1, self.m_Window):setRange(10, 300)
	slider.onUpdate = function(size) self.m_Skribble:setDrawSize(size) end
end

function SkribbleGUI:virtual_destructor()
	triggerServerEvent("skribbleLeaveLobby", localPlayer)
end

function SkribbleGUI:showInfoText(text)
	if not text then self:hideInfoText() return end
	self.m_InfoLabel:setText(text)

	local backgroundAlpha = self.m_Background:getAlpha()
	if backgroundAlpha ~= 200 then
		Animation.FadeAlpha:new(self.m_Background, 250, backgroundAlpha, 200)
	end

	local posX, posY = self.m_InfoLabel:getPosition()
	self.m_InfoLabel:setPosition(posX, -posY)
	Animation.Move:new(self.m_InfoLabel, 250, posX, posY, "OutQuad")
	Animation.FadeAlpha:new(self.m_InfoLabel, 250, 0, 255)
end

function SkribbleGUI:hideInfoText()
	if self.m_InfoLabel:getText() == "" then return end

	Animation.FadeAlpha:new(self.m_Background, 250, 200, 0)
	Animation.FadeAlpha:new(self.m_InfoLabel, 250, 255, 0).onFinish =
		function()
			self.m_InfoLabel:setText("")
		end
end

function SkribbleGUI:updateInfos(players, currentDrawing, currentRound, rounds)
	self.m_PlayersGrid:clear()
	for player, data in pairs(players) do
		self.m_PlayersGrid:addItem(player:getName(), data.points)
	end

	self.m_CurrentDrawing = currentDrawing
	self.m_RoundLabel:setText(("Runde %s von %s"):format(currentRound, rounds))
end

function SkribbleGUI:choosingWord(words)
	self:showInfoText("Wähle ein Wort aus ...\n\n\n\n")

	self.m_WordButtons = {}
	for key, word in pairs(words) do
		local posX, posY = self.m_Skribble:getPosition()
		local width, height = self.m_Skribble:getSize()

		self.m_WordButtons[key] = GUIButton:new(posX + width/2 - 125, (posY+height/2) + 55*(key-2), 250, 50, word[1], self.m_Window):setBarEnabled(false):setAlpha(0)
		Animation.FadeAlpha:new(self.m_WordButtons[key], 500*key, 0, 255)

		self.m_WordButtons[key].onLeftClick =
			function()
				triggerServerEvent("skribbleChoosedWord", localPlayer, key)
			end
	end
end

function SkribbleGUI:changeColor()
	ColorPicker:new(
		function(r, g, b)
			self.m_ChangeColor:setBackgroundColor(tocolor(r, g, b))
			self.m_Skribble:setDrawColor(tocolor(r, g, b))
		end,
		function(r, g, b)
			self.m_ChangeColor:setBackgroundColor(tocolor(r, g, b))
		end
	)
end

addEventHandler("skribbleSyncLobbyInfos", root,
	function(...)
		if not SkribbleGUI:isInstantiated() then
			SkribbleGUI:new(...)
		end

		SkribbleGUI:getSingleton():updateInfos(...)
	end
)

addEventHandler("skribbleShowInfoText", root,
	function(...)
		if SkribbleGUI:isInstantiated() then
			SkribbleGUI:getSingleton():showInfoText(...)
		end
	end
)

addEventHandler("skribbleChoosingWord", root,
	function(words)
		if SkribbleGUI:isInstantiated() then
			SkribbleGUI:getSingleton():choosingWord(words)
		end
	end
)

--[[function SkribbleGUI:setHost()
	self.m_Timer = setTimer(function()
		self.m_Skribble:setDrawingEnabled(true)
		local syncData = self.m_Skribble:getSyncData(true)
		if #syncData > 0 then
			triggerServerEvent("onSyncSkribbleData", localPlayer, syncData)
		end
	end, 100, 0)
end]]

--[[addEvent("sendSkribbleData", true)
addEventHandler("sendSkribbleData", root,
	function(data)
		if not SkribbleGUI:isInstantiated() then
			SkribbleGUI:new()
		end

		SkribbleGUI:getSingleton().m_Skribble:drawSyncData(data)
	end
)
]]
