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
	self.m_WebView = GUIWebView:new(0, 0, self.m_Width, self.m_Height, "http://exo-reallife.de/ingame/phone/phone.php?player="..getPlayerName(getLocalPlayer()).."&sessionID="..self:generateSessionId(), true, self)
	Browser.requestDomains{"exo-reallife.de", "maxcdn.bootstrapcdn.com"}
end

function PhoneCEF:destructor()
	GUIWebForm.destructor(self)
end

function PhoneCEF:onShow()
end

function PhoneCEF:onHide()
end

function PhoneCEF:generateSessionId()
	return md5(localPlayer:getName()..localPlayer:getSerial()) -- ToDo: generate serverside with lastlogin timestamp for more security
end
