-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/MessageBoxs/InfoBox.lua
-- *  PURPOSE:     Success box class
-- *
-- ****************************************************************************
ToastSuccess = inherit(ToastMessage)

function ToastSuccess:getImagePath()
	return "files/images/MessageBoxes/Toast/success.png"
end

function ToastSuccess:getSoundPath()
	return "files/audio/Success.mp3"
end

function ToastSuccess:getColor()
	return {60, 118, 61, 0.8}
end

function ToastSuccess:getDefaultTitle()
	return _"Erfolgreich"
end

addEvent("toast:successBox", true)
addEventHandler("toast:successBox", root, function(...) ToastSuccess:new(...) end)
