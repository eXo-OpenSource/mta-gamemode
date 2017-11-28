-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Christmas/BonusGUI.lua
-- *  PURPOSE:     Christmas Bonus GUI
-- *
-- ****************************************************************************

BonusGUI = inherit(GUIForm)
inherit(Singleton, BonusGUI)

function BonusGUI:constructor()
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 16) 	-- width of the window
	self.m_Height = grid("y", 12) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"X-Mas Bonus Shop", true, true, self)
	GUIGridLabel:new(1, 1, 15, 1, "Herzlich Willkommen beim X-Mas-Premium Shop!\nHier kannst du deine Päckchen und Zuckerstangen in wertvolle Prämien umwandeln!", self.m_Window)
	self.m_ScrollArea =	GUIGridScrollableArea:new(1, 3, 15, 9, 10, 31, true, false, self.m_Window, 3)
	self.m_ScrollArea:updateGrid()
	self.m_BonusAmount = 0

	self.m_Column, self.m_Row = 1, 1

	self.m_BonusBG = {}
	self.m_BonusBtn = {}

	triggerServerEvent("eventRequestBonusData", localPlayer)

	addRemoteEvents{"eventReceiveBonusData"}
	addEventHandler("eventReceiveBonusData", root, bind(self.Event_receiveBonusData, self))
end

function BonusGUI:addBonus(index, data)
	if self.m_BonusAmount > 0 and self.m_BonusAmount % 3 == 0 then
		self.m_Row = self.m_Row + 6
		self.m_Column = 1
	end

	self.m_BonusAmount = self.m_BonusAmount + 1

	local id = self.m_BonusAmount

	self.m_BonusBG[id] = GUIGridImage:new(self.m_Column, self.m_Row, 4, 6, "files/images/Events/Christmas/Bonus_BG.png", self.m_ScrollArea)

	if data["Image"] then
		GUIGridImage:new(1, 1, 4, 6, ("files/images/Events/Bonus/%s"):format(data["Image"]), self.m_BonusBG[id])
	end

	GUIGridRectangle:new(1, 1, 4, 1, Color.Background, self.m_BonusBG[id])
	GUIGridLabel:new(1, 1, 4, 1, data["Text"], self.m_BonusBG[id]):setAlignX("center")

	GUIGridRectangle:new(1, 4.5, 4, 1, Color.Background, self.m_BonusBG[id])
	GUIGridImage:new(1, 4.5, 1, 1, "files/images/Inventory/items/Items/Paeckchen.png", self.m_BonusBG[id]):fitBySize(128, 128)
	GUIGridLabel:new(2, 4.5, 1, 1, tostring(data["Pumpkin"]), self.m_BonusBG[id]):setAlignX("center"):setFont(VRPFont(25))
	GUIGridImage:new(3, 4.5, 1, 1, "files/images/Inventory/items/Essen/Zuckerstange.png", self.m_BonusBG[id]):fitBySize(128, 128)
	GUIGridLabel:new(4, 4.5, 1, 1, tostring(data["Sweets"]), self.m_BonusBG[id]):setAlignX("center"):setFont(VRPFont(20))

	self.m_BonusBtn[id] = GUIGridButton:new(1, 6, 4, 1, "Kaufen", self.m_BonusBG[id]):setBackgroundColor(Color.Red)
	self.m_BonusBtn[id].onLeftClick = function() triggerServerEvent("eventBuyBonus", localPlayer, id) end

	self.m_Column = self.m_Column + 5
end

function BonusGUI:Event_receiveBonusData(bonusData)
	for name, data in ipairs(bonusData) do
		self:addBonus(index, data)
	end
end

function BonusGUI:destructor()
	GUIForm.destructor(self)
end
