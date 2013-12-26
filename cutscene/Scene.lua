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
			if v.starttick < now then
				v:trigger()
			end
		else
	
			if self.m_ActiveAction[v.index] then
				if v.stoptick < now then
					self.m_ActiveAction[v.index]:stop()
					self.m_ActiveAction[v.index] = nil
				end
			else
				if v.starttick < now and v.stoptick > now then
					v.index = #self.m_ActiveAction+1
					self.m_ActiveAction[v.index] = v
					self.m_ActiveAction[v.index]:start()
				end
			end
		end
	end
	
	for k, v in pairs(self.m_ActiveAction) do
		v:preRender()
	end
end

function Scene:render()
	for k, v in pairs(self.m_ActiveAction) do
		v:render()
	end
end