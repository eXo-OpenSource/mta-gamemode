-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIRenderer.lua
-- *  PURPOSE:     GUI renderer class
-- *
-- ****************************************************************************
GUIRenderer = inherit(Object)
GUIRenderer.cache = {}
GUIRenderer.ms_3DGUIs = {}

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

function GUIRenderer.reattachEvents()
	removeEventHandler("onClientPreRender", root, GUIRenderer.updateAll)
	removeEventHandler("onClientRender", root, GUIRenderer.drawAll)
	addEventHandler("onClientPreRender", root, GUIRenderer.updateAll)
	addEventHandler("onClientRender", root, GUIRenderer.drawAll)
end


function GUIRenderer.updateAll(elapsedTime)
	GUIElement.ms_ClickProcessed = false
	GUIElement.ms_ClickDownProcessed = false
	GUIElement.ms_CacheAreaRetrievedClick = false
	GUIElement.ms_HoveredElement = false

	for k = #GUIRenderer.cache, 1, -1 do
		local v = GUIRenderer.cache[k]
		if v then
			if v.m_Visible and v.update then
				v:update(elapsedTime)
			end
			if v.m_ContainsGUIElements and v.m_Visible then
				v:performChecks()
			end
		end
	end

	GUITooltip.checkTooltip()

	if not GUIElement.ms_ClickProcessed then
		GUIRenderer.process3DMouse()
	end

	if not GUIElement.ms_ClickProcessed then
		ClickHandler:getSingleton():invokeClick()
	else
		ClickHandler:getSingleton():clearClickInfo()
	end
end

function GUIRenderer.process3DMouse()
	local cx, cy = getCursorPosition()
	if not cx then
		return
	end

	-- Convert relative to absolute coordinates
	cx = cx*screenWidth
	cy = cy*screenHeight

	-- Retrieve mouse states
	local mouse1, mouse2 = getKeyState("mouse1"), getKeyState("mouse2")

	-- Make coordinates for a 3D line a long the cursor (orthogonal to the camera)
	local wx1, wy1, wz1 = getWorldFromScreenPosition(cx, cy, 3)
	local wx2, wy2, wz2 = getWorldFromScreenPosition(cx, cy, 5)

	-- Make a 3D line described by a position and direction vector
	local cursorPos = Vector3(wx1, wy1, wz1)
	local cursorDir = Vector3(wx2-wx1, wy2-wy1, wz2-wz1)

	for k, ca in pairs(GUIRenderer.ms_3DGUIs) do
		if ca:isVisible() then
			-- Make 3D plane described by a position vector and two direction vectors
			local caStart = ca.m_3DStart
			local caV1 = ca.m_3DEnd - ca.m_3DStart
			local caV2 = ca.m_SecPos - ca.m_3DStart

			-- Calculate intersection point between plane and line (solves a linear equation system)
			local vecIntersection = math.line_plane_intersection(cursorPos, cursorDir, caStart, caV1, caV2)

			-- Perform mouse click in case of intersection
			if vecIntersection then
				ca:performMouse(vecIntersection, mouse1, mouse2)
			else
				ca:unhoverChildren()
			end
		end
	end
end

function GUIRenderer.drawAll()
	if DEBUG then ExecTimeRecorder:getSingleton():startRecording("UI/GUIRenderer") end
	for i = 1, #GUIRenderer.cache do
		GUIRenderer.cache[i]:draw()
	end
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/GUIRenderer", #GUIRenderer.cache) end
end

function GUIRenderer.restore(clearedRenderTargets)
	--if clearedRenderTargets then
		-- Redraw render target(s)
		GUIRenderer.cacheroot:updateArea()

		for i = 1, #GUIRenderer.cache do
			GUIRenderer.cache[i]:updateArea()
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
