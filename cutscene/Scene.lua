Scene = inherit(Object)

function Scene:constructor(data)
	self.m_Actions = {}
	self.m_ActiveAction = {}
	self.m_Elements = {}
	
	self.m_Uid = data.uid or false
	self.m_Letterbox = data.letterbox == true
	
	for k, v in ipairs(data) do
		self.m_Actions[k] = Action.create(v)
	end
end

function Scene:start()
	self.m_Begin = getTickCount()
end

function Scene:stop()
	for k, v in pairs(self.m_ActiveAction) do
		v:stop(true)
	end
	
	for k, v in pairs(self.m_Elements) do
		destroyElement(v)
	end
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
					if self.m_ActiveAction[v.index].stop then
						self.m_ActiveAction[v.index]:stop()
					end
					self.m_ActiveAction[v.index] = nil
				end
			else
				if v.starttick < now and v.stoptick > now then
					v.index = #self.m_ActiveAction+1
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
	for k, v in pairs(self.m_ActiveAction) do
		if v.render then v:render() end
	end
end