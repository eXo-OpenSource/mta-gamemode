TrainManager = inherit(Singleton)
addRemoteEvents{"onTrainSync"}

function TrainManager:constructor()
	self.m_Blips = {}
	addEventHandler("onTrainSync", root, bind(self.onTrainSync, self))
end

function TrainManager:destructor()
	 for i, v in pairs(self.m_Blips) do
		 delete(v)
	 end
end

function TrainManager:onTrainSync(x, y, z, attachedElement)
	if not self.m_Blips[source] then
		self.m_Blips[source] = Blip:new("Train.png", 0, 0, 200)
	end
	if attachedElement then
		if not self.m_Blips[source]:getAttachedElement() then
			self.m_Blips[source]:attachTo(attachedElement)
		end
	else
		if self.m_Blips[source]:getAttachedElement() then
			self.m_Blips[source]:detach()
		end
		self.m_Blips[source]:setPosition(x, y)
	end
end
