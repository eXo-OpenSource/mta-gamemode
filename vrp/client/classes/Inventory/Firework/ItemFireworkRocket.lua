ItemFireworkRocket = inherit(Object)

function ItemFireworkRocket:constructor(pos, pipeBomb, pipeBombSound)
	self.m_Position = pos

	if pipeBomb then
		self.m_uRocket          = createVehicle(594, pos.x, pos.y, pos.z-1);
		setElementFrozen(self.m_uRocket, true);
		setElementAlpha(self.m_uRocket, 0)

		self.m_uAbschuss        = createObject(3675, pos.x, pos.y+0.25, pos.z-2, 0, 180, 0);
		setObjectScale(self.m_uAbschuss, 0.3);
		setElementCollisionsEnabled(self.m_uAbschuss, false);

	else
		self.m_uRocket          = createObject(1941, pos.x, pos.y, pos.z-1);
		setObjectScale(self.m_uRocket, 2); -- Rausnehmen
		setElementRotation(self.m_uRocket, 0, math.random(1, 10), math.random(0, 360))
		setElementCollisionsEnabled(self.m_uRocket, false);

	end

	self.m_FRR              = false; --ItemFireworkRocketSchweif:new(self);
	self.m_FRE              = false; --ItemFireworkRocketExplosion:new(self);
	self.m_bRohrBombe       = pipeBomb;

	self.m_bRohrBombenSound = pipeBombSound;

	self.m_bLaunched        = false;
	self.m_iState           = 0; -- am Boden

	self.m_tblTimer         = {};
	self.m_timer            = {};

	-- Funktionen --

	self.m_funcRender       = bind(self.render, self)

	self.bindedFunc_launchRocket        = function(...) self:launchRocket() end
	self.bindedFunc_doExplosion         = function(...) self:doExplosion() end
	self.bindedFunc_destructor          = function(...) self:destructor() end

	self:initTimer();
	-- Events --

	addEventHandler("onClientRender", getRootElement(), self.m_funcRender);
end

function ItemFireworkRocket:destructor()
	if self.m_FRR then delete(self.m_FRR) end
	if self.m_FRE then delete(self.m_FRE) end

--	destroyElement(self.m_uRocket);

	if(self.m_uAbschuss) then
		destroyElement(self.m_uAbschuss, true);
	end
	removeEventHandler("onClientRender", getRootElement(), self.m_funcRender);
end

function ItemFireworkRocket:render()
	if(self.m_iState == 0) then
		-- Am Boden
		fxAddSparks(self.m_Position, 0,0, 1, 1, 1)
	elseif(self.m_iState == 1) then
		-- Luft
		self.m_FRR:render();
	elseif(self.m_iState == 2) then
		-- Explosion
		if(self.m_FRE.render) then
			self.m_FRE:render();
		end
	end
end

function ItemFireworkRocket:launchRocket()
	self.m_iState = 1;

	if(self.m_bRohrBombe) or (self.m_bRohrBombenSound) then
		self.m_FRR              = FireworkPipebombTail:new(self);
	else
		self.m_FRR              = FireworkRocketTail:new(self);
	end
end

function ItemFireworkRocket:doExplosion()
	self.m_iState = 2;
	if(self.m_FRR) then delete(self.m_FRR) end
	if(self.m_bRohrBombe) then
		self.m_FRE              = FireworkPipebombExplosion:new(self);
	else
		self.m_FRE              = FireworkExplosionSimple:new(self);

	end

	destroyElement(self.m_uRocket)
end

function ItemFireworkRocket:initTimer()

	self.m_tblTimer =
	{
		["launchRocket"]   = {3000},
		["doExplosion"]    = {5000},
		["destructor"]     = {10000},
	}

	self.m_tblTimer_RB =
	{
		["launchRocket"]   = {5000},
		["doExplosion"]    = {7000},
		["destructor"]     = {15000},
	}
	for event, ms in pairs(self.m_tblTimer) do
		local ms2 = ms[1]

		if(self.m_bRohrBombe) then
			ms2 = self.m_tblTimer_RB[event][1]
		end
		self.m_timer[event] = setTimer(function() self["bindedFunc_"..event]() end, ms2, 1);

	end
end

function ItemFireworkRocket:playSound(sSound, iMax, bAttach)
	local sound = playSound3D("files/audio/Firework/"..sSound, self.m_Position);

	if(bAttach ~= true) then
		attachElements(sound, self.m_uRocket);
	end
	setSoundMaxDistance(sound, (iMax or 50));
end
