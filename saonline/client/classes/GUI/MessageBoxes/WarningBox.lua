-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/MessageBoxs/InfoBox.lua
-- *  PURPOSE:     Warning box class
-- *
-- ****************************************************************************
WarningBox = inherit(MessageBox)

function WarningBox:getImagePath()
	return "files/images/MessageBoxs/Warning.png"
end

function WarningBox:getSoundPath()
	return "files/audio/Message.mp3"
end