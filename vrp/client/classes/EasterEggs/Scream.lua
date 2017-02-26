-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/EasterEggs/Scream.lua
-- *  PURPOSE:     Scream EasterEgg
-- *
-- ****************************************************************************
EasterEgg.Scream = inherit(Object)

function EasterEgg.Scream:constructor()
	self.m_Position = Vector3(1719.126, -1765.652, 38.133)
	self.m_colshape =  createColSphere(self.m_Position, 2)
	addEventHandler("onClientColShapeHit", self.m_colshape, bind(EasterEgg.Scream.onHit, self))
end

function EasterEgg.Scream:onHit(hitElement, matchingDimension)
	if not matchingDimension then return end
	if hitElement ~= localPlayer then return end

	setTimer(
		function()
			Sound3D("files/audio/scream.mp3", self.m_Position):setMaxDistance(50)
		end, 80, 3)

	localPlayer:giveAchievement(79)
end
