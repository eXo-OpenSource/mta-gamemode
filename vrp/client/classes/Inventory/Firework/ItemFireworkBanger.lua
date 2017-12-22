ItemFireworkBanger = inherit(Object)

function ItemFireworkBanger:constructor(pos)
	self.m_Position = pos

	-- Funktionen --
	self.m_funcRender       = bind(self.render, self)
	self.m_funcBumm         = bind(self.bumm, self)
	addEventHandler("onClientRender", getRootElement(), self.m_funcRender)
	-- Events --

	setTimer(self.m_funcBumm, math.random(3000, 4000), 1);
end

function ItemFireworkBanger:destructor()
	local pos = self.m_Position
	fxAddSparks(pos.x, pos.y, pos.z-1, 0, 0, 1, 5, 25)
	fxAddBulletImpact(pos.x, pos.y, pos.z-1, 0, 0, 1, 15, 3, 1)
	removeEventHandler("onClientRender", getRootElement(), self.m_funcRender)
end

function ItemFireworkBanger:render()
	local x, y, z = self.m_Position.x, self.m_Position.y, self.m_Position.z-0.5;
	fxAddSparks(self.m_Position, 0,0, 1, 1, 1)

end

function ItemFireworkBanger:bumm()
	local s = playSound3D("files/audio/Firework/explode_firecracker_"..math.random(1, 3)..".ogg", self.m_Position);

	setSoundMaxDistance(s, 250)
	delete(self)
end



