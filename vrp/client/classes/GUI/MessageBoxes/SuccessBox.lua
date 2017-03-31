-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/MessageBoxs/InfoBox.lua
-- *  PURPOSE:     Success box class
-- *
-- ****************************************************************************
SuccessBox = inherit(MessageBox)

function SuccessBox:new(...) -- Todo: remove later!
	return ToastSuccess:new(...)
end

function SuccessBox:getImagePath()
	return "files/images/MessageBoxes/Success.png"
end

function SuccessBox:getSoundPath()
	return "files/audio/Success.mp3"
end

addEvent("successBox", true)
addEventHandler("successBox", root, function(...) SuccessBox:new(...) end)
