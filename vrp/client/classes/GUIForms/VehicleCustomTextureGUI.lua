-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/VehicleCustomTextureGUI.lua
-- *  PURPOSE:     Vehicle tuning garage class
-- *
-- ****************************************************************************
VehicleCustomTextureGUI = inherit(GUIForm)
addRemoteEvents{"vehicleCustomTextureShopEnter", "vehicleCustomTextureShopExit", "vehicleCustomTextureShopInfo"}



function VehicleCustomTextureGUI:constructor(vehicle, path, textures)
    GUIForm.constructor(self, 10, 10, screenWidth/4/ASPECT_RATIO_MULTIPLIER, screenHeight*0.7)

    -- Part selection form
    do
        self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fahrzeug-Custom-Textures", false, true, self)
     	GUIImage:new(0, 30, self.m_Width, self.m_Height*0.13, "files/images/Shops/CustomTexture.jpg", self.m_Window)
		self.m_Color1 = VRPButton:new(self.m_Width*0.05, 30+self.m_Height*0.15, self.m_Width*0.42, self.m_Height*0.05, _"Farbe 1", true, self.m_Window):setBarColor(Color.Green)
		self.m_Color2 = VRPButton:new(self.m_Width*0.53, 30+self.m_Height*0.15, self.m_Width*0.42, self.m_Height*0.05, _"Farbe 2", true, self.m_Window):setBarColor(Color.Green)

		self.m_TextureList = GUIGridList:new(0, 30+self.m_Height*0.22, self.m_Width, self.m_Height*0.67, self.m_Window)
        self.m_TextureList:addColumn(_"Name (Doppelklick zum Kauf)", 1)
		self.m_MuteSound = GUILabel:new(self.m_Width-55, 5, 28, 28, FontAwesomeSymbols.SoundOn, self):setFont(FontAwesome(22))
		self.m_MuteSound.onLeftClick = function()
			if self.m_Music then
				self.m_Music:destroy()
				self.m_Music = nil
				self.m_MuteSound:setText(FontAwesomeSymbols.SoundOff)
			else
				self.m_Music = Sound.create("http://exo-reallife.de/ingame/GarageMusic.mp3", true)
				self.m_MuteSound:setText(FontAwesomeSymbols.SoundOn)
			end

		end
        GUIRectangle:new(0, 30+self.m_Height*0.895, self.m_Width, self.m_Height*0.005, Color.LightBlue, self.m_Window)
        GUILabel:new(0, 30+self.m_Height*0.89, self.m_Width, self.m_Height*0.075, "↕", self.m_Window):setAlignX("center")
    end


	self.m_Color1.onLeftClick = function()
		if self.m_ColorPicker then delete(self.m_ColorPicker) end
		local r2, g2, b2 = unpack(self.m_Tuning:getTuning("Color2"))
		self.m_ColorPicker = ColorPicker:new(
			function(r, g, b)
				self.m_Tuning:saveTuning("Color1", {r, g, b})
				self.m_Tuning:applyTuning()
			end,
			function(r, g, b)
				self.m_Vehicle:setColor(r, g, b, r2, g2, b2)
            end
			)
		self.m_ColorPicker:setColor(unpack(self.m_Tuning:getTuning("Color1")))
	end

	self.m_Color2.onLeftClick = function()
		if self.m_ColorPicker then delete(self.m_ColorPicker) end
		local r1, g1, b1 = unpack(self.m_Tuning:getTuning("Color1"))
		self.m_ColorPicker = ColorPicker:new(
			function(r, g, b)
				self.m_Tuning:saveTuning("Color2", {r, g, b})
				self.m_Tuning:applyTuning()
			end,
			function(r, g, b)
				self.m_Vehicle:setColor(r1, g1, b1, r, g, b)
            end
			)
		self.m_ColorPicker:setColor(unpack(self.m_Tuning:getTuning("Color2")))
	end

    self.m_Vehicle = vehicle
	self.m_Path = path
    self:initTextures(textures)

	setTimer(function()
		local pos = self.m_Vehicle:getPosition()
		setCameraMatrix(pos.x-5, pos.y-7, pos.z+1, pos)
	end, 100, 1)

    showChat(false)
	HUDRadar:getSingleton():hide()

	--self.m_Music = Sound.create("http://exo-reallife.de/ingame/GarageMusic.mp3", true)
	self.m_CarRadioVolume = RadioGUI:getSingleton():getVolume() or 0
	RadioGUI:getSingleton():setVolume(0)
    self.m_Vehicle:setOverrideLights(2)

	self.m_Tuning = VehicleTuning:new(self.m_Vehicle)
	self.m_TuningOld = VehicleTuning:new(self.m_Vehicle)

	self.m_RotateBind = bind(self.rotateVehicle, self)
	addEventHandler("onClientPreRender", root, self.m_RotateBind)


