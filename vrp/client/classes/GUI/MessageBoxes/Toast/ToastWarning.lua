-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/MessageBoxs/InfoBox.lua
-- *  PURPOSE:     Warning box class
-- *
-- ****************************************************************************
ToastWarning = inherit(ToastMessage)

function ToastWarning:getImagePath()
	return "files/images/MessageBoxes/Toast/warning.png"
end

function ToastWarning:getSoundPath()
	return "files/audio/Message.mp3"
end

function ToastWarning:getColor()
	return {138, 109, 59, 0.8}
end

function ToastWarning:getDefaultTitle()
	return _"Warnung"
end

addEvent("toast:warningBox", true)
addEventHandler("toast:warningBox", root, function(...) ToastWarning:new(...) end)
