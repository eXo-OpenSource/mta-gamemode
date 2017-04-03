-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/MessageBoxs/InfoBox.lua
-- *  PURPOSE:     Info box class
-- *
-- ****************************************************************************
ToastInfo = inherit(ToastMessage)

function ToastInfo:getImagePath()
	return "files/images/MessageBoxes/Toast/info.png"
end

function ToastInfo:getSoundPath()
	return "files/audio/Message.mp3"
end

function ToastInfo:getColor()
	return {49, 112, 143, 0.8}
end

function ToastInfo:getDefaultTitle()
	return _"Information"
end

addEvent("toast:infoBox", true)
addEventHandler("toast:infoBox", root, function(...) ToastInfo:new(...) end)