end

function VehicleCustomTextureGUI:destructor(closedByServer)
    if not closedByServer then
		TextureReplace.deleteFromElement(self.m_Vehicle)
        triggerServerEvent("vehicleCustomTextureAbbort", localPlayer)
		self.m_TuningOld:applyTuning()
    end

	removeEventHandler("onClientPreRender", root, self.m_RotateBind)

    setCameraTarget(localPlayer)
    if self.m_Music then
        self.m_Music:destroy()
    end
    self.m_Vehicle:setOverrideLights(0)
    showChat(true)
	RadioGUI:getSingleton():setVolume(self.m_CarRadioVolume)
	HUDRadar:getSingleton():show()
    GUIForm.destructor(self)
end

function VehicleCustomTextureGUI:rotateVehicle()
	local rot = self.m_Vehicle:getRotation()
	rot.z = rot.z+1
	rot.z = rot.z > 360 and rot.z-360 or rot.z
	self.m_Vehicle:setRotation(rot)
end

function VehicleCustomTextureGUI:initTextures(textures)
    -- Add 'special properties' (e.g. color)
    for index, row in ipairs(textures) do
        local item = self.m_TextureList:addItem(row["Name"])
        item.Url = self.m_Path..row["Image"]
		item.Id = row["Id"]
        item.onLeftClick = bind(self.Texture_Click, self)
		item.onLeftDoubleClick = function()
			QuestionBox:new(_("Möchtest du die Textur wirklich für 15.000$ kaufen?"),
				function()
					triggerServerEvent("vehicleCustomTextureBuy", self.m_Vehicle, item.Id, item.Url, self.m_Tuning:getTuning("Color1"), self.m_Tuning:getTuning("Color2"))
				end
			)
		end
    end
end

function VehicleCustomTextureGUI:Texture_Click(item)
    if item.Url then
		TextureReplace.deleteFromElement(self.m_Vehicle)
		triggerServerEvent("vehicleCustomTextureLoadPreview", self.m_Vehicle, item.Url, self.m_Tuning:getTuning("Color1"), self.m_Tuning:getTuning("Color2"))
	end
end

local vehicleTuningShop = false
addEventHandler("vehicleCustomTextureShopEnter", root,
    function(vehicle, path, textures)
        if vehicleTuningShop then
            delete(vehicleTuningShop)
        end

        vehicleTuningShop = VehicleCustomTextureGUI:new(vehicle, path, textures)

        vehicle:setDimension(PRIVATE_DIMENSION_CLIENT)
        localPlayer:setDimension(PRIVATE_DIMENSION_CLIENT)
		localPlayer.m_inTuning = true
    end
)

function VehicleCustomTextureGUI.Exit(closedByServer)
	if vehicleTuningShop then
		vehicleTuningShop.m_Vehicle:setDimension(0)
		localPlayer:setDimension(0)

		delete(vehicleTuningShop, closedByServer)
		vehicleTuningShop = false
		localPlayer.m_inTuning = false
		setCameraTarget(localPlayer)
	end
end
addEventHandler("vehicleCustomTextureShopExit", root, function() VehicleCustomTextureGUI.Exit(true) end)

addEventHandler("vehicleCustomTextureShopInfo", root, function()
	CustomTextureInfoGUI:new()
end)

CustomTextureInfoGUI = inherit(GUIButtonMenu)
inherit(Singleton, CustomTextureInfoGUI)

function CustomTextureInfoGUI:constructor()
	GUIButtonMenu.constructor(self, "Fahrzeug Textur Info")

	self:addItem(_"Hilfe/Info anzeigen",Color.Green ,
		function()
			HelpGUI:getSingleton():select(HelpTextTitles.Vehicles.CustomTextures)
			delete(self)
		end
	)
	self:addItem(_"Textur testen",Color.Green ,
		function()
			TexturePreviewGUI:getSingleton():open()
			delete(self)
		end
	)
end
