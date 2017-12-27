FireworkRomanCandleRocket = inherit(Object)

function FireworkRomanCandleRocket:constructor(pos)
	-- Klassenvariablen --
	self.m_Position       = pos

	self.m_uRocket          = createVehicle(594, pos.x, pos.y, pos.z-1);
	setElementFrozen(self.m_uRocket, true);
	setElementAlpha(self.m_uRocket, 0)

	self.m_Tail              = false; --FireworkRomanCandleRocketSchweif:new(self);

	self.m_bLaunched        = false;
	self.m_iState           = 0; -- am Boden

	self.m_tblTimer         = {};
	self.m_timer            = {};

	-- Funktionen --

	self.m_funcRender       = function(...) self:event_render(...) end

	self.bindedFunc_launchRocket        = bind(self.launchRocket, self)
	self.bindedFunc_destructor          = function () delete(self) end

	self:initTimer();
	-- Events --

	addEventHandler("onClientRender", getRootElement(), self.m_funcRender);
end

function FireworkRomanCandleRocket:destructor()
	delete(self.m_Tail)

	destroyElement(self.m_uRocket);

	removeEventHandler("onClientRender", getRootElement(), self.m_funcRender);
end

function FireworkRomanCandleRocket:event_render()
	if(self.m_iState == 0) then
		-- Am Boden

	elseif(self.m_iState == 1) then
		-- Luft
		self.m_Tail:render();
	end
end

function FireworkRomanCandleRocket:launchRocket()
	self.m_iState = 1;

	self.m_Tail              = FireworkRomanCandleTail:new(self);
end

function FireworkRomanCandleRocket:initTimer()

	self.bindedFunc_launchRocket();
	self.m_timer[1] = setTimer(self.bindedFunc_destructor, 2000, 1);
end

function FireworkRomanCandleRocket:playSound(sSound, iMax, bAttach)
	local sound = playSound3D("files/audio/Firework/"..sSound, self.m_Position);

	if(bAttach ~= true) then
		attachElements(sound, self.m_uRocket);
	end
	setSoundMaxDistance(sound, (iMax or 50));
end
