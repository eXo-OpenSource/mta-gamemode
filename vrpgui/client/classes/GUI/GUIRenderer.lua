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
	GUIElement.ms_ClickProcessed = false
	GUIElement.ms_ClickDownProcessed = false
	GUIElement.ms_CacheAreaRetrievedClick = false

	for k = #GUIRenderer.cache, 1, -1 do
		local v = GUIRenderer.cache[k]
		if v.m_Visible and v.update then
			v:update(elapsedTime)
		end
		if v.m_ContainsGUIElements and v.m_Visible then
			v:performChecks()
		end
	end
	
	if not GUIElement.ms_ClickProcessed then
		--GUIRenderer.process3DMouse()
	end
end

function GUIRenderer.process3DMouse()
	local cx, cy = getCursorPosition()
	local wx1, wy1, wz1 = getWorldFromScreenPosition(cx, cy, 1)
	local wx2, wy2, wz2 = getWorldFromScreenPosition(cx, cy, 2)
	
	local offx, offy, offz = wx2-wx1, wy1-wy2, wz1-wz2
	
	for k, ca in pairs(GUIRenderer.ms_3DGUIs) do
		if ca:isVisible() then
			--[[
				wx1 + a* offx = ca.StartX + b * ca.EndX + c * ca.SecPosX
				wy1 + a* offy = ca.StartY + b * ca.EndY + c * ca.SecPosY
				wz1 + a* offz = ca.StartZ + b * ca.EndZ + c * ca.SecPosZ
			]]
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

function GUIRenderer.add3DGUI(gui)
	GUIRenderer.ms_3DGUIs[gui] = gui
end

function GUIRenderer.remove3DGUI(gui)
	GUIRenderer.ms_3DGUIs[gui] = nil
end

GUIRenderer:new()
