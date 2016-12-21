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

function BarManageGUI:constructor(barId, name, ownerId, ownerName, price, streamUrl)
	GUIButtonMenu.constructor(self, "Bar: "..name)

	self.m_BarId = barId
	self.m_OwnerId = ownerId
	self.m_OwnerName = ownerName
	self.m_Stream = streamUrl
	self.m_Price = price

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
	end
	if self.m_OwnerId == localPlayer:getGroupId() then
		self:addItem(_"Bar verkaufen", Color.Red, bind(self.itemCallback, self, 3))
		self:addItem(_"Musik verwalten", Color.Green, bind(self.itemCallback, self, 1))
	end
	self:addItem(_"Schließen", Color.Red, bind(self.itemCallback, self))
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
		function(barId, name, ownerId, ownerName, price, streamUrl)
			BarManageGUI:new(barId, name, ownerId, ownerName, price, streamUrl)
		end
	)

