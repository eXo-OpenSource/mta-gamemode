Main = {}

function Main.resourceStart()
	-- Stop useless Resources
	for i, v in pairs(RESOURCES_TO_STOP) do
		local resource = Resource.getFromName(v)
		if resource then
			resource:stop()
		end
	end

	-- Instantiate Core
	core = Core:new()
end
addEventHandler("onResourceStart", resourceRoot, Main.resourceStart, true, "high+99999")

function Main.resourceStop()
	delete(core)
end
addEventHandler("onResourceStop", resourceRoot, Main.resourceStop, true, "low-99999")
