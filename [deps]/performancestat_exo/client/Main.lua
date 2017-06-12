Main = {}

function Main.onStart()
	local file = fileOpen("client_config.json")
	Main.m_Config = fromJSON(file:read(file:getSize()))["config"]
	file:close()


	outputDebugString("true!")
	Main.m_Collector = Collector:new(false)
end

function Main.onStop()
	delete(Main.m_Collector)
end

addEventHandler("onClientResourceStart", getThisResource():getRootElement(), Main.onStart)
addEventHandler("onClientResourceStop",  getThisResource():getRootElement(), Main.onStop)
