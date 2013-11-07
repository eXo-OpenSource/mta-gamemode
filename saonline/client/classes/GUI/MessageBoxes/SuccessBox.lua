-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/MessageBoxs/InfoBox.lua
-- *  PURPOSE:     Success box class
-- *
-- ****************************************************************************
SuccessBox = inherit(MessageBox)

function SuccessBox:getImagePath()
	return "files/images/MessageBoxs/Success.png"
end

function SuccessBox:getSoundPath()
	return "files/audio/Message.mp3"
end