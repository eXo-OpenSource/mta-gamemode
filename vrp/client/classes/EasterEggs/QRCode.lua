EasterEgg.QRCode = inherit(GUIForm3D)
inherit(Singleton, EasterEgg.QRCode)

function EasterEgg.QRCode:constructor()
	GUIForm3D.constructor(self, Vector3(1464.0999755859, -1790.8000488281, 20.700000762939), Vector3(90, 0, 0), Vector2(5, 5), Vector2(300, 300), 50)
end

function EasterEgg.QRCode:onStreamIn(surface)
	local json = toJSON({["player"] = localPlayer:getName(), ["sessionId"] = localPlayer:getSessionId(), ["id"] = localPlayer:getPrivateSync("Id")}, true)
	self.m_Url = ("https://exo-reallife.de/ingame/qr/qr.php?size=300x300&text=https://www.exo-reallife.de/ingame/achievement/qrcode.php?data=%s"):format(json:sub(2, #json-1))
	outputDebug(self.m_Url)
	GUIWebView:new(0, 0, 300, 300, self.m_Url, true, surface)
end
