-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
SkribbleGUI = inherit(GUIForm)
inherit(Singleton, SkribbleGUI)
addRemoteEvents{"skribbleSyncLobbyInfos"}

function SkribbleGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 25)
	self.m_Height = grid("y", 16)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"eXo Skribble", true, true, self)

	GUIGridRectangle:new(1, 1, 24, 1, Color.LightGrey, self.m_Window)
	GUIGridLabel:new(1, 1, 1, 1, FontAwesomeSymbols.Clock, self.m_Window):setFont(FontAwesome(30)):setFontSize(1):setAlignX("center")

	self.m_TimeRemain = GUIGridLabel:new(2, 1, 1, 1, "80", self.m_Window)
	self.m_RoundLabel = GUIGridLabel:new(1, 1, 5, 1, "Runde 1 von 5", self.m_Window):setAlignX("right")
	self.m_GuessingWord = GUIGridLabel:new(10, 1, 10, 1, "_ _ _ _ _ _ _ _ _", self.m_Window)

	self.m_PlayersGrid = GUIGridGridList:new(1, 2, 5, 14, self.m_Window)
	self.m_PlayersGrid:addColumn(_"Spieler", .6)
	self.m_PlayersGrid:addColumn(_"Punkte", .4)

	self.m_Skribble = GUIGridSkribble:new(6, 2, 19, 13, self.m_Window)

	self.m_Background = GUIGridRectangle:new(6, 2, 19, 13, Color.Clear, self.m_Window)
	self.m_InfoLabel = GUIGridLabel:new(6, 2, 19, 13, "", self.m_Window):setAlign("center", "center")

	self.m_ChangeColor = GUIGridIconButton:new(6, 15, FontAwesomeSymbols.Brush, self.m_Window)
	self.m_ChangeColor.onLeftClick = bind(SkribbleGUI.changeColor, self)

	local erase = GUIGridIconButton:new(7, 15, FontAwesomeSymbols.Erase, self.m_Window)
	erase.onLeftClick = function() self.m_Skribble:setDrawColor(Color.White) end

	local clearDraw = GUIGridIconButton:new(8, 15, FontAwesomeSymbols.Trash, self.m_Window)
	clearDraw.onLeftClick = function() self.m_Skribble:clear() end

	-- About the slider range:
	-- GUISkribble draws a FontAwesome text/symbol
	-- The FontAwesome font height will devided by 2. dxCreateFont height ist limited to 5 - 150 (https://github.com/multitheftauto/mtasa-blue/blob/b2227c359092ce530cdf9727466b88bec8282cd0/Client/core/Graphics/CRenderItem.DxFont.cpp#L96)
	local slider = GUIGridSlider:new(20, 15, 5, 1, self.m_Window):setRange(10, 300)
	slider.onUpdate = function(size) self.m_Skribble:setDrawSize(size) end
end

function SkribbleGUI:virtual_destructor()
	triggerServerEvent("skribbleLeaveLobby", localPlayer)
end

function SkribbleGUI:updateInfos(players, currentDrawing, currentRound, state)
	self.m_PlayersGrid:clear()
	for player, data in pairs(players) do
		self.m_PlayersGrid:addItem(player:getName(), data.points)
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
