ItemFireworkRomanCandle = inherit(Object)

function ItemFireworkRomanCandle:constructor(pos, iAm)
	self.m_Position = pos

	self.m_iAm          = iAm;
	self.m_iCur         = 0;

	self.m_uAbschuss    = createObject(2774, pos.x, pos.y, pos.z-1);
	setObjectScale(self.m_uAbschuss, 0.05);
	setElementCollisionsEnabled(self.m_uAbschuss, false)
	setElementDoubleSided(self.m_uAbschuss, true)

	self.m_tblExplos      = {}

	-- Funktionen --

	self.m_func_bum     = function() self:bumm() end
	self.m_funcRender   = function(...) self:render(...) end

	setTimer(self.m_func_bum, math.random(3500, 4500), 1)

	-- Events --

	addEventHandler("onClientRender", getRootElement(), self.m_funcRender)

end

function ItemFireworkRomanCandle:destructor()
	destroyElement(self.m_uAbschuss);

	removeEventHandler("onClientRender", getRootElement(), self.m_funcRender)
end


function ItemFireworkRomanCandle:render()
	fxAddSparks(self.m_Position, 0,0, 1, 1, 1)

	if(self.m_iCur == self.m_iAm) then
		self:destructor()
	end
end

function ItemFireworkRomanCandle:bumm()
	if(self.m_iCur < self.m_iAm) then
		local x, y, z = self.m_iX, self.m_iY, self.m_iZ;

		self.m_tblExplos[self.m_iCur] = FireworkRomanCandleRocket:new(self.m_Position)
		self.m_iCur = self.m_iCur+1;

		setTimer(self.m_func_bum, math.random(1000, 1500), 1)
	end
end



