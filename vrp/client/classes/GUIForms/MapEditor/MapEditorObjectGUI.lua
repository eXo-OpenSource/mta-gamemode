-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MapEditor/MapEditorObjectGUI.lua
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
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Map Editor: Objekt bearbeiten", true, true, self)
	self.m_Scrollable = GUIGridScrollableArea:new(1, 1, 10, 10, 10, 14, true, false, self.m_Window)
    self.m_Scrollable:updateGrid()
    
    self.m_Object = object
	
	self.m_ModelLabel = GUIGridLabel:new(1, 1, 3, 1, "Model:", self.m_Scrollable)
    self.m_ModelEdit = GUIGridLabel:new(3, 1, 2, 1, "", self.m_Scrollable)
    
    self.m_ModelButton = GUIGridButton:new(6, 1, 4, 1, "Ändern", self.m_Scrollable)
    self.m_ModelButton.onLeftClick = function()
        self:close()
        MapEditorObjectCreateGUI:new(true)
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
    
    self.m_BreakableCheckbox = GUIGridCheckbox:new(1, 11, 10, 1, "Zerbrechbar", self.m_Scrollable)

    self.m_CollisionCheckbox = GUIGridCheckbox:new(1, 12, 10, 1, "Kollisionen", self.m_Scrollable)

    self.m_DoubleSidedCheckbox = GUIGridCheckbox:new(1, 13, 10, 1, "Doppelseitige Textur", self.m_Scrollable)
	
	self.m_SaveButton = GUIGridButton:new(2, 12, 4, 1, "Speichern", self.m_Window):setBackgroundColor(Color.Green)
    self.m_DiscardButton = GUIGridButton:new(6, 12, 4, 1, "Abbrechen", self.m_Window):setBackgroundColor(Color.Red)
    
    self:insertObjectData(object)

    self.m_InteriorEdit.onChange = function() if isElement(object) then setElementInterior(object, self.m_InteriorEdit:getText()) end end
    self.m_DimensionEdit.onChange = function() if isElement(object) then setElementDimension(object, self.m_DimensionEdit:getText()) end end

    self.m_PosXEdit.onChange = function() if isElement(object) then x, y, z = getElementPosition(object) if tonumber(self.m_PosXEdit:getText()) then setElementPosition(object, self.m_PosXEdit:getText(), y, z) end end end 
    self.m_PosYEdit.onChange = function() if isElement(object) then x, y, z = getElementPosition(object) if tonumber(self.m_PosYEdit:getText()) then setElementPosition(object, x, self.m_PosYEdit:getText(), z) end end end
    self.m_PosZEdit.onChange = function() if isElement(object) then x, y, z = getElementPosition(object) if tonumber(self.m_PosZEdit:getText()) then setElementPosition(object, x, y, self.m_PosZEdit:getText()) end end end

    self.m_RotXEdit.onChange = function() if isElement(object) then x, y, z = getElementRotation(object) if tonumber(self.m_RotXEdit:getText()) then setElementRotation(object, self.m_RotXEdit:getText(), y, z) end end end
    self.m_RotYEdit.onChange = function() if isElement(object) then x, y, z = getElementRotation(object) if tonumber(self.m_RotYEdit:getText()) then setElementRotation(object, x, self.m_RotYEdit:getText(), z) end end end
    self.m_RotZEdit.onChange = function() if isElement(object) then x, y, z = getElementRotation(object) if tonumber(self.m_RotZEdit:getText()) then setElementRotation(object, x, y, self.m_RotZEdit:getText()) end end end

    self.m_ScaleXEdit.onChange = function() if isElement(object) then x, y, z = getObjectScale(object) if tonumber(self.m_ScaleXEdit:getText()) then setObjectScale(object, self.m_ScaleXEdit:getText(), y, z) end end end
    self.m_ScaleYEdit.onChange = function() if isElement(object) then x, y, z = getObjectScale(object) if tonumber(self.m_ScaleYEdit:getText()) then setObjectScale(object, x, self.m_ScaleYEdit:getText(), z) end end end
    self.m_ScaleZEdit.onChange = function() if isElement(object) then x, y, z = getObjectScale(object) if tonumber(self.m_ScaleZEdit:getText()) then setObjectScale(object, x, y, self.m_ScaleZEdit:getText()) end end end

    self.m_DoubleSidedCheckbox.onChange = function() if isElement(object) then object:setDoubleSided(self.m_DoubleSidedCheckbox:isChecked()) end end

    self.m_SaveButton.onLeftClick = function()
        self:saveObject()
        delete(self)
    end

    self.m_DiscardButton.onLeftClick = function()
        delete(self)
    end
