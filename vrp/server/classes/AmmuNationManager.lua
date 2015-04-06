AmmuNationManager = inherit(Singleton)

AmmuNationManager.DATA = {
	[1] = {
		NAME = "Los Santos Main",
		ENTER = 
		{
			{1368.23376,-1279.83606,13.54688}
		},
		DIMENSION = 1,
		ENTER_ROT = 360,
		EXIT_ROT = 90
	},	
	[2] = {
		NAME = "Los Santos East",
		ENTER = 
		{
			{2400.59106,-1981.68750,13.54688}
		},
		DIMENSION = 2,
		ENTER_ROT = 0,
		EXIT_ROT = 0
	},
}

function AmmuNationManager:constructor()
	self.m_AmmuNations = {}
	
	addEvent("onPlayerWeaponBuy",true)
	addEvent("onPlayerMagazineBuy",true)
	
	for key, value in ipairs(AmmuNationManager.DATA) do
		table.insert(self.m_AmmuNations,new(AmmuNation,value.NAME))
		local instance = self.m_AmmuNations[#self.m_AmmuNations]
		for k, coords in ipairs(value.ENTER) do
			instance:addEnter(coords[1],coords[2],coords[3],value.DIMENSION,value.ENTER_ROT, value.EXIT_ROT)
		end
	end
	
end