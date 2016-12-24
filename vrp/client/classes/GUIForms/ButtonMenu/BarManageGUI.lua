-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/BarManageGUI.lua
-- *  PURPOSE:     BarManageGUI
-- *
-- ****************************************************************************
BarManageGUI = inherit(GUIButtonMenu)
inherit(Singleton, BarManageGUI)

addRemoteEvents{"barOpenManageGUI", "barCloseManageGUI", "updateBarManageGUI"}

function BarManageGUI:constructor(barId, name, ownerId, ownerName, price, streamUrl, stripper)
	GUIButtonMenu.constructor(self, "Bar: "..name)

	self.m_BarId = barId
	self.m_OwnerId = ownerId
	self.m_OwnerName = ownerName
	self.m_Stream = streamUrl
	self.m_Price = price
	self.m_Stripper = stripper

	-- Add the Items
	self:addItems()

	-- Events
	--addEventHandler("updateBarManageGUI", root, bind(self.Event_updateBarManageGUI, self))
	addEventHandler("barCloseManageGUI", root, bind(self.Event_close, self))
end

function BarManageGUI:addItems()
	self:addItemNoClick("Besitzer: "..self.m_OwnerName, Color.LightBlue)
	self:addItemNoClick("Wert: "..self.m_Price.."$", Color.White)
	if self.m_OwnerId == 0 then
		self:addItem(_"Bar kaufen", Color.Blue, bind(self.itemCallback, self, 2))
	else
		if self.m_OwnerId == localPlayer:getGroupId() then
			self:addItem(_"Bar verkaufen", Color.Red, bind(self.itemCallback, self, 3))
			self:addItem(_"Musik verwalten", Color.Green, bind(self.itemCallback, self, 1))
			self:addItem(_"Kasse verwalten", Color.Blue, bind(self.itemCallback, self, 4))
			if self.m_Stripper then
				self:addItem(_"Stripperinnen entlassen", Color.Red, bind(self.itemCallback, self, 6))
			else
				self:addItem(_"Stripperinnen engagieren", Color.Red, bind(self.itemCallback, self, 5))
			end
		end
	end
end

function BarManageGUI:itemCallback(type)
	if type == 1 then
		self.m_StreamGUI = StreamGUI:new("Bar Musik ändern",
		function(url)
			triggerServerEvent("barShopMusicChange", localPlayer, self.m_BarId , url)
		end,
		function()
			triggerServerEvent("barShopMusicStop", localPlayer, self.m_BarId )
		end,
		self.m_Stream
		)
	elseif type == 2 then
		QuestionBox:new(_("Möchtest du wirklich diese Bar für deine Firma um %d$ kaufen?", self.m_Price),
		function() 	triggerServerEvent("shopBuy", localPlayer, self.m_BarId) end
		)
	elseif type == 3 then
		QuestionBox:new(_("Möchtest du wirklich diese Bar deiner Firma um %d$ verkaufen?", math.floor(self.m_Price*0.75)),
		function() 	triggerServerEvent("shopSell", localPlayer, self.m_BarId) end
		)
	elseif type == 4 then
		triggerServerEvent("shopOpenBankGUI", localPlayer, self.m_BarId)
	elseif type == 5 then
		QuestionBox:new(_("Möchtest du wirklich Stripperinnen engagieren? (Kosten 15$ pro 15 Minuten!)"),
		function() 	triggerServerEvent("barShopStartStripper", localPlayer, self.m_BarId) end
		)
	elseif type == 6 then
		triggerServerEvent("barShopStopStripper", localPlayer, self.m_BarId)
	end
	delete(self)
end

function BarManageGUI:Event_close()
	if self.m_StreamGUI then
		delete(self.m_StreamGUI)
	end
	delete(self)
end

addEventHandler("barOpenManageGUI", root,
		function(barId, name, ownerId, ownerName, price, streamUrl, stripper)
			BarManageGUI:new(barId, name, ownerId, ownerName, price, streamUrl, stripper)
		end
	)

