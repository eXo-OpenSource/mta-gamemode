-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleShopGUI.lua
-- *  PURPOSE:     VehicleShopGUI class
-- *
-- ****************************************************************************
VehicleShopGUI = inherit(GUIForm)
inherit(Singleton, VehicleShopGUI)

addRemoteEvents{"showVehicleShopMenu"}

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

	addEvent("vehicleBought", true)
	addEventHandler("vehicleBought", root,
		function()
			delete(self)
			SuccessBox:new(_"Glückwunsch! Du bist nun Besitzer eines neuen Fahrzeugs!", 0, 255, 0)
		end
	)

	showChat(false)
end

function VehicleShopGUI:destructor()
	showChat(true)
	setCameraTarget(localPlayer, localPlayer)
	setTimer(function()
		setCameraTarget(localPlayer, localPlayer)
	end, 2000, 1)
	GUIForm.destructor(self)
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
			self:updateMatrix()
		end
		item.onLeftDoubleClick = bind(self.buyVehicle, self)
	end
end



function VehicleShopGUI:updateMatrix()
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

addEventHandler("showVehicleShopMenu", root, function(id, name, image, vehicles)
	local shopGUI = VehicleShopGUI:getSingleton()
	shopGUI:setShopName(name)
	shopGUI:setShopId(id)
	shopGUI:setShopLogoPath("files/images/Shops/"..image)
	shopGUI:setVehicleList(vehicles)

	VehicleShopGUI:getSingleton():setVisible(true)
end)
