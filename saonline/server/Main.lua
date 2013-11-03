Main = {}

function Main.resourceStart()
	-- Instantiate Core
	core = Core:new()
	
	
end
addEventHandler("onResourceStart", resourceRoot, Main.resourceStart, true, "high+99999")
