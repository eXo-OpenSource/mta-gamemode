
ItemFireworkGroundShell = inherit(Object)

function ItemFireworkGroundShell:constructor(pos)
	-- Klassenvariablen --
	self.m_Position = pos
	self.m_uRocket      = createObject(1598, pos)
	setObjectScale(self.m_uRocket, 0.5);

	self.m_iTimer       = 5000;

	-- Funktionen --

	self.m_funcExplode      = bind(self.explode, self)
	self.m_destructorFunc     = function() delete(self) end
	self.m_renderFunc       = bind(self.render, self)

	addEventHandler("onClientRender", getRootElement(), self.m_renderFunc)
	-- Events --

	setTimer(self.m_destructorFunc, self.m_iTimer+5000, 1)
	setTimer(self.m_funcExplode, self.m_iTimer, 1)
end

function ItemFireworkGroundShell:destructor()
	if(self.m_explosion) then
		self.m_explosion:destructor()
	end

	removeEventHandler("onClientRender", getRootElement(), self.m_renderFunc)

end

function ItemFireworkGroundShell:render()
	if(self.m_explosion) then
		self.m_explosion:render()
	end

	if not(self.m_exploded) then
		local x, y, z = getElementPosition(self.m_uRocket)
		fxAddSparks(x, y, z, 0,0, 1, 1, 1)
	end
end

function ItemFireworkGroundShell:playSound(sSound, iDist)
	local sound = playSound3D("files/audio/Firework/"..sSound, self.m_Position);
	setSoundMaxDistance(sound, (iDist or 250))
end

function ItemFireworkGroundShell:explode()
	self.m_exploded         = true;
	self.m_explosion        = FireworkExplosionSimple:new(self, 16, {}, false);

	destroyElement(self.m_uRocket)
end


