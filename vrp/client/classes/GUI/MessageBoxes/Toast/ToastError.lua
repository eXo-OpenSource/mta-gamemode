-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/MessageBoxs/InfoBox.lua
-- *  PURPOSE:     Error box class
-- *
-- ****************************************************************************
ToastError = inherit(ToastMessage)

function ToastError:getImagePath()
	return "files/images/MessageBoxes/Toast/error.png"
end

function ToastError:getSoundPath()
	return "files/audio/Message.mp3"
end

function ToastError:getColor()
	return {169, 68, 66, 0.8}
end

function ToastError:getDefaultTitle()
	return _"Fehler"
end

addEvent("toast:errorBox", true)
addEventHandler("toast:errorBox", root, function(...) ToastError:new(...) end)
