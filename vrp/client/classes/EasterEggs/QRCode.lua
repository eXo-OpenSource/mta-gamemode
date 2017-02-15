EasterEgg.QRCode = inherit(GUIForm3D)
inherit(Singleton, EasterEgg.QRCode)

function EasterEgg.QRCode:constructor()
	GUIForm3D.constructor(self, Vector3(1464.0999755859, -1790.8000488281, 20.700000762939), Vector3(90, 0, 0), Vector2(5, 5), Vector2(300, 300), 50)
end

function EasterEgg.QRCode:onStreamIn(surface)
	local data = {["player"] = localPlayer:getName(), ["sessionId"] = localPlayer:getSessionId(), ["id"] = localPlayer:getPrivateSync("Id")}
	self.m_Url = ("https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=https://www.exo-reallife.de/ingame/achievement/qrcode.php?data=%s"):format(toJSON(data, true))
	outputDebug(self.m_Url)
	GUIWebView:new(0, 0, 300, 300, self.m_Url, true, surface)
end
