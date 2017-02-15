EasterEgg = inherit(Singleton)

function EasterEgg:constructor()
	self.m_DogeQRFrame = createObject(2257, 1102.8000488281, -841.70001220703, 108.19999694824, 345, 0, 7.25);
	setObjectScale(self.m_DogeQRFrame, 1.5);
	TextureReplace:constructor("cj_painting15", "files/images/Other/such_qr_wow.png", false, 1320, 1320, self.m_DogeQRFrame)
end
