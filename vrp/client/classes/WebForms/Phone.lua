-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/WebForms/Phone.lua
-- *  PURPOSE:     experimental Phone Class
-- *
-- ****************************************************************************
PhoneCEF = inherit(GUIWebForm)
inherit(Singleton, PhoneCEF)

function PhoneCEF:constructor()
	GUIWebForm.constructor(self, screenWidth-320, screenHeight-630, 294, 600)
	outputChatBox(self:generateSessionId())
	self.m_WebView = GUIWebView:new(0, 0, self.m_Width, self.m_Height, "http://exo-reallife.de/ingame/phone/phone.php?player="..getPlayerName(getLocalPlayer()).."&sessionID="..self:generateSessionId(), true, self)
	Browser.requestDomains{"exo-reallife.de", "maxcdn.bootstrapcdn.com"}
end
setTimer(function() PhoneCEF:new() end,500,1)	-- Only while Testing

function PhoneCEF:destructor()
	GUIWebForm.destructor(self)
end

function PhoneCEF:onShow()
	showChat(false)
end

function PhoneCEF:onHide()
	showChat(true)
end

function PhoneCEF:generateSessionId()
	return md5(localPlayer:getName()..localPlayer:getSerial()) -- ToDo: generate serverside with lastlogin timestamp for more security
end

addCommandHandler("phone", function()
	
	PhoneCEF:open()
end)
