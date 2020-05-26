-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MapEditor/MapEditorTextureEditGUI.lua
-- *  PURPOSE:     Map Editor Texture Edit GUI class
-- *
-- ****************************************************************************

MapEditorTextureEditGUI = inherit(GUIForm)
inherit(Singleton, MapEditorTextureEditGUI)

MapEditorTextureEditGUI.FileEndings = {
    ".jpg",
    ".png"
}

function MapEditorTextureEditGUI:constructor(object, textures)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 12)
	self.m_Height = grid("y", 9)

	self.m_Object = object

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
    self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Texturen editieren", true, true, self)
    
    self.m_TextureBackground = GUIGridImage:new(1, 1, 2, 2, "files/images/Textures/Cityhall/tex4.jpg", self.m_Window):setColorRGB(0, 255, 0, 0)
    self.m_TextureImage = GUIGridImage:new(1, 1, 2, 2, "files/images/Textures/Empty.png", self.m_Window)
    self.m_TextureName = GUIGridLabel:new(3, 1, 9, 1, "Texturname: -", self.m_Window)
    self.m_TexturePath = GUIGridLabel:new(3, 2, 9, 1, "Bildpfad: -", self.m_Window)

    self.m_BackgroundCheckbox = GUIGridCheckbox:new(1, 3, 11, 1, "Hintergrundbild anzeigen (Für Texturen mit Transparenz)", self.m_Window)
    self.m_BackgroundCheckbox.onChange = function (state)
        self.m_TextureBackground:setColorRGB(0, 255, 0, state and 255 or 0)
    end

	self.m_Grid = GUIGridGridList:new(1, 4, 11, 4, self.m_Window)
	self.m_Grid:addColumn("Texturname", 0.4)
	self.m_Grid:addColumn("Bildpfad", 0.6)

    local objectTextures = engineGetModelTextures(self.m_Object:getModel())
    for textureName, textureMaterial in pairs(objectTextures) do
        local item = self.m_Grid:addItem(textureName,"-")

        item.onLeftDoubleClick = function()
            self.m_TextureImage:setImage(objectTextures[item:getColumnText(1)])
            self.m_TextureName:setText(("Texturname: %s"):format(item:getColumnText(1)))
            self.m_TexturePath:setText(("Bildpfad: %s"):format(item:getColumnText(2)))

            self.m_PathEdit:setText(item:getColumnText(2))
        end
        
    end

	if textures then
		for textureName, texturePath in pairs(textures) do
            for index, column in pairs(self.m_Grid:getItems()) do
                if textureName == column:getColumnText(1) then
                    column:setColumnText(2, texturePath)
                end
            end
		end
	end

    self.m_PathEdit = GUIGridEdit:new(1, 8, 10, 1, self.m_Window):setCaption("Bildpfad")
    
	self.m_SaveButton = GUIGridIconButton:new(11, 8, FontAwesomeSymbols.Save, self.m_Window):setBackgroundColor(Color.Green)
    self.m_SaveButton.onLeftClick = function()
        if self.m_Grid:getSelectedItem() then
            if self:checkForFileEndings(self.m_PathEdit:getText()) then

                if self:isTextureLocal(self.m_PathEdit:getText()) then
                    if not fileExists(self.m_PathEdit:getText()) or not string.find(self.m_PathEdit:getText(), "files/images/Textures/") then
                        ErrorBox:new("Die Bilddatei existiert lokal nicht!")
                        return
                    end
                end

                self.m_Grid:getSelectedItem():setColumnText(2, self.m_PathEdit:getText())
                self:save()
            else
                ErrorBox:new("Deine Bilddatei ist im falschen Format! (Nur PNG oder JPG)")
            end
        end
    end
    
	self.m_DeleteButton = GUIGridIconButton:new(11, 4, FontAwesomeSymbols.Trash, self.m_Window):setBackgroundColor(Color.Red)
	self.m_DeleteButton.onLeftClick = function()
		if self.m_Grid:getSelectedItem() then
			self.m_Grid:getSelectedItem():setColumnText(2, "-")
			self:save()
		end
	end
end

function MapEditorTextureEditGUI:save()
	local textureTable = {}
    for i, v in pairs(self.m_Grid:getItems()) do
        if v:getColumnText(2) ~= "-" then
            textureTable[v:getColumnText(1)] = v:getColumnText(2)
        end
	end
    if MapEditorObjectGUI:isInstantiated() then
        MapEditorObjectGUI:getSingleton():addTextures(textureTable)
    end
end

function MapEditorTextureEditGUI:checkForFileEndings(path)
    for index, tag in pairs(MapEditorTextureEditGUI.FileEndings) do
        if string.find(path, tag) then
            return true
        end
    end
    return false
end

function MapEditorTextureEditGUI:isTextureLocal(name)
    if string.find(name, "http://") or string.find(name, "https://") then
        return false
    end
    return true
end

function MapEditorTextureEditGUI:destructor()
	GUIForm.destructor(self)
end
