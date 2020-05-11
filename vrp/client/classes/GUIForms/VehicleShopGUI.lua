-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleShopGUI.lua
-- *  PURPOSE:     VehicleShopGUI class
-- *
-- ****************************************************************************
VehicleShopGUI = inherit(GUIForm)
inherit(Singleton, VehicleShopGUI)

addRemoteEvents{"showVehicleShopMenu", "vehicleBought"}

function VehicleShopGUI:constructor()
	GUIForm.constructor(self, 10, 10, screenWidth/5/ASPECT_RATIO_MULTIPLIER, screenHeight/2)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Vehicle shop", false, true, self)
	self.m_VehicleList = GUIGridList:new(0, self.m_Height/7+30, self.m_Width, self.m_Height-self.m_Height/7-self.m_Height/14-30, self.m_Window)
	self.m_VehicleList:addColumn("Name", 0.43)
	self.m_VehicleList:addColumn("Level", 0.11)
	self.m_VehicleList:addColumn("Preis", 0.2)
	self.m_VehicleList:addColumn("auf Lager", 0.15)
	self.m_ShopImage = GUIImage:new(0, 30, self.m_Width, self.m_Height/7, "files/images/Shops/CouttSchutz.png", self.m_Window)
	GUILabel:new(6, self.m_Height-self.m_Height/14, self.m_Width*0.5, self.m_Height/14, _"Doppelklick zum Kaufen", self.m_Window):setFont(VRPFont(self.m_Height*0.045)):setAlignY("center")

	self.m_VehicleBought = bind(self.Event_VehicleBought, self)
	addEventHandler("vehicleBought", root, self.m_VehicleBought)

	showChat(false)
end

function VehicleShopGUI:virtual_destructor()
	removeEventHandler("vehicleBought", root, self.m_VehicleBought)

	showChat(true)
	if self.m_InfoInstance then delete(self.m_InfoInstance) end

	if self.m_CameraInstance then
		delete(self.m_CameraInstance)
	end
	setCameraTarget(localPlayer, localPlayer)
end

function VehicleShopGUI:buyVehicle(item)
	if item.VehicleId then
		QuestionBox:new(_("Möchtest du das Fahrzeug %s wirklich für %s kaufen?", VehicleCategory:getSingleton():getModelName(item.VehicleId), toMoneyString(item.VehiclePrice)), function()
			triggerServerEvent("vehicleBuy", root, self.m_Id, item.VehicleId, item.VehicleIndex)
		end)
	end
end

function VehicleShopGUI:setShopName(name)
	self.m_ShopName = name
end

function VehicleShopGUI:setShopId(id)
	self.m_Id = id
end

function VehicleShopGUI:setShopLogoPath(path)
	return self.m_ShopImage:setImage(path)
end

function VehicleShopGUI:setVehicleList(list)
	-- Clear old data
	self.m_VehicleList:clear()

	local vehicleCount = 0
	for k, v in pairs(list) do
		for i = 1, #v do
			vehicleCount = vehicleCount + 1
			local stock = v[i][5] == -1 and "Ja" or ("%s/%s"):format(v[i][4], v[i][5])
			local item = self.m_VehicleList:addItem(VehicleCategory:getSingleton():getModelName(k), v[i][3], toMoneyString(v[i][2]), stock)
			item.VehicleId = k
			item.VehicleIndex = i
			item.VehiclePrice = v[i][2]
			item.onLeftClick = function()
				self.m_CurrentVehicle = v[i][1]
				if not self.m_InfoInstance then self.m_InfoInstance = VehicleShopInfoGUI:new(self.m_CurrentVehicle) end
				self.m_InfoInstance:updateVehicle(v[i][1])
				self:updateMatrix()
			end
			item.onLeftDoubleClick = bind(self.buyVehicle, self)
		end
	end
end



function VehicleShopGUI:updateMatrix()
	if not isElement(self.m_CurrentVehicle) then return false end
	self.m_CurrentMatrix = {getCameraMatrix(localPlayer)}
	local pos = self.m_CurrentVehicle:getPosition()
	local x0, y0, z0, x1, y1, z1 = getElementBoundingBox(self.m_CurrentVehicle)
	local dist = math.sqrt((math.abs(x0) + math.abs(x1))^2 + (math.abs(y0) + math.abs(y1))^2)/1.5
	local offsetX, offsetY, offsetZ = getPositionFromElementOffset(self.m_CurrentVehicle, dist, dist, dist)
	local fadeMatrix = {offsetX, offsetY, offsetZ, pos.x, pos.y, pos.z, -25, 90}

	if self.m_CameraInstance then
		delete(self.m_CameraInstance)
	end

	self.m_CameraInstance = cameraDrive:new(self.m_CurrentMatrix[1],self.m_CurrentMatrix[2],self.m_CurrentMatrix[3],
		self.m_CurrentMatrix[4],self.m_CurrentMatrix[5],self.m_CurrentMatrix[6],
		fadeMatrix[1],fadeMatrix[2],fadeMatrix[3],
		fadeMatrix[4],fadeMatrix[5],fadeMatrix[6],
		1500
	)
