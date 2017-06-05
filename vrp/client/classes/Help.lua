-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Help.lua
-- *  PURPOSE:     Client Help Class
-- *
-- ****************************************************************************

Help = inherit(Singleton)

function Help:constructor()
	addRemoteEvents{"helpTextReceive"}

	addEventHandler("helpTextReceive", root, bind(self.helpTextReceive, self))

    self.m_Hash = nil
    self.m_Text = nil

    if fileExists("files/help.json") then
        local fileHandle = fileOpen("files/help.json")
        self.m_Text = fileRead(fileHandle, fileGetSize(fileHandle))
        fileClose(fileHandle)

        self.m_Hash = hash("sha1", self.m_Text)
        self.m_Text = fromJSON(self.m_Text)
    end

    triggerServerEvent("helpCheckHash", localPlayer, self.m_Hash)
end

function Help:destructor()

end

function Help:helpTextReceive(text)
    self.m_Text = fromJSON(text)
    self.m_Hash = hash("sha1", text)

    if fileExists("files/help.json") then
        fileDelete("files/help.json")
    end

    local fileHandle = fileCreate("files/help.json")
    fileWrite(fileHandle, text)
    fileClose(fileHandle)
end

function Help:getText()
    return self.m_Text
end