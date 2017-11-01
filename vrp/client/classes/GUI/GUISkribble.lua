-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
GUISkribble = inherit(GUIElement)

function GUISkribble:constructor(posX, posY, width, height, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)

	self.m_SyncData = {}
	self.m_RestorableDrawData = {}
	self.m_DrawSize = 1
	self.m_DrawColor = Color.Black
	self.m_DrawingEnabled = false

	self.m_RenderTarget = DxRenderTarget(self.m_Width, self.m_Height)
	self:clear(true)

	self.m_CursorMoveFunc = bind(GUISkribble.onCursorMove, self)
	self.m_RenderFunc = bind(GUISkribble.onClientRender, self)
	self.m_RestoreFunc = bind(GUISkribble.onClientRestore, self)
	addEventHandler("onClientCursorMove", root, self.m_CursorMoveFunc)
	addEventHandler("onClientRender", root, self.m_RenderFunc)
	addEventHandler("onClientRestore", root, self.m_RestoreFunc)
end

function GUISkribble:virtual_destructor()
	if isElement(self.m_RenderTarget) then self.m_RenderTarget:destroy() end
	removeEventHandler("onClientCursorMove", root, self.m_CursorMoveFunc)
	removeEventHandler("onClientRender", root, self.m_RenderFunc)
	removeEventHandler("onClientRestore", root, self.m_RestoreFunc)
end

function GUISkribble:drawThis()
	dxSetBlendMode("modulate_add")
	dxDrawImage(math.floor(self.m_AbsoluteX), math.floor(self.m_AbsoluteY), self.m_Width, self.m_Height, self.m_RenderTarget)
	dxSetBlendMode("blend")
end

function GUISkribble:onCursorMove(_, _, x, y)
	if not self.m_DrawingEnabled then return end

	if getKeyState("mouse1") and self.m_Hover then
		local cursorPosition = Vector2(x, y)

		if self.m_LastPosition then
			local pos = Vector2(self:getPosition(true))
			local textWidth = dxGetTextWidth(FontAwesomeSymbols.Circle, .5, FontAwesome(self.m_DrawSize))
			local drawSize = Vector2(textWidth, textWidth)
			local drawStart = (self.m_LastPosition - pos)
			local drawEnd = cursorPosition - pos
			local interpolateCount = math.ceil((drawStart - drawEnd).length)

			self.m_RenderTarget:setAsTarget()
			for i = 1, interpolateCount do
				local drawStart = Vector2(interpolateBetween(drawStart.x, drawStart.y, 0, drawEnd.x, drawEnd.y, 0, i/interpolateCount, "Linear"))
				dxDrawText(FontAwesomeSymbols.Circle, drawStart - drawSize/2, Vector2(0,0), self.m_DrawColor, .5, FontAwesome(self.m_DrawSize))
			end

			dxSetRenderTarget()

			table.insert(self.m_SyncData, {type = 1, start = {drawStart.x, drawStart.y}, to = {drawEnd.x, drawEnd.y}, color = self.m_DrawColor, size = self.m_DrawSize})
			table.insert(self.m_RestorableDrawData, {type = 1, start = {drawStart.x, drawStart.y}, to = {drawEnd.x, drawEnd.y}, color = self.m_DrawColor, size = self.m_DrawSize})
			if self.m_DrawHook then
				self.m_DrawHook({type = 1, start = {drawStart.x, drawStart.y}, to = {drawEnd.x, drawEnd.y}, color = self.m_DrawColor, size = self.m_DrawSize})
			end
			self:anyChange()
		end

		self.m_LastPosition = cursorPosition
		self.m_LastMoveTick = getTickCount()
	else
		self.m_LastPosition = nil
	end
end

function GUISkribble:onInternalLeftClick(x, y)
	if not self.m_DrawingEnabled then return end

	local cursorPosition = Vector2(x, y)

	if self.m_LastMoveTick and getTickCount() - self.m_LastMoveTick < 5 then return end
	if self.m_LastClickPosition and (self.m_LastClickPosition - cursorPosition).length == 0 then return end
	self.m_LastClickPosition = cursorPosition

	local pos = Vector2(self:getPosition(true))
	local textWidth = dxGetTextWidth(FontAwesomeSymbols.Circle, .5, FontAwesome(self.m_DrawSize))
	local drawSize = Vector2(textWidth, textWidth)
	local drawStart = cursorPosition - pos

	self.m_RenderTarget:setAsTarget()
	dxDrawText(FontAwesomeSymbols.Circle, drawStart - drawSize/2, Vector2(0,0), self.m_DrawColor, .5, FontAwesome(self.m_DrawSize))
	dxSetRenderTarget()

	table.insert(self.m_SyncData, {type = 2, start = {drawStart.x, drawStart.y}, color = self.m_DrawColor, size = self.m_DrawSize})
	table.insert(self.m_RestorableDrawData, {type = 2, start = {drawStart.x, drawStart.y}, color = self.m_DrawColor, size = self.m_DrawSize})
	if self.m_DrawHook then
		self.m_DrawHook({type = 2, start = {drawStart.x, drawStart.y}, color = self.m_DrawColor, size = self.m_DrawSize})
	end
	self:anyChange()
