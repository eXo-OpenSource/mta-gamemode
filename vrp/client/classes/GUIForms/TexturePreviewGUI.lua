
TexturePreviewGUI = inherit(GUIForm)
inherit(Singleton, TexturePreviewGUI)
addRemoteEvents{"texturePreviewLoadTextures"}

function TexturePreviewGUI:constructor()
	GUIForm.constructor(self, 10, 10, screenWidth/4/ASPECT_RATIO_MULTIPLIER, screenHeight/2)

	self.m_Admin = localPlayer:getRank() >= RANK.Moderator and true or false

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fahrzeug-Textur Vorschau", false, true, self)
	self.m_TextureList = GUIGridList:new(0, self.m_Height*0.21, self.m_Width, self.m_Height*0.72, self.m_Window)
	self.m_TextureList:addColumn(_"Name", 1)

	self.m_VehiclePosition = Vector3(1944.97, -2307.69, 14.54)
	self.m_PlayerPosition = Vector3(1948.85, -2320.42, 17.11)
	setCameraMatrix(self.m_PlayerPosition, self.m_VehiclePosition)

	triggerServerEvent("texturePreviewRequestTextures", localPlayer, self.m_Admin)

	addEventHandler("texturePreviewLoadTextures", root, bind(self.initTextures, self))
	addEventHandler("onClientPreRender", root, self.m_RotateBind)
end

function TexturePreviewGUI:destructor(closedByServer)
	if self.m_Vehicle and isElement(self.m_Vehicle) then self.m_Vehicle:destroy() end
	removeEventHandler("onClientPreRender", root, self.m_RotateBind)
	GUIForm.destructor(self)
end

function TexturePreviewGUI:rotateVehicle()
	if self.m_Vehicle and isElement(self.m_Vehicle) then
		local rot = self.m_Vehicle:getRotation()
		rot.z = rot.z+1
		rot.z = rot.z > 360 and rot.z-360 or rot.z
		self.m_Vehicle:setRotation(rot)
	end
end

function TexturePreviewGUI:initTextures(textures)
    -- Add 'special properties' (e.g. color)
    for _, row in ipairs(textures) do
        local item = self.m_TextureList:addItem(row["Name"])
        item.Url = self.m_Path..row["Image"]
        item.Model = row["Model"]
		item.onLeftClick = bind(self.Texture_Click, self)
    end
end

function VehicleCustomTextureGUI:Texture_Click(item)
    if item.Url then
		if self.m_Vehicle and isElement(self.m_Vehicle) then self.m_Vehicle:destroy() end
		self.m_Vehicle = createVehicle(item.Model, self.m_VehiclePosition)
		self.m_Vehicle:setColor(255, 255, 255, 255, 255, 255)
		triggerServerEvent("vehicleCustomTextureLoadPreview", self.m_Vehicle, item.Url)
	end
end
