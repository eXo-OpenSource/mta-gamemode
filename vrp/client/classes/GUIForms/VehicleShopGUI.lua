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
	self.m_VehicleList = GUIGridList:new(0, self.m_Height/7, self.m_Width, self.m_Height-self.m_Height/7-self.m_Height/14, self.m_Window)
	self.m_VehicleList:addColumn("", 0.6)
	self.m_VehicleList:addColumn("", 0.05)
	self.m_VehicleList:addColumn("", 0.3)
	self.m_ShopImage = GUIImage:new(0, 30, self.m_Width, self.m_Height/7, "files/images/Shops/CouttSchutz.png", self.m_Window)
	GUILabel:new(0, self.m_Height-self.m_Height/14, self.m_Width, self.m_Height/14, "↕", self.m_Window):setAlignX("center")
	GUILabel:new(6, self.m_Height-self.m_Height/14, self.m_Width*0.5, self.m_Height/14, _"Doppelklick zum Kaufen", self.m_Window):setFont(VRPFont(self.m_Height*0.045)):setAlignY("center"):setColor(Color.Red)

	self.m_VehicleBought = bind(self.Event_VehicleBought, self)
	addEventHandler("vehicleBought", root, self.m_VehicleBought)

	showChat(false)
end

function VehicleShopGUI:destructor()
	removeEventHandler("vehicleBought", root, self.m_VehicleBought)

	showChat(true)
	if self.m_InfoInstance then delete(self.m_InfoInstance) end
	GUIForm.destructor(self)

	if self.m_CameraInstance then
		delete(self.m_CameraInstance)
	end
	setCameraTarget(localPlayer, localPlayer)
end

function VehicleShopGUI:buyVehicle(item)
	if item.VehicleId then
		triggerServerEvent("vehicleBuy", root, self.m_Id, item.VehicleId)
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

	for k, v in pairs(list) do
		local item = self.m_VehicleList:addItem(getVehicleNameFromModel(k), v[3], "$"..tostring(v[2])):setColumnAlignX(3, "right")
		item.VehicleId = k
		item.onLeftClick = function()
			self.m_CurrentVehicle = v[1]
			if not self.m_InfoInstance then self.m_InfoInstance = VehicleShopInfoGUI:new(self.m_CurrentVehicle) end
			self.m_InfoInstance:updateVehicle(v[1])
			self:updateMatrix()
		end
		item.onLeftDoubleClick = bind(self.buyVehicle, self)
	end
end



function VehicleShopGUI:updateMatrix()
	if not isElement(self.m_CurrentVehicle) then return false end
	self.m_CurrentMatrix = {getCameraMatrix(localPlayer)}
	local pos = self.m_CurrentVehicle:getPosition()
	local offsetX, offsetY, offsetZ = getPositionFromElementOffset(self.m_CurrentVehicle, 5, 5, 5)
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
	GUIForm.constructor(self, screenWidth-250, screenHeight-200, 250, 200)


	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Fahrzeug", true, false, self)
	self.m_Gears = GUILabel:new(10, 35, self.m_Width-20, 20, "" , self.m_Window)
	self.m_Weight = GUILabel:new(10, 55, self.m_Width-20, 20, "", self.m_Window)
	self.m_MaxSpeed = GUILabel:new(10, 75, self.m_Width-20, 20, "", self.m_Window)
	self.m_DriveType = GUILabel:new(10, 95, self.m_Width-20, 20, "", self.m_Window)
	self.m_Seats = GUILabel:new(10, 115, self.m_Width-20, 20, "", self.m_Window)
	self.m_ABS = GUILabel:new(10, 135, self.m_Width-20, 20, "", self.m_Window)

	showChat(false)
end

function VehicleShopInfoGUI:updateVehicle(veh)
	local handling = veh:getHandling()
	local driveType = {["fwd"] = _"Front-Antrieb", ["rwd"] = _"Heck-Antrieb", ["awd"] = _"Allrad-Antrieb"}

	self.m_Window:setTitleBarText(veh:getName())
	self.m_Gears:setText(_("%d Gang Getriebe", handling["numberOfGears"]))
	self.m_Weight:setText(_("%d kg Leergewicht", handling["mass"]))
	self.m_MaxSpeed:setText(_("~ %d km/H Höchstgeschwindigkeit" , handling["maxVelocity"]))
	self.m_DriveType:setText(_("%s", driveType[handling["driveType"]]))
	self.m_Seats:setText(_("%d Sitzplätze", veh:getMaxPassengers()+1))
	self.m_ABS:setText(handling["ABS"] and "ABS" or "")
end
