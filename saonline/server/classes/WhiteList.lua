-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/WhiteList.lua
-- *  PURPOSE:     Whitelist class
-- *
-- ****************************************************************************
WhiteList = inherit(Singleton)

function WhiteList:constructor()
	self.m_Data = {}

	-- Create xml if not exists
	if fileExists("whitelist.xml") then
		self.m_XmlFile = xmlLoadFile("whitelist.xml")
	else
		self.m_XmlFile = xmlCreateFile("whitelist.xml", "whitelist")
	end
	
	-- Parse our xml file
	self:parseXML()
	
	-- Add connection handler
	addEventHandler("onPlayerConnect", root,
		function(playerNick, playerIP, playerUsername, playerSerial, playerVersionNumber, playerVersionString)
			local whiteNick = self:checkSerial(playerSerial)
			if not whiteNick then
				cancelEvent(true, "Sorry, you're not whitelisted")
			else
				outputServerLog("[WHITELIST] Whitelisted player joined. Whitelist-Nick: "..whiteNick)
			end
		end
	)
	
	addCommandHandler("addserial",
		function(player, cmd, nick, serial)
			if not nick or not serial then
				outputChatBox("Syntax: /addserial nick serial", player, 255, 0, 0)
				return
			end
			if hasObjectPermissionTo(player, "function.banPlayer") then
				self:addPlayer(nick, serial)
			end
		end
	)
	
	xmlSaveFile(self.m_XmlFile)
end

function WhiteList:destructor()
	xmlUnloadFile(self.m_XmlFile)
	-- Todo: Remove the event handler
end

function WhiteList:parseXML()
	-- Clear old data (in case of "reparsing")
	self.m_Data = {}
	
	-- Read the new
	for k, playerNode in ipairs(xmlNodeGetChildren(self.m_XmlFile)) do
		local name = xmlNodeGetAttribute(playerNode, "name")
		local serial = xmlNodeGetAttribute(playerNode, "serial")
		self.m_Data[serial] = name
	end
end

function WhiteList:addPlayer(name, serial)
	self.m_Data[serial] = name
	
	local playerNode = xmlCreateChild(self.m_XmlFile, "player")
	xmlNodeSetAttribute(playerNode, "name", name)
	xmlNodeSetAttribute(playerNode, "serial", serial)
	xmlSaveFile(self.m_XmlFile)
end

function WhiteList:checkSerial(serial)
	return self.m_Data[serial]
end
