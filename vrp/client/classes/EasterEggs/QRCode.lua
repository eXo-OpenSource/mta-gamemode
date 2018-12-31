EasterEgg.QRCode = inherit(GUIForm3D)
inherit(Singleton, EasterEgg.QRCode)

function EasterEgg.QRCode:constructor()
	GUIForm3D.constructor(self, Vector3(2752, -2394.22, 827), Vector3(0, 0, 0), Vector2(2, 2), Vector2(300, 300), 15)
end

function EasterEgg.QRCode:onStreamIn(surface)
	local json = toJSON({["sId"] = localPlayer:getSessionId():sub(1, 8), ["id"] = localPlayer:getPrivateSync("Id")}, true)
	self.m_Url = (INGAME_WEB_PATH .. "/ingame/qr/qr.php?size=300x300&text=" .. INGAME_WEB_PATH .. "/ingame/qr/result.php?data=%s"):format(json:sub(2, #json-1))
	outputDebug(self.m_Url)
	GUIWebView:new(0, 0, 300, 300, self.m_Url, true, surface)
end
