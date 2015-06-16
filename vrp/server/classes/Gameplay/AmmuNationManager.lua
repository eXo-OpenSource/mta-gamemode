-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/AmmuNationManager.lua
-- *  PURPOSE:     Weapon shop manager class
-- *
-- ****************************************************************************
AmmuNationManager = inherit(Singleton)
addRemoteEvents{"onPlayerWeaponBuy", "onPlayerMagazineBuy"}

AmmuNationManager.DATA = {
	[1] = {
		NAME = "Los Santos Main",
		ENTER =
		{
			{1368.23376,-1279.83606,13.54688}
		},
		DIMENSION = Interiors.AmmuNation1
	},
	[2] = {
		NAME = "Los Santos East",
		ENTER = {
			{2400.59106,-1981.68750,13.54688}
		},
		DIMENSION = Interiors.AmmuNation2
	},
}

function AmmuNationManager:constructor()
	self.m_AmmuNations = {}

	for k, info in pairs(AmmuNationManager.DATA) do
		local ammuNation = AmmuNation:new(info.NAME)
		table.insert(self.m_AmmuNations, ammuNation)

		for k, coords in pairs(info.ENTER) do
			ammuNation:addEnter(coords[1], coords[2], coords[3], info.DIMENSION)
		end

		-- Register interiors (so that the player respawns here after reconnecting)
		InteriorManager:getSingleton():registerInterior(info.DIMENSION, AmmuNation.INTERIORID, Vector3(info.ENTER[1]))
	end
end
