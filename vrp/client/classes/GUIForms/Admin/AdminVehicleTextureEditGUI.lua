AdminVehicleTextureEditGUI = inherit(GUIForm)
inherit(Singleton, AdminVehicleTextureEditGUI)

function AdminVehicleTextureEditGUI:constructor(vehicle, textures)
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 12) 	-- width of the window
	self.m_Height = grid("y", 6) 	-- height of the window

	self.m_Vehicle = vehicle

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Texturen editieren", true, true, self)

	self.m_Grid = GUIGridGridList:new(1, 1, 11, 4, self.m_Window)
	self.m_Grid:addColumn("Texturname", 0.4)
	self.m_Grid:addColumn("Bildpfad", 0.6)

	if textures then
		for i,v in pairs(textures) do
			local item = self.m_Grid:addItem(i,v)
			item.onLeftDoubleClick = function()
				self.m_NameEdit:setText(i)
				self.m_PathEdit:setText(v)
			end
		end
	end

	self.m_NameEdit = GUIGridEdit:new(1, 5, 5, 1, self.m_Window):setCaption("Name")
	self.m_NameEdit:setText("vehiclegrunge256")
	self.m_PathEdit = GUIGridEdit:new(6, 5, 5, 1, self.m_Window):setCaption("Pfad")
	self.m_AddButton = GUIGridIconButton:new(11, 5, FontAwesomeSymbols.Plus, self.m_Window):setBackgroundColor(Color.Green)
	self.m_AddButton.onLeftClick = function()
		self.m_Grid:addItem(self.m_NameEdit:getText(), self.m_PathEdit:getText())
		self:sendToServer()
	end
	self.m_DeleteButton = GUIGridIconButton:new(11, 1, FontAwesomeSymbols.Trash, self.m_Window):setBackgroundColor(Color.Red)
	self.m_DeleteButton.onLeftClick = function()
		if self.m_Grid:getSelectedItem() then
			self.m_Grid:removeItemByItem(self.m_Grid:getSelectedItem())
			self:sendToServer()
		end
	end
end

function AdminVehicleTextureEditGUI:sendToServer()
	local textureTable = {}
	for i,v in pairs(self.m_Grid:getItems()) do
		textureTable[v:getColumnText(1)] = v:getColumnText(2)
	end
	triggerServerEvent("adminVehicleOverrideTextures", localPlayer, self.m_Vehicle, textureTable)
end

function AdminVehicleTextureEditGUI:destructor()
	GUIForm.destructor(self)
end
