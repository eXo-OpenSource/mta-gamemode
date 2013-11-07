-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/MessageBoxs/InfoBox.lua
-- *  PURPOSE:     Info box class
-- *
-- ****************************************************************************
InfoBox = inherit(MessageBox)

function InfoBox:getImagePath()
	return "files/images/MessageBoxs/Info.png"
end

function InfoBox:getSoundPath()
	return "files/audio/Message.mp3"
end