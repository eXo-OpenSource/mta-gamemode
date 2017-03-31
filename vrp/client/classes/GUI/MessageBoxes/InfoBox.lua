-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/MessageBoxs/InfoBox.lua
-- *  PURPOSE:     Info box class
-- *
-- ****************************************************************************
InfoBox = inherit(MessageBox)

function InfoBox:new(...) -- Todo: remove later!
	return ToastInfo:new(...)
end

function InfoBox:getImagePath()
	return "files/images/MessageBoxes/Info.png"
end

function InfoBox:getSoundPath()
	return "files/audio/Message.mp3"
end

addEvent("infoBox", true)
addEventHandler("infoBox", root, function(...) InfoBox:new(...) end)
