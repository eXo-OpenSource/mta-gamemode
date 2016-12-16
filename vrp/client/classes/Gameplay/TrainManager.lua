TrainManager = inherit(Singleton)
addRemoteEvents{"onTrainSync"}

function TrainManager:constructor()
	self.m_Blips = {}

	-- Add some events
	self.m_OnTrainSync = bind(self.onTrainSync, self)
	--self.m_OnTrainStreamIn = bind()
	--self.m_OnTrainStreamOut = bind()

	addEventHandler("onTrainSync", root, self.m_OnTrainSync)
	--addEventHandler("onClientElementStreamIn", root, self.m_OnTrainSync)
	--addEventHandler("onClientElementStreamOut", root, self.m_OnTrainSync)
end

function TrainManager:destructor()
	 for i, v in pairs(self.m_Blips) do
		 delete(v)
	 end
end

function TrainManager:onTrainSync(x, y, z, speed)
	local pos = Vector3(x, y, z) -- Convert to a vector
		if not self.m_Blips[source] then
			self.m_Blips[source] = Blip:new("Train.png", 0, 0)
		end
		self.m_Blips[source]:setPosition(pos.x, pos.y)
	if not isElementStreamedIn(source) then
		source:setPosition(pos)
	else
		source:setTrainSpeed(speed)
	end
end
