ItemPipeBomb = inherit(Object)

function ItemPipeBomb:constructor(pos)
	self.m_Position = pos

	self.m_uRocket          = createVehicle(594, pos.x, pos.y, pos.z-1);
	setElementFrozen(self.m_uRocket, true);
	setElementAlpha(self.m_uRocket, 0)

	self.m_uAbschuss        = createObject(3675, pos.x, pos.y+0.25, pos.z-2, 0, 180, 0);
	setObjectScale(self.m_uAbschuss, 0.3);
	setElementCollisionsEnabled(self.m_uAbschuss, false);

	self.m_FRR              = false; --ItemPipeBombSchweif:new(self);
	self.m_FRE              = false; --ItemPipeBombExplosion:new(self);

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

	addEventHandler("onClientRender", getRootElement(), self.m_funcRender);
end

function ItemPipeBomb:destructor()
	self.m_FRE:destructor()
	self.m_FRR:destructor();

	destroyElement(self.m_uRocket);
	destroyElement(self.m_uAbschuss, true);

	removeEventHandler("onClientRender", getRootElement(), self.m_funcRender);
end

function ItemPipeBomb:render()
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

function ItemPipeBomb:launchRocket()
	self.m_iState = 1;

	self.m_FRR              = FireworkPipebombTail:new(self);
end

function ItemPipeBomb:doExplosion()
	self.m_iState = 2;
	self.m_FRR:destructor();

	self.m_FRE              = FireworkPipebombExplosion:new(self);
end

function ItemPipeBomb:initTimer()

	self.m_tblTimer =
	{
		["launchRocket"]   = {5000},
		["doExplosion"]    = {7000},
		["destructor"]     = {15000},
	}

	for event, ms in pairs(self.m_tblTimer) do
		local ms2 = ms[1]

		self.m_timer[event] = setTimer(function() self["bindedFunc_"..event]() end, ms2, 1);
	end
end

function ItemPipeBomb:playSound(sSound, iMax, bAttach)
	local sound = playSound3D("files/audio/Firework/"..sSound, self.m_Position);

	if(bAttach ~= true) then
		attachElements(sound, self.m_uRocket);
	end
	setSoundMaxDistance(sound, (iMax or 50));
end
