Scene = inherit(Object)

function Scene:constructor(data, cut)
	self.m_Actions = {}
	self.m_ActiveAction = {}
	self.m_Cutscene = cut

	self.m_Uid = data.uid or false
	self.m_Letterbox = data.letterbox == true

	for k, v in ipairs(data) do
		self.m_Actions[k] = Action.create(v, self)
	end

	-- Not exactly 21/9, but looks better this way
	Scene.LetterboxHeight = ( 9 / 21 * (screenHeight/screenWidth) * screenHeight ) / 3 * 2

	Scene.LetterboxWidth = screenWidth
	Scene.LetterboxY = screenHeight - Scene.LetterboxHeight
end

function Scene:destructor()
	self:stop()
end

function Scene:start()
	self.m_Begin = getTickCount()
end

function Scene:stop()
	for k, v in pairs(self.m_ActiveAction) do
		if v.stop then
			v:stop(true)
		end
	end
	for k, v in pairs(self.m_Actions) do
		delete(v)
	end
end

function Scene:getCutscene()
	return self.m_Cutscene
end

function Scene:preRender()
	local now = getTickCount() - self.m_Begin
	for k, v in pairs(self.m_Actions) do
		if not v.duration then
			if v.starttick < now and not v.wasTriggered then
				v:trigger()
				v.wasTriggered = true
			end
		else

			if self.m_ActiveAction[v.index] then
				if v.stoptick < now then
					if self.m_ActiveAction[v.index].preRender then
						self.m_ActiveAction[v.index]:preRender()
					end
					if self.m_ActiveAction[v.index].stop then
						self.m_ActiveAction[v.index]:stop()
					end
					self.m_ActiveAction[v.index] = nil
					v.index = nil
				end
			else
				if not v.index and v.starttick < now and v.stoptick > now then
					v.index = #self.m_ActiveAction+1
--					outputDebug(v.index)
					self.m_ActiveAction[v.index] = v
					if self.m_ActiveAction[v.index].start then
						self.m_ActiveAction[v.index]:start()
					end
				end
			end
		end
	end

	for k, v in pairs(self.m_ActiveAction) do
		if v.preRender then v:preRender() end
	end
end

function Scene:render()
	if self.m_Letterbox then
		dxDrawRectangle(0, 0, Scene.LetterboxWidth, Scene.LetterboxHeight, tocolor(0, 0, 0), false)
		dxDrawRectangle(0, Scene.LetterboxY, Scene.LetterboxWidth, Scene.LetterboxHeight, tocolor(0, 0, 0), false)
	end

	for k, v in pairs(self.m_ActiveAction) do
		if v.render then v:render() end
	end

	if self.m_Cutscene.m_Debug then
		local now = getTickCount() - self.m_Begin
		dxDrawText(tostring(now), screenWidth - 100, 50, screenWidth, screenHeight)
	end

end
