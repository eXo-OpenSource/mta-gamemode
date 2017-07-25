-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/HistoryPlayerGUI.lua
-- *  PURPOSE:     Player History GUI class
-- *
-- ****************************************************************************
HistoryPlayerGUI = inherit(GUIForm)

function HistoryPlayerGUI:constructor(gui)
	GUIForm.constructor(self, screenWidth/2-600/2, screenHeight/2-410/2, 600, 410)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Spielerakte", true, true, self)

	if gui then
		self.m_BackButton = GUIButton:new(self.m_Width-60, 0, 30, 30, FontAwesomeSymbols.Left, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.LightBlue):setHoverColor(Color.White):setFontSize(1)
		self.m_BackButton.onLeftClick = function() self:close() gui:getSingleton():show() Cursor:show() end
	end

	GUILabel:new(10, 35, 200, 20, "Suche:", self.m_Window)
	self.m_SeachText = GUIEdit:new(10, 55, 170, 30, self.m_Window)
	self.m_SeachButton = GUIButton:new(180, 55, 30, 30, FontAwesomeSymbols.Search, self.m_Window):setFont(FontAwesome(15))
	self.m_SeachButton.onLeftClick = function ()
		if #self.m_SeachText:getText() >= 3 then
			triggerServerEvent("historySearchPlayer", localPlayer, self.m_SeachText:getText())
		else
			ErrorBox:new(_"Bitte gib mindestens 3 Zeichen ein!")
		end
	end

	self.m_PlayersGrid = GUIGridList:new(10, 95, 200, 300, self.m_Window)
	self.m_PlayersGrid:addColumn(_"Spieler", 1)

	self.m_PlayerHistory = GUIGridList:new(220, 55, 370, 340, self.m_Window)
	self.m_PlayerHistory:addColumn(_"Name", 0.48)
	self.m_PlayerHistory:addColumn(_"Beitritt", 0.26)
	self.m_PlayerHistory:addColumn(_"Austritt", 0.26)

	addRemoteEvents{"historyReceiveSearchedPlayers", "historyPlayerReceived"}
	addEventHandler("historyReceiveSearchedPlayers", root, bind(self.Event_ReceiveSearchedPlayers, self))
	addEventHandler("historyPlayerReceived", root, bind(self.Event_OnPlayerHistoryReceived, self))
end

function HistoryPlayerGUI:Event_ReceiveSearchedPlayers(resultPlayers)
	self.m_PlayersGrid:clear()
	for index, pname in pairs(resultPlayers) do
		local item = self.m_PlayersGrid:addItem(pname)
		item.name = pname
		item.onLeftClick = function ()
			self:Event_OnPlayerHistoryReceived() -- Reset
			triggerServerEvent("historyPlayerRequest", root, index, pname)
		end
	end
end

function HistoryPlayerGUI:Event_OnPlayerHistoryReceived(infos)
	self.m_PlayerHistory:clear()
	if not infos then return end
	
	for index, info in pairs(infos) do
		local item = self.m_PlayerHistory:addItem(info.ElementName, info.JoinDate, info.LeaveDate)
		item.onLeftClick = function ()
			local text = (info.ElementType == "faction" and "Fraktion" or  "Unternehmen") ..": " .. info.ElementName .. "\n"
			text = text .. "Beitritt: " .. info.JoinDate .. "\n"
			text = text .. "Invited von: " .. info.Inviter .. "\n"
			text = text .."Austritt: " .. info.LeaveDate .. "\n"
			text = text .. "Uninvited von: " .. info.Uninviter .. "\n"
			text = text .."Extener Grund: " .. info.ExternalReason

			if info.InternalReason then
				text = text .. "\n" .. "Interner Grund: " .. info.InternalReason
			end

			ShortMessage:new(text, "Spielerakte")
		end
	end
end

function HistoryPlayerGUI:destructor()
	GUIForm.destructor(self)
end