-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MapEditorObjectGUI.lua
-- *  PURPOSE:     Map Editor Object GUI class
-- *
-- ****************************************************************************

MapEditorObjectGUI = inherit(GUIForm)
inherit(Singleton, MapEditorObjectGUI)

function MapEditorObjectGUI:constructor(object)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 11)
	self.m_Height = grid("y", 12)

	GUIForm.constructor(self, 23, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"MapEditor: Objekt", true, true, self)
	self.m_Scrollable = GUIGridScrollableArea:new(1, 1, 10, 10, 10, 11, true, false, self.m_Window)
	self.m_Scrollable:updateGrid()
	
	self.m_ModelLabel = GUIGridLabel:new(1, 1, 3, 1, "Model:", self.m_Scrollable)
    self.m_ModelEdit = GUIGridEdit:new(3, 1, 2, 1, self.m_Scrollable)
    
    self.m_ModelButton = GUIGridButton:new(6, 1, 4, 1, "Ändern", self.m_Scrollable)
    self.m_ModelButton.onLeftClick = function()
        
    end
	
	self.m_InteriorLabel = GUIGridLabel:new(1, 2, 3, 1, "Interior:", self.m_Scrollable)
	self.m_InteriorEdit = GUIGridEdit:new(3, 2, 2, 1, self.m_Scrollable)
	
	self.m_DimensionLabel = GUIGridLabel:new(6, 2, 3, 1, "Dimension:", self.m_Scrollable)
	self.m_DimensionEdit = GUIGridEdit:new(8, 2, 2, 1, self.m_Scrollable)
	
	self.m_PosXLabel = GUIGridLabel:new(1, 4, 3, 1, "Position X:", self.m_Scrollable)
	self.m_PosXEdit = GUIGridEdit:new(4, 4, 6, 1, self.m_Scrollable)
	
	self.m_PosYLabel = GUIGridLabel:new(1, 5, 3, 1, "Position Y:", self.m_Scrollable)
	self.m_PosYEdit = GUIGridEdit:new(4, 5, 6, 1, self.m_Scrollable)
	
	self.m_PosZLabel = GUIGridLabel:new(1, 6, 3, 1, "Position Z:", self.m_Scrollable)
	self.m_PosZEdit = GUIGridEdit:new(4, 6, 6, 1, self.m_Scrollable)
	
	self.m_RotXLabel = GUIGridLabel:new(1, 8, 3, 1, "Rotation X:", self.m_Scrollable)
	self.m_RotXEdit = GUIGridEdit:new(3, 8, 2, 1, self.m_Scrollable)
	
	self.m_RotYLabel = GUIGridLabel:new(1, 9, 3, 1, "Rotation Y:", self.m_Scrollable)
	self.m_RotYEdit = GUIGridEdit:new(3, 9, 2, 1, self.m_Scrollable)
	
	self.m_RotZLabel = GUIGridLabel:new(1, 10, 3, 1, "Rotation Z:", self.m_Scrollable)
	self.m_RotZEdit = GUIGridEdit:new(3, 10, 2, 1, self.m_Scrollable)
	
	self.m_ScaleXLabel = GUIGridLabel:new(6, 8, 3, 1, "Scale X:", self.m_Scrollable)
	self.m_ScaleXEdit = GUIGridEdit:new(8, 8, 2, 1, self.m_Scrollable)
	
	self.m_ScaleYLabel = GUIGridLabel:new(6, 9, 3, 1, "Scale Y:", self.m_Scrollable)
	self.m_ScaleYEdit = GUIGridEdit:new(8, 9, 2, 1, self.m_Scrollable)
	
	self.m_ScaleZLabel = GUIGridLabel:new(6, 10, 3, 1, "Scale Z:", self.m_Scrollable)
	self.m_ScaleZEdit = GUIGridEdit:new(8, 10, 2, 1, self.m_Scrollable)
	
	self.m_SaveButton = GUIGridButton:new(2, 12, 4, 1, "Speichern", self.m_Window):setBackgroundColor(Color.Green)
    self.m_DiscardButton = GUIGridButton:new(6, 12, 4, 1, "Abbrechen", self.m_Window):setBackgroundColor(Color.Red)
    
    self:insertObjectData(object)

    self.m_InteriorEdit.onChange = function() setElementInterior(object, self.m_InteriorEdit:getText()) end
    self.m_DimensionEdit.onChange = function() setElementDimension(object, self.m_DimensionEdit:getText()) end

    self.m_PosXEdit.onChange = function() x, y, z = getElementPosition(object) setElementPosition(object, self.m_PosXEdit:getText(), y, z) end
    self.m_PosYEdit.onChange = function() x, y, z = getElementPosition(object) setElementPosition(object, x, self.m_PosYEdit:getText(), z) end
    self.m_PosZEdit.onChange = function() x, y, z = getElementPosition(object) setElementPosition(object, x, y, self.m_PosZEdit:getText()) end

    self.m_RotXEdit.onChange = function() x, y, z = getElementRotation(object) setElementRotation(object, self.m_RotXEdit:getText(), y, z) end
    self.m_RotYEdit.onChange = function() x, y, z = getElementRotation(object) setElementRotation(object, x, self.m_RotYEdit:getText(), z) end
    self.m_RotZEdit.onChange = function() x, y, z = getElementRotation(object) setElementRotation(object, x, y, self.m_RotZEdit:getText()) end

    self.m_ScaleXEdit.onChange = function() x, y, z = getObjectScale(object) setObjectScale(object, self.m_ScaleXEdit:getText(), y, z) end
    self.m_ScaleYEdit.onChange = function() x, y, z = getObjectScale(object) setObjectScale(object, x, self.m_ScaleYEdit:getText(), z) end
    self.m_ScaleZEdit.onChange = function() x, y, z = getObjectScale(object) setObjectScale(object, x, y, self.m_ScaleZEdit:getText()) end

    self.m_SaveButton.onLeftClick = function()

    end

    self.m_DiscardButton.onLeftClick = function()
        setElementModel(object, self.m_Model)
        setElementInterior(object, self.m_Interior)
        setElementDimension(object, self.m_Dimension)
        setElementPosition(object, self.m_X, self.m_Y, self.m_Z)
        setElementRotation(object, self.m_RX, self.m_RY, self.m_RZ)
        setObjectScale(object, self.m_SX, self.m_SY, self.m_SZ)
        delete(self)
    end
