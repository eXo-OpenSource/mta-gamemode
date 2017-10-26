-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Halloween/BonusGUI.lua
-- *  PURPOSE:     Halloween Bonus GUI
-- *
-- ****************************************************************************

BonusGUI = inherit(GUIForm)
inherit(Singleton, BonusGUI)

function BonusGUI:constructor()
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 16) 	-- width of the window
	self.m_Height = grid("y", 12) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Halloween Bonus GUI", true, true, self)
	GUIGridLabel:new(1, 1, 15, 1, "Herzlich Willkommen beim Halloween Premium Shop!\nHier kannst du deine Kürbisse und Süßigkeiten in wertvolle Prämien umwandeln!", self.m_Window)
	self.m_ScrollArea =	GUIGridScrollableArea:new(1, 3, 15, 9, 10, 36, true, false, self.m_Window, 3)
	self.m_ScrollArea:updateGrid()
	self.m_BonusAmount = 0

	self.m_Column, self.m_Row = 1, 1

	self.m_BonusBG = {}

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

	self.m_BonusBG[id] = GUIGridRectangle:new(self.m_Column, self.m_Row, 4, 6, Color.White, self.m_ScrollArea)
	GUIGridRectangle:new(1, 1, 4, 1, Color.LightBlue, self.m_BonusBG[id])
	GUIGridLabel:new(1, 1, 4, 1, data["Text"], self.m_BonusBG[id]):setAlignX("center")

	if data["Image"] then
		GUIGridImage:new(1, 2, 4, 3, ("files/images/Events/Halloween/%s"):format(data["Image"]), self.m_BonusBG[id]):fitBySize(150, 130)
	end

	GUIGridRectangle:new(1, 5, 4, 1, Color.LightGrey, self.m_BonusBG[id])
	GUIGridImage:new(1, 5, 1, 1, "files/images/Inventory/items/Items/Kuerbis.png", self.m_BonusBG[id]):fitBySize(128, 128)
	GUIGridLabel:new(2, 5, 1, 1, tostring(data["Pumpkin"]), self.m_BonusBG[id]):setAlignX("center"):setFont(VRPFont(25))
	GUIGridImage:new(3, 5, 1, 1, "files/images/Inventory/items/Essen/Suessigkeiten.png", self.m_BonusBG[id]):fitBySize(128, 128)
	GUIGridLabel:new(4, 5, 1, 1, tostring(data["Sweets"]), self.m_BonusBG[id]):setAlignX("center"):setFont(VRPFont(20))

	GUIGridButton:new(1, 6, 4, 1, "Kaufen", self.m_BonusBG[id])

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
