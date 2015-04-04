Main = {}

-- Require bcrypt module
if not bcrypt_digest then 
	error("Missing bcrypt module")
end

function Main.resourceStart()
	-- Instantiate Core
	core = Core:new()
	
	
end
addEventHandler("onResourceStart", resourceRoot, Main.resourceStart, true, "high+99999")

function Main.resourceStop()
	delete(core)
end
addEventHandler("onResourceStop", resourceRoot, Main.resourceStop, true, "low-99999")
