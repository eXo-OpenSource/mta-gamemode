FireworkPipebombExplosion = inherit(Object)

function FireworkPipebombExplosion:constructor(uRocket)
	-- Klassenvariablen --

	self.m_uRocket          = uRocket;
	self.m_iMaxRoc          = 3;
	self.m_FirstExplo       = FireworkExplosionSimple:new(uRocket, self.m_iMaxRoc, self)

	-- Funktionen --
	self.m_iStartTick           = getTickCount();
	self.m_bNextExplosionDone1   = false;
	self.m_bNextExplosionDone2   = false;

	self.m_tblNewExplos         = {};
	self.m_tblNewExplos2        = {};

	-- Events --
end

function FireworkPipebombExplosion:destructor(...)

end

function FireworkPipebombExplosion:render()
	self.m_FirstExplo:render()

	for index, expl in pairs(self.m_tblNewExplos) do
		expl:render()
	end
	for index, expl in pairs(self.m_tblNewExplos2) do
		expl:render()

	end
	if(getTickCount()-self.m_iStartTick > 1000) then
		if not(self.m_bNextExplosionDone1) then
			self:createNewExplo();
			self.m_bNextExplosionDone1 = true;
		end
	end

end

function FireworkPipebombExplosion:playSound(...)
	return self.m_uRocket:playSound(...);
end

function FireworkPipebombExplosion:createNewExplo(bBool)
	if not(bBool) then
		for i = 1, self.m_iMaxRoc, 1 do
			local uEle = self.m_FirstExplo.m_Vehicle[i];
			if(uEle) then
				local x, y, z = getElementPosition(uEle);
				local rt = {}
				rt.m_uRocket = uEle

				self.m_tblNewExplos[i] = FireworkExplosionSimple:new(rt, math.random(7, 15), self)
			end
		end
	end
end
