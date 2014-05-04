AmmuNationManager = inherit(Singleton)

AmmuNationManager.DATA = {
	[1] = {
		NAME = "Los Santos Main",
		ENTER = 
		{
			{0,0,0}
		},
		DIMENSION = 0,
	},
}

function AmmuNationManager:constructor()
	self.m_AmmuNations = {}
	
	addEvent("onPlayerWeaponBuy",true)
	addEvent("onPlayerMagazinBuy",true)
	
	for key, value in ipairs(AmmuNationManager.DATA) do
		table.insert(self.m_AmmuNations,new(AmmuNation,value.NAME))
		local instance = self.m_AmmuNations[#self.m_AmmuNations]
		for k, coords in ipairs(value.ENTER) do
			instance:addEnter(coords[1],coords[2],coords[3],value.DIMENSION)
		end
	end
	
end