end

function MapEditorObjectGUI:destructor()
    GUIForm.destructor(self)
    if isElement(self.m_Object) then
        setElementModel(self.m_Object, self.m_Model)
        setElementInterior(self.m_Object, self.m_Interior)
        setElementDimension(self.m_Object, self.m_Dimension)
        setElementPosition(self.m_Object, self.m_X, self.m_Y, self.m_Z)
        setElementRotation(self.m_Object, self.m_RX, self.m_RY, self.m_RZ)
        setObjectScale(self.m_Object, self.m_SX, self.m_SY, self.m_SZ)
        setElementDoubleSided(self.m_Object, self.m_DoubleSided)
    end
end

function MapEditorObjectGUI:insertObjectData(object)
    self.m_Model = getElementModel(object)
    self.m_Interior = getElementInterior(object)
    self.m_Dimension = getElementDimension(object)
    self.m_X, self.m_Y, self.m_Z = getElementPosition(object)
    self.m_RX, self.m_RY, self.m_RZ = getElementRotation(object)
    self.m_SX, self.m_SY, self.m_SZ = getObjectScale(object)
    self.m_Breakable = object:getData("breakable")
    self.m_Collision = object:getCollisionsEnabled()
    self.m_DoubleSided = object:isDoubleSided()

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

    self.m_BreakableCheckbox:setChecked(self.m_Breakable)
    if object:isBreakable() == false then
        object:setBreakable(true)
        if object:isBreakable() == false then
            self.m_BreakableCheckbox:setChecked(false)
            self.m_BreakableCheckbox:setEnabled(false)
            self.m_BreakableCheckbox:setText("Zerbrechbar (Beeinflusst dieses Objekt nicht)")
        end
    elseif object:isBreakable() == true then
        object:setBreakable(false)
        if object:isBreakable() == true then
            self.m_BreakableCheckbox:setChecked(true)
            self.m_BreakableCheckbox:setEnabled(false)
            self.m_BreakableCheckbox:setText("Zerbrechbar (Beeinflusst dieses Objekt nicht)")
        end
    end
    object:setBreakable(self.m_Breakable)

    self.m_CollisionCheckbox:setChecked(self.m_Collision)
    self.m_DoubleSidedCheckbox:setChecked(self.m_DoubleSided)
end

function MapEditorObjectGUI:changeModel(id)
    self.m_ModelEdit:setText(id)
    self.m_Object:setModel(id)
end

function MapEditorObjectGUI:saveObject()
    if isElement(self.m_Object) then
        local model = getElementModel(self.m_Object)
        local interior = getElementInterior(self.m_Object)
        local dimension = getElementDimension(self.m_Object)
        local position = self.m_Object:getPosition()
        local rotation = self.m_Object:getRotation()
        local sx, sy, sz = self.m_Object:getScale()
        local breakable = self.m_BreakableCheckbox:isChecked()
        local collision = self.m_CollisionCheckbox:isChecked()
        local doublesided = self.m_DoubleSidedCheckbox:isChecked()

        MapEditor:getSingleton():onObjectPlaced(position, rotation, Vector3(sx, sy, sz), interior, dimension, model, breakable, collision, doublesided)
    end
end