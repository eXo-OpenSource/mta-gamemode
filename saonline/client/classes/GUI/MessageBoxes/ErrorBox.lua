-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/MessageBoxs/InfoBox.lua
-- *  PURPOSE:     Error box class
-- *
-- ****************************************************************************
ErrorBox = inherit(MessageBox)

function ErrorBox:getImagePath()
	return "files/images/MessageBoxs/Error.png"
end

function ErrorBox:getSoundPath()
	return "files/audio/Message.mp3"
end