end

function GUISkribble:onClientRender()
	if isCursorShowing() and self.m_Hover and self.m_DrawingEnabled then
		setCursorAlpha(0)
		local cx, cy = getCursorPosition()

		if cx then
			local textWidth = dxGetTextWidth(FontAwesomeSymbols.Circle, .5, FontAwesome(self.m_DrawSize))
			local drawSize = Vector2(textWidth, textWidth)
			local drawStart = Vector2(cx * screenWidth, cy * screenHeight)

			dxDrawText(FontAwesomeSymbols.Circle, drawStart - drawSize/2, Vector2(0,0), self.m_DrawColor, .5, FontAwesome(self.m_DrawSize))
		end
	end
end

function GUISkribble:clear(hard, drawRestoreData)
	self.m_RenderTarget:setAsTarget()
	dxDrawRectangle(0, 0, self.m_Width, self.m_Height, Color.White)
	dxSetRenderTarget()

	self:anyChange()

	if hard then
		self.m_SyncData = {}
		self.m_RestorableDrawData = {}
		return
	end

	if self.m_DrawingEnabled and not drawRestoreData then
		table.insert(self.m_SyncData, {type = 0})
		table.insert(self.m_RestorableDrawData, {type = 0})
	end
end

function GUISkribble:setDrawingEnabled(state)
	self.m_DrawingEnabled = state
end

function GUISkribble:setDrawColor(color)
	self.m_DrawColor = color
end

function GUISkribble:setDrawSize(size)
	self.m_DrawSize = size
end

function GUISkribble:getSyncData(reset)
	local syncData = self.m_SyncData
	if reset then self.m_SyncData = {} end
	return syncData
end

function GUISkribble:drawSyncData(data, drawRestoreData)
	for _, draw in ipairs(data) do
		if draw.type == 0 then
			self:clear(false, drawRestoreData)
		elseif draw.type == 1 then
			local drawStart = Vector2(unpack(draw.start))
			local drawEnd = Vector2(unpack(draw.to))
			local textWidth = dxGetTextWidth(FontAwesomeSymbols.Circle, .5, FontAwesome(draw.size))
			local drawSize = Vector2(textWidth, textWidth)
			local interpolateCount = math.ceil((drawStart - drawEnd).length)

			self.m_RenderTarget:setAsTarget()
			for i = 1, interpolateCount do
				local drawStart = Vector2(interpolateBetween(drawStart.x, drawStart.y, 0, drawEnd.x, drawEnd.y, 0, i/interpolateCount, "Linear"))
				dxDrawText(FontAwesomeSymbols.Circle, drawStart - drawSize/2, Vector2(0,0), draw.color, .5, FontAwesome(draw.size))
			end
			dxSetRenderTarget()

			self:anyChange()
		elseif draw.type == 2 then
			local drawStart = Vector2(unpack(draw.start))
			local textWidth = dxGetTextWidth(FontAwesomeSymbols.Circle, .5, FontAwesome(draw.size))
			local drawSize = Vector2(textWidth, textWidth)

			self.m_RenderTarget:setAsTarget()
			dxDrawText(FontAwesomeSymbols.Circle, drawStart - drawSize/2, Vector2(0,0), draw.color, .5, FontAwesome(draw.size))
			dxSetRenderTarget()
		end

		if not drawRestoreData then
			table.insert(self.m_RestorableDrawData, draw)
		end
	end
end

function GUISkribble:onClientRestore(didClearRenderTargets)
	if didClearRenderTargets then
		self:clear(false, true)

		if #self.m_RestorableDrawData > 0 then
			self:drawSyncData(self.m_RestorableDrawData, true)
		end
	end
end

function GUISkribble:addDrawHook(callback)
	self.m_DrawHook = callback
end
