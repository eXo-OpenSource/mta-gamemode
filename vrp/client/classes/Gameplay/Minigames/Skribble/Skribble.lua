-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
Skribble = inherit(Singleton)

function Skribble:constructor(size)
	self.m_Size = size
	self.m_Position = Vector2(screenWidth, screenHeight)/2 - self.m_Size/2

	self.m_RenderTarget = DxRenderTarget(self.m_Size)

	self.m_RenderTarget:setAsTarget()
	dxDrawRectangle(0, 0, self.m_Size, Color.White)
	dxSetRenderTarget()

	self.m_DrawColor = Color.Black
	self.m_DrawSize = 1

	--self.m_Render = bind(Skribble.render, self)
	self.m_Move = bind(Skribble.onMove, self)
	addEventHandler("onClientCursorMove", root, self.m_Move)
	--addEventHandler("onClientRender", root, self.m_Render)

	--self.m_SyncTimer = setTimer(bind(Skribble.sync, self), 1000, 0)
end

function Skribble:destructor()
	if isTimer(self.m_SyncTimer) then killTimer(self.m_SyncTimer) end
end

function Skribble:onMove(_, _, x, y)
	if getKeyState("mouse1") then
		if self.m_LastPosition then
			self.m_RenderTarget:setAsTarget()

			self.m_Position = Vector2(SkribbleGUI:getSingleton().m_SkribbleImage:getPosition(true))
			dxDrawLine(self.m_LastPosition - self.m_Position, Vector2(x, y) - self.m_Position, self.m_DrawColor, self.m_DrawSize)
			dxSetRenderTarget()

			SkribbleGUI:getSingleton():anyChange()

		end

		self.m_LastPosition = Vector2(x, y)
	else
		self.m_LastPosition = nil
	end
end

function Skribble:render()
	--dxDrawImage(self.m_Position, 800, 600, self.m_RenderTarget)
end

function Skribble:sync()
	--[[local st = getTickCount()
	local pixels = self.m_RenderTarget:getPixels()
	if md5(pixels) == self.m_LastHash then return end

	self.m_LastHash = md5(pixels)
	local image = dxConvertPixels(pixels, "png")

	outputDebugString(getTickCount() - st)

	local imageFile = fileCreate("skribble.png")
	imageFile:write(image)
	imageFile:close()]]
end
