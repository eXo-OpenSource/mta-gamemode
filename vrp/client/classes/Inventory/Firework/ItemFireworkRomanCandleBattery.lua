ItemFireworkRomanCandleBattery = inherit(Object)

function ItemFireworkRomanCandleBattery:constructor(pos, iAm)
	-- Klassenvariablen --
	self.m_Position = pos

	self.m_iAm          = iAm;

	self.m_iCur         = 0;

	self.m_tblExplos      = {}
	self:bumm()
end

function ItemFireworkRomanCandleBattery:destructor()

end

function ItemFireworkRomanCandleBattery:bumm()
	for i = 1, self.m_iAm, 1 do
		self.m_tblExplos[i] = ItemFireworkRomanCandle:new(self.m_Position, math.random(25, 35))
	end
end
