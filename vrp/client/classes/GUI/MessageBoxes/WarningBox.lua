-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/MessageBoxs/InfoBox.lua
-- *  PURPOSE:     Warning box class
-- *
-- ****************************************************************************
WarningBox = inherit(MessageBox)

function WarningBox:new(...) -- Todo: remove later!
	return ToastWarning:new(...)
end


function WarningBox:getImagePath()
	return "files/images/MessageBoxes/Warning.png"
end

function WarningBox:getSoundPath()
	return "files/audio/Message.mp3"
end

addEvent("warningBox", true)
addEventHandler("warningBox", root, function(...) WarningBox:new(...) end)
