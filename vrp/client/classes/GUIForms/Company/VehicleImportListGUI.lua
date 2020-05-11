VehicleImportListGUI = inherit(GUIForm)
inherit(Singleton, VehicleImportListGUI)

addRemoteEvents {"openVehicleImportListGUI"}

function VehicleImportListGUI:constructor(vehicleList, showStartButton)
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 16) 	-- width of the window
	self.m_Height = grid("y", showStartButton and 8 or 7) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"zu liefernde Fahrzeuge", true, true, self)
    if #vehicleList > 0 then
        self.m_GridListSelectedFunc = function()
            self.m_StartTransportBtn:setEnabled(true)
        end
        self.m_Grid = GUIGridGridList:new(1, 1, 15, 6, self.m_Window)
        self.m_Grid:addColumn("∑", 0.05)
        self.m_Grid:addColumn(_"Fahrzeug", 0.3)
        self.m_Grid:addColumn(_"Autohaus", 0.3)
        self.m_Grid:addColumn(_"Preis", 0.3)
        self.m_Grid:setSortable(true)
        self.m_Grid:setSortColumn("∑", "down")
    else
        GUIGridLabel:new(1, 1, 15, 6, _"Alle Autohäuser sind befüllt.", self.m_Window):setAlignX("center")
    end

    self.m_StartButtonActive = showStartButton
    
    if showStartButton then
        GUIGridLabel:new(1, 7, 10, 1, _"Hinweis: Für die Lieferung benötigst du einen DFT.", self.m_Window)
        self.m_StartTransportBtn = GUIGridButton:new(11, 7, 5, 1, _"Lieferung starten", self.m_Window):setBarEnabled(false):setBackgroundColor(Color.Green)
        self.m_StartTransportBtn.onLeftClick = bind(self.triggerTransportStart, self)
        self.m_StartTransportBtn:setEnabled(false)
    end

    if self.m_Grid then
        self:populateList(vehicleList)
    end
end

function VehicleImportListGUI:triggerTransportStart()
    local selectedItem = self.m_Grid:getSelectedItem()
    if selectedItem then
        triggerServerEvent("startVehicleTransport", localPlayer, selectedItem.shopId, selectedItem.model, selectedItem.variant, true)
    end
end

function VehicleImportListGUI:populateList(list)
    self.m_Grid:clear()
    if self.m_StartButtonActive then
        self.m_StartTransportBtn:setEnabled(false)
    end
    for i, data in pairs(list) do
        local item = self.m_Grid:addItem((data.maxStock - data.currentStock - data.currentlyTransported), VehicleCategory:getSingleton():getModelName(data.model), data.shopName, toMoneyString(data.price))
        item.shopId = data.shopId
        item.model = data.model
        item.variant = data.variant
        if self.m_StartButtonActive then
            item.onLeftClick = self.m_GridListSelectedFunc
        end
    end
end

function VehicleImportListGUI:destructor()
	GUIForm.destructor(self)
end

addEventHandler("openVehicleImportListGUI", root, function(vehicleList) 
	if not VehicleImportListGUI:isInstantiated() then 
		VehicleImportListGUI:new(vehicleList, getDistanceBetweenPoints3D(VEHICLE_IMPORT_POSITION, localPlayer.position) < 10)
    else
        VehicleImportListGUI:getSingleton():populateList(vehicleList)
    end
end)