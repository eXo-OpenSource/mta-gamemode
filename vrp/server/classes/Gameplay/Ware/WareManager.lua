-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/WareManager.lua
-- *  PURPOSE:     Ware Manager class
-- *
-- ****************************************************************************

WareManager = inherit(Singleton)

WareManager.Map = {}

--//1321.26, -1644.13, 13.55
function WareManager:constructor( x,y,z )
	self.m_Pickup = createPickup(x, y, z, 3, 1239,0)
	self.m_MapId = #WareManager.Map
	self.m_WareObj = Ware:new(self.m_MapId)
	WareManager.Map[#WareManager.Map+1] = self.m_WareObj
	PlayerManager:getSingleton():getWastedHook():register(
	function(player, killer, weapon)
		if player.bInWare then
			player:triggerEvent("abortDeathGUI", true)
			player.bInWare:onDeath(player, killer, weapon)
			return true
		end
	end)
	addEventHandler("onPlayerPickupHit",self.m_Pickup, bind(self.Event_onPickupHit, self))
end

function WareManager:Event_onPickupHit( player )
	local dimension = source:getDimension() == player:getDimension()
	if dimension then 
		player:triggerEvent("Ware:wareOpenGUI")
	end
end

function WareManager:destructor()

end
