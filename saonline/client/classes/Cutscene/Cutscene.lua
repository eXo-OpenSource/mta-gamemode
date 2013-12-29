Cutscene = inherit(Object)

function Cutscene:constructor(data)
	self.m_Name = data.name
	self.m_Startscene = data.startscene
	self.m_Elements = {}
	
	self.m_Scene = {}
	self.m_ActiveScene = false
	self.m_Debug = data.debug
	for k, v in ipairs(data) do
		local scene = Scene:new(v, self)
		self.m_Scene[scene.m_Uid] = scene
	end
	
	self.m_fnRender = bind(Cutscene.render, self)
	self.m_fnPreRender = bind(Cutscene.preRender, self)
end

function Cutscene:destructor()
	if self.m_ActiveScene then
		self:stop()
	end
end

function Cutscene:setScene(uid)
	assert(self.m_Scene[uid], "Invalid Scene")
	self.m_ActiveScene = self.m_Scene[uid]
	self.m_Scene[uid]:start()
end

function Cutscene:play()
	self.m_ActiveScene = self.m_Scene[self.m_Startscene]
	self.m_Scene[self.m_Startscene]:start()
	
	addEventHandler("onClientRender", root, self.m_fnRender)
	addEventHandler("onClientPreRender", root, self.m_fnPreRender)
end

function Cutscene:stop()
	self.m_ActiveScene:stop()
	self.m_ActiveScene = false
	
	removeEventHandler("onClientRender", root, self.m_fnRender)
	removeEventHandler("onClientPreRender", root, self.m_fnPreRender)
	
	for k, v in pairs(self.m_Elements) do
		destroyElement(v)
	end
	outputDebug("pre on finish")
	if self.onFinish then
	outputDebug("in on finish")
		self:onFinish()
	end
	outputDebug("post on finish")
end

function Cutscene:render()
	if self.m_ActiveScene then
		self.m_ActiveScene:render()
	end
end

function Cutscene:preRender()
	if self.m_ActiveScene then
		self.m_ActiveScene:preRender()
	end
end
