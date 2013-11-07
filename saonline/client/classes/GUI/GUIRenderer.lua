-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIRenderer.lua
-- *  PURPOSE:     GUI renderer class
-- *
-- ****************************************************************************

GUIRenderer = {cache = {}}

function GUIRenderer.constructor()	
	-- Create a default cache area
	GUIRenderer.cacheroot = CacheArea:new(0, 0, screenWidth, screenHeight, true)
	
	addEventHandler("onClientPreRender", root, GUIRenderer.updateAll)
	addEventHandler("onClientRender", root, GUIRenderer.drawAll)
	addEventHandler("onClientRestore", root, GUIRenderer.restore)
end

function GUIRenderer.destructor()
	removeEventHandler("onClientPreRender", root, GUIRenderer.updateAll)
	removeEventHandler("onClientRender", root, GUIRenderer.drawAll)
end

function GUIRenderer.updateAll()
	for k, v in ipairs(GUIRenderer.cache) do
		if v.m_ContainsGUIElements then
			v:performChecks()
		end
	end
end

function GUIRenderer.drawAll()
	for k, v in ipairs(GUIRenderer.cache) do
		v:draw()
	end
end

function GUIRenderer.restore(clearedRenderTargets)
	if clearedRenderTargets then
		-- Redraw render target(s)
		GUIRenderer.cacheroot:updateArea()
	end
end

function GUIRenderer.addRef(ref)
	table.insert(GUIRenderer.cache, ref)
end

function GUIRenderer.removeRef(ref)
	local idx = table.find(GUIRenderer.cache, ref)
	if not idx then
		return false
	end
	table.remove(GUIRenderer.cache, idx)
	return true
end
