FireworkExplosionSimple = inherit(Object)


function FireworkExplosionSimple:constructor(uRocket, iAm, rb, bNewSound)
	-- Klassenvariablen --
	self.m_uRocket          = uRocket;

	self.m_uRocketRocket    = uRocket.m_uRocket;

	self.m_bRB              = rb;
	self.m_bNewSound        = bNewSound

	self.m_Vehicle      = {};
	self.m_Effects      = {};
	self.m_Marker       = {};

	self.m_Alpha        = 255;

	self.m_iMaxVehicles = (iAm or math.random(10, 20));

	self.m_iStartTick   = getTickCount();

	-- Funktionen --

	self:explode();

	-- Events --
end

function FireworkExplosionSimple:destructor()
	for i = 1, self.m_iMaxVehicles, 1 do
		if(self.m_Vehicle[i]) then
			destroyElement(self.m_Vehicle[i])
			destroyElement(self.m_Effects[i])
			destroyElement(self.m_Marker[i])

			self.m_Vehicle[i] = nil;
			self.m_Effects[i] = nil;
			self.m_Marker[i] = nil;
		end
	end
end

function FireworkExplosionSimple:render()
	local sWert = 1-math.abs((getTickCount()-self.m_iStartTick)/2500)

	self.m_Alpha = sWert*200

	if(self.m_Alpha >= 255) then
		self.m_Alpha = 255;
	end
	if(self.m_Alpha <= 0) then
		self.m_Alpha = 0;
		self:destructor();
	end

	for i = 1, self.m_iMaxVehicles do
		if(self.m_Marker[i]) then
			local r, g, b = getMarkerColor(self.m_Marker[i])
			setMarkerColor(self.m_Marker[i], r, g, b, self.m_Alpha)
		end

		if(self.m_Effects[i]) then
			local x, y, z = getElementPosition(self.m_Vehicle[i])
			setElementPosition(self.m_Effects[i], x, y, z);
		end
	end


end

function FireworkExplosionSimple:destroyVehicle(iI)
	destroyElement(self.m_Vehicle[iI])
	destroyElement(self.m_Effect[iI])
	self.m_Vehicle[iI] = nil;
	self.m_Effect[iI] = nil;
end

function FireworkExplosionSimple:explode()

	local randColor1 = {math.random(0, 255), math.random(0, 255), math.random(0, 255), 255}
	local randColor2 = {math.random(0, 255), math.random(0, 255), math.random(0, 255), 255}

	local x, y, z = getElementPosition(self.m_uRocketRocket)

	if not(self.m_bNewSound) then
		if(self.m_bRB) then
			if(self.m_bRB.playSound) then
				self.m_bRB:playSound("explode_kugelbombe_"..math.random(1, 3)..".ogg", 350);
			else
				self.m_uRocket:playSound("explode_kugelbombe_"..math.random(1, 3)..".ogg", 350);
			end
		else
			self.m_uRocket:playSound("explode_rocket_"..math.random(1, 2)..".ogg", 350);
		end
	else
		self.m_uRocket:playSound("explode_rocket_"..math.random(1, 2)..".ogg", 350);
	end

	for i = 1, self.m_iMaxVehicles do

		self.m_Vehicle[i] = createVehicle(594, x, y, z)

		self.m_Effects[i]   = createEffect("prt_spark", x, y, z);

		setElementRotation(self.m_Effects[i], 0, -90, 0)
		setElementAlpha(self.m_Vehicle[i], 0)

		local r, g, b, a;

		if((i % 2) == 0) then
			r, g, b, a 	= unpack(randColor1)
		else
			r, g, b, a 	= unpack(randColor2)
		end

		self.m_Marker[i]       = createMarker(x, y, z, "corona", 5.0, r, g, b, self.m_Alpha);
		attachElements(self.m_Marker[i], self.m_Vehicle[i])

		local newX, newY = self:getPointFromDistanceRotation(x, y, 2, 360 * (i/self.m_iMaxVehicles))
		setElementVelocity(self.m_Vehicle[i], (newX-x)/self.m_iMaxVehicles+math.random(-5, 5)/10, (newY-y)/self.m_iMaxVehicles+math.random(-5, 5)/10, math.random(1, 5)/10)

		createExplosion(x, y, z, 5, false, 1.0, false)
	end
end

function FireworkExplosionSimple:getPointFromDistanceRotation(x, y, dist, angle)
	local a = math.rad(90 - angle);

	local dx = math.cos(a) * dist;
	local dy = math.sin(a) * dist;

	return x+dx, y+dy;
end
