FireworkRomanCandleTail = inherit(Object)

function FireworkRomanCandleTail:constructor(uRocket)
	-- Klassenvariablen --
	self.m_uRocket      = uRocket;

	self.m_uMarker      = false;

	self.m_iAlpha       = 255;

	self.m_iDuration    = math.random(2500, 4000);

	self.m_iStartTick   = getTickCount()

	self.m_bSparks      = true;     -- Spakrs
	self.m_bLight       = true;     -- Glow

	self.b_enabled      = true;


	self.m_cLightColor  = {math.random(0, 255), math.random(0, 255), math.random(0, 255), 255}

	-- Funktionen --
	self:launch();

	-- Events --
end

function FireworkRomanCandleTail:destructor()
	if(isElement(self.m_uMarker)) then
		destroyElement(self.m_uMarker);
	end
	if (isElement(self.m_uSparkEffect)) then
		destroyElement(self.m_uSparkEffect)
	end
	if (isElement(self.m_uMarker)) then
		destroyElement(self.m_uMarker)
	end
	if (isElement(self.m_uLight)) then
		destroyElement(self.m_uLight)
	end
end

function FireworkRomanCandleTail:render()
	if(self.b_enabled) then
		local pos = self.m_uRocket:getPosition()
		local rot = Vector3(0, 0, 0);


		if(self.m_bSparks) then
			setElementPosition(self.m_uSparkEffect, pos:getX(), pos:getY(), pos:getZ());
			setElementPosition(self.m_uMarker, pos:getX(), pos:getY(), pos:getZ());
			setElementPosition(self.m_uLight, pos:getX(), pos:getY(), pos:getZ());
			setElementRotation(self.m_uSparkEffect, rot:getX()+90, rot:getY(), rot:getZ());
		end

		if(self.m_bLight) then
			local sWert = 1-math.abs((getTickCount()-self.m_iStartTick)/self.m_iDuration)

			self.m_Alpha = sWert*200

			if(self.m_Alpha >= 255) then
				self.m_Alpha = 255;
			end
			if(self.m_Alpha <= 0) then
				self.m_Alpha = 0;
			--	self:destructor();
			end
			setMarkerColor(self.m_uMarker, self.m_cLightColor[1], self.m_cLightColor[2], self.m_cLightColor[3], self.m_Alpha)
			setLightRadius(self.m_uLight, self.m_Alpha/10)
		end
	end
end

function FireworkRomanCandleTail:launch()

	--local x, y, z = getElementPosition(self.m_uRocket.m_uRocket);

	if(self.m_bSparks) then
		self.m_uSparkEffect     = createEffect("prt_spark", self.m_uRocket:getPosition());
		setEffectSpeed(self.m_uSparkEffect, 1)
		setElementRotation(self.m_uSparkEffect, 0, -90, 0);
	end
	if(self.m_bLight) then
		self.m_uMarker = createMarker(self.m_uRocket:getPosition(), "corona", math.random(10, 15)/10, unpack(self.m_cLightColor));
		self.m_uLight = createLight(0, self.m_uRocket:getPosition(), math.random(10, 15)/10, unpack(self.m_cLightColor));
	end

	self.m_uRocket:playSound("launch_motar_"..math.random(1, 2)..".ogg", 150, true);
end






