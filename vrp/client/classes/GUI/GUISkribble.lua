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
	self.m_DrawSize = 1
	self.m_DrawColor = Color.Black

	self.m_RenderTarget = DxRenderTarget(self.m_Width, self.m_Height)
	self:clear()

	self.m_CursorMoveFunc = bind(self.onCursorMove, self)
	addEventHandler("onClientCursorMove", root, self.m_CursorMoveFunc)
end

function GUISkribble:virtual_destructor()
	outputChatBox("virtual_destructor")

	removeEventHandler("onClientCursorMove", root, self.m_CursorMoveFunc)
end

function GUISkribble:drawThis()
	dxSetBlendMode("modulate_add")
	dxDrawImage(math.floor(self.m_AbsoluteX), math.floor(self.m_AbsoluteY), self.m_Width, self.m_Height, self.m_RenderTarget)
	dxSetBlendMode("blend")
end

function GUISkribble:onCursorMove(_, _, x, y)
	if getKeyState("mouse1") and self.m_Hover then
		if self.m_LastPosition then
			local cursorPosition = Vector2(x, y)


			local pos = Vector2(self:getPosition(true))
			local drawStart = self.m_LastPosition - pos
			local drawEnd = Vector2(x, y) - pos
			self.m_RenderTarget:setAsTarget()
			if (self.m_LastPosition - cursorPosition).length < self.m_DrawSize/2 then
				local drawSize = Vector2(self.m_DrawSize, self.m_DrawSize)
				dxDrawRectangle(drawStart - drawSize/2, drawSize, self.m_DrawColor)
			else
				dxDrawLine(drawStart, drawEnd, self.m_DrawColor, self.m_DrawSize)
			end

			dxSetRenderTarget()

			table.insert(self.m_SyncData, {pos = {drawStart.x, drawStart.y}, to = {drawEnd.x, drawEnd.y}, type = 0, color = self.m_DrawColor, size = self.m_DrawSize})

			self:anyChange()
		end

		self.m_LastPosition = Vector2(x, y)
	else
		self.m_LastPosition = nil
	end
end

function GUISkribble:clear()
	self.m_RenderTarget:setAsTarget()
	dxDrawRectangle(0, 0, self.m_Width, self.m_Height, Color.White)
	dxSetRenderTarget()

	self.m_SyncData = {}
	self:anyChange()
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
