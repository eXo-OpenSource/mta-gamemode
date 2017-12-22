ItemFireworkBattery = inherit(Object)

function ItemFireworkBattery:constructor(pos, iAm)
	self.m_Position = pos

	self.m_iAm          = iAm;
	self.m_iCur         = 0;

	self.m_tblExplos      = {}

	self.m_StartBind     = bind(self.start, self)

	self:start()
end

function ItemFireworkBattery:destructor()
	destroyElement(self.m_uAbschuss);
end

function ItemFireworkBattery:start()
	if(self.m_iCur < self.m_iAm) then
		self.m_tblExplos[self.m_iCur] = FireworkPipebombBatteryRocket:new(self.m_Position, true)
		self.m_iCur = self.m_iCur+1;

		setTimer(self.m_StartBind, math.random(4000, 5000), 1)
	end
end




