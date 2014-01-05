-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIRenderer.lua
-- *  PURPOSE:     GUI renderer class
-- *
-- ****************************************************************************
GUIRenderer = inherit(Object)
GUIRenderer.cache = {}

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

function GUIRenderer.updateAll(elapsedTime)
	for k = #GUIRenderer.cache, 1, -1 do
		local v = GUIRenderer.cache[k]
		if v.m_Visible and v.update then
			v:update(elapsedTime)
		end
		if v.m_ContainsGUIElements and v.m_Visible then
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
	--if clearedRenderTargets then
		-- Redraw render target(s)
		GUIRenderer.cacheroot:updateArea()
		
		for k, v in ipairs(GUIRenderer.cache) do
			v:updateArea()
		end
	--end
end

function GUIRenderer.addToDrawList(ref, position)
	table.insert(GUIRenderer.cache, position or #GUIRenderer.cache+1, ref)
end

function GUIRenderer.removeFromDrawList(ref)
	local idx = table.find(GUIRenderer.cache, ref)
	if not idx then
		return false
	end
	table.remove(GUIRenderer.cache, idx)
	return true
end

GUIRenderer:new()