end

function MapEditorObjectGUI:destructor()
    GUIForm.destructor(self)
    MapEditor:getSingleton():abortPlacing()
end

function MapEditorObjectGUI:insertObjectData(object)
    self.m_Model = getElementModel(object)
    self.m_Interior = getElementInterior(object)
    self.m_Dimension = getElementDimension(object)
    self.m_X, self.m_Y, self.m_Z = getElementPosition(object)
    self.m_RX, self.m_RY, self.m_RZ = getElementRotation(object)
    self.m_SX, self.m_SY, self.m_SZ = getObjectScale(object)

    self.m_ModelEdit:setText(self.m_Model)
    self.m_InteriorEdit:setText(self.m_Interior)
    self.m_DimensionEdit:setText(self.m_Dimension)

    self.m_PosXEdit:setText(self.m_X)
    self.m_PosYEdit:setText(self.m_Y)
    self.m_PosZEdit:setText(self.m_Z)

    self.m_RotXEdit:setText(self.m_RX)
    self.m_RotYEdit:setText(self.m_RY)
    self.m_RotZEdit:setText(self.m_RZ)

    self.m_ScaleXEdit:setText(self.m_SX)
    self.m_ScaleYEdit:setText(self.m_SY)
    self.m_ScaleZEdit:setText(self.m_SZ)
end