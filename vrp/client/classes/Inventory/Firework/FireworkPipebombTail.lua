FireworkPipebombTail = inherit(Object)

function FireworkPipebombTail:constructor(uRocket)
	-- Klassenvariablen --
	self.m_uRocket      = uRocket;

	self.m_uMarker      = false;

	self.m_iHeight      = 1.5;       -- Hoehe

	self.m_iTime        = self.m_uRocket.m_tblTimer["doExplosion"][1]-self.m_uRocket.m_tblTimer["launchRocket"][1];     -- Zeit in MS wie lange er Braucht

	self.m_cLightColor  = {255, 255, 255, 200}

	self:launch();
end

function FireworkPipebombTail:destructor()
	if(isElement(self.m_uMarker)) then
		destroyElement(self.m_uMarker);
	end
end

function FireworkPipebombTail:render()
	local pos = Vector3(getElementPosition(self.m_uRocket.m_uRocket));
	local rot = Vector3(getElementRotation(self.m_uRocket.m_uRocket));

end

function FireworkPipebombTail:launch()
	setTimer(function()
		local x, y, z = getElementPosition(self.m_uRocket.m_uRocket);
		createExplosion(x, y, z+1, 12, false, 1.0, false)

		self.m_uMarker      = createMarker(x, y, z, "corona", 0.5, unpack(self.m_cLightColor));

		attachElements(self.m_uMarker, self.m_uRocket.m_uRocket)

		setElementPosition(self.m_uRocket.m_uRocket, x, y, z+1)
		setElementFrozen(self.m_uRocket.m_uRocket, false);
		setElementVelocity(self.m_uRocket.m_uRocket, (math.random(-3, 3)/10), (math.random(-3, 3)/10), self.m_iHeight)

		fxAddSparks(x, y, z-0.3, 0, 0, 3, 5, 100, 0, 0, 0, true, 1, 2)

	end, 500, 1)

	self.m_uRocket:playSound("launch_kugelbombe_"..math.random(1, 3)..".ogg", 150, true);

	local x, y, z = getElementPosition(self.m_uRocket.m_uRocket);
	fxAddSparks(x, y, z, 0, 0, 2, 5, 10)

	createExplosion(x, y, z, 12, false, 1.0, false)
end





