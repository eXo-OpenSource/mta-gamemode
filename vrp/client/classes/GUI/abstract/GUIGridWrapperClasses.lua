-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/abstract/GUIGridWrapperClasses.lua
-- *  PURPOSE:     GUI Grid Wrapper
-- *
-- ****************************************************************************
GUIGridButton = inherit(GUIButton)
GUIGridChanger = inherit(GUIChanger)
GUIGridCheckbox = inherit(GUICheckbox)
GUIGridEdit = inherit(GUIEdit)
GUIGridCombobox = inherit(GUICombobox)
GUIGridGridList = inherit(GUIGridList)
GUIGridImage = inherit(GUIImage)
GUIGridLabel = inherit(GUILabel)
GUIGridMiniMap = inherit(GUIMiniMap)
GUIGridProgressBar = inherit(GUIProgressBar)
GUIGridRadioButton = inherit(GUIRadioButton)
GUIGridRectangle = inherit(GUIRectangle)

function GUIGridButton:constructor(posX, posY, width, height, text, parent)	GUIButton.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), text, parent) self:setBarEnabled(true) return self end
function GUIGridChanger:constructor(posX, posY, width, height, parent) return GUIChanger.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), parent) end
function GUIGridCheckbox:constructor(posX, posY, width, height, text, parent) GUICheckbox.constructor(self, grid("x", posX), grid("y", posY) + 5, grid("d", width), grid("d", height) - 10, text, parent) self:setFont(VRPFont(25)):setFontSize(1) return self end
function GUIGridEdit:constructor(posX, posY, width, height, parent) return GUIEdit.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), parent) end
function GUIGridCombobox:constructor(posX, posY, width, height, parent) return GUICombobox.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), parent) end
function GUIGridGridList:constructor(posX, posY, width, height, parent) return GUIGridList.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), parent) end
function GUIGridImage:constructor(posX, posY, width, height, path, parent) return GUIImage.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), path, parent) end
function GUIGridLabel:constructor(posX, posY, width, height, text, parent) return GUILabel.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), text, parent) end
function GUIGridMiniMap:constructor(posX, posY, width, height, parent) return GUIMiniMap.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), parent) end
function GUIGridProgressBar:constructor(posX, posY, width, height, parent) return GUIProgressBar.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), parent) end
function GUIGridRadioButton:constructor(posX, posY, width, height, text, parent) return GUIRadioButton.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), text, parent) end
function GUIGridRectangle:constructor(posX, posY, width, height, color, parent) return GUIRectangle.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), color, parent) end