end

function VehicleShopGUI:Event_VehicleBought()
	delete(self)
	self.m_BuyVehicle = getPedOccupiedVehicle(localPlayer)
	setElementAlpha(self.m_BuyVehicle,150)
	for key, vehicle in ipairs(getElementsByType("vehicle")) do
		setElementCollidableWith(self.m_BuyVehicle,vehicle,false)
	end
	setTimer(bind(VehicleShopGUI.setColBack,self),15000,1,self.m_BuyVehicle)
	SuccessBox:new(_"Glückwunsch! Du bist nun Besitzer eines neuen Fahrzeugs!")
end

function VehicleShopGUI:setColBack()
	setElementAlpha(self.m_BuyVehicle,255)
	for key, vehicle in ipairs(getElementsByType("vehicle")) do
		setElementCollidableWith(self.m_BuyVehicle,vehicle,true)
	end
end

addEventHandler("showVehicleShopMenu", root, function(id, name, image, vehicles)
	local shopGUI = VehicleShopGUI:getSingleton()
	shopGUI:setShopName(name)
	shopGUI:setShopId(id)
	shopGUI:setShopLogoPath("files/images/Shops/"..image)
	shopGUI:setVehicleList(vehicles)

	VehicleShopGUI:getSingleton():setVisible(true)
end)

VehicleShopInfoGUI = inherit(GUIForm)
inherit(Singleton, VehicleShopInfoGUI)

function VehicleShopInfoGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 7)
	self.m_Height = grid("y", 7)

	GUIForm.constructor(self, screenWidth-self.m_Width*1.5, screenHeight-self.m_Height*1.5, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Buffalo", true, false, self)
	self.m_Label = GUIGridLabel:new(1, 1, 6, 5, "Muscle-Car\n1200kg Leergewicht\nrund 230 km/h Spitze\n5-Gang-Getriebe\nHeck-Antrieb", self.m_Window)

	self.m_LightButton = GUIGridIconButton:new(1, 6, FontAwesomeSymbols.Lightbulb, self.m_Window):setTooltip("Licht an/aus", "bottom")
	self.m_EngineButton = GUIGridIconButton:new(2, 6, FontAwesomeSymbols.Cogs, self.m_Window):setTooltip("Motor an/aus", "bottom")
	self.m_DoorButton = GUIGridIconButton:new(3, 6, FontAwesomeSymbols.Key, self.m_Window):setTooltip("Türen auf/zu", "bottom")

	self.m_LightButton.onLeftClick = function()
		if isElement(self.m_Veh) then
			self.m_Veh:setOverrideLights(self.m_Veh:getOverrideLights() == 2 and 1 or 2)
		end
	end
	self.m_EngineButton.onLeftClick = function()
		if isElement(self.m_Veh) then
			self.m_Veh:setEngineState(not self.m_Veh:getEngineState())
		end
	end
	self.m_DoorButton.onLeftClick = function()
		if isElement(self.m_Veh) then
			for i=0,5 do
				setVehicleDoorOpenRatio ( self.m_Veh, i, getVehicleDoorOpenRatio ( self.m_Veh, i ) == 1 and 0 or 1, 500 )
			end
		end
	end
end

function VehicleShopInfoGUI:updateVehicle(veh)
	self:resetOldVehicle()

	local handling = veh:getHandling()
	local driveType = {["fwd"] = _"Front-Antrieb", ["rwd"] = _"Heck-Antrieb", ["awd"] = _"Allrad-Antrieb"}
	self.m_Veh = veh
	self.m_Window:setTitleBarText(veh:getName())
	self.m_Label:setText(("- %s\n- %s%s\n- %s$ Steuern / PayDay\n- %s kg Leergewicht\n~ %s km/h Höchstgeschw.\n- %s\n- %s Sitzplätze"):format(
		veh:getCategoryName(),
		(veh:getFuelType() ~= "nofuel" and veh:getFuelTankSize().."-Liter-" or ""),
		(veh:getFuelType() == "nofuel" and "kein Tank" or "Tank ("..FUEL_NAME[veh:getFuelType()]..")"),
		veh:getTax(),
		handling["mass"],
		veh:getMaxVelocityShopInfo(),
		driveType[handling["driveType"]],
		veh:getMaxPassengers()+1
	))
end

function VehicleShopInfoGUI:resetOldVehicle()
	if isElement(self.m_Veh) then
		self.m_Veh:setEngineState(false)
		self.m_Veh:setOverrideLights(1)
		for i=0,5 do
			setVehicleDoorOpenRatio ( self.m_Veh, i, 0, 500 )
		end
	end
end

function VehicleShopInfoGUI:destructor()
	self:resetOldVehicle()
	GUIForm.destructor(self)
end
