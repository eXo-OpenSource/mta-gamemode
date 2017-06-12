Main = {}

function Main.onStart()
	Main.m_Collector = Collector:new()
end

function Main.onStop()
	delete(Main.m_Collector)
end

addEventHandler("onResourceStart", getThisResource():getRootElement(), Main.onStart)
addEventHandler("onResourceStop",  getThisResource():getRootElement(), Main.onStop)
