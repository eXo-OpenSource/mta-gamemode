-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/WareManager.lua
-- *  PURPOSE:     Ware Manager class
-- *
-- ****************************************************************************

WareManager = inherit(Singleton)

WareManager.Map = {}
local MAX_PLAYERS_PER_WARE = 12

function WareManager:constructor( x,y,z )
	--self.m_Pickup = createPickup(x, y, z, 3, 1313,0) --1736.53, -1270.35, 13.54
	self.m_Pos = {x, y, z}
	addRemoteEvents{"Ware:tryJoinLobby", "Ware:tryLeaveLobby", "Ware:refreshGUI", "Ware:onPedClick"}
	addEventHandler("Ware:tryJoinLobby", root, bind(self.Event_onTryJoinLobby, self))
	addEventHandler("Ware:refreshGUI", root, bind(self.Event_refreshGUI, self))
	for i = 1, 5 do
		WareManager.Map[#WareManager.Map+1] = Ware:new(i)
	end
	PlayerManager:getSingleton():getWastedHook():register(
	function(player, killer, weapon)
		if player.bInWare then
			player:triggerEvent("abortDeathGUI", true)
			player.bInWare:onDeath(player, killer, weapon)
			return true
		end
	end)
	Player.getQuitHook():register(
		function(player)
			if player.bInWare then
				self:leaveLobby(player)
			end
		end
	)

	--addEventHandler("onPickupHit",self.m_Pickup, bind(self.Event_onPickupHit, self))
	addEventHandler("Ware:tryLeaveLobby", root , bind(self.Event_onLeaveLobby, self))
	addEventHandler("Ware:onPedClick", root , bind(self.Event_onPedClick, self))


end

function WareManager:Event_refreshGUI()
	if client then
		client:triggerEvent("Ware:closeGUI")
		client:triggerEvent("Ware:wareOpenGUI", WareManager.Map)
	end
end

function WareManager:Event_onLeaveLobby( isServerStop)
	if not client then return end
	local player = client
	if player.bInWare then
		if isElement(player) then
			player.bInWare:leavePlayer(player)
			player:restoreStorage()
			--player.m_RemoveWeaponsOnLogout = nil
			player.disableWeaponStorage = nil
			spawnPlayer(player, 0, 0, 0)
			player:setDimension(0)
			player:setInterior(0)
			player:setPosition(self.m_Pos[1], self.m_Pos[2], self.m_Pos[3])
			player:setHeadless(false)
			player:setHealth(100)
			player:setArmor(0)
			player:setSkin(player.m_Skin)
			player:setAlpha(255)
			player.bInWare = nil
			if not isServerStop then
				player:sendShortMessage(_("Du hast die Lobby verlassen!", player), "Deathmatch-Lobby", {255, 125, 0})
			end
		end
	end
end


function WareManager:leaveLobby( player, isServerStop)
	if player.bInWare then
		if isElement(player) then
			player.bInWare:leavePlayer(player)
			player:restoreStorage()
			--player.m_RemoveWeaponsOnLogout = nil
			player.disableWeaponStorage = nil
			spawnPlayer(player, 0, 0, 0)
			player:setDimension(0)
			player:setInterior(0)
			player:setPosition(self.m_Pos[1], self.m_Pos[2], self.m_Pos[3])
			player:setHeadless(false)
			player:setHealth(100)
			player:setArmor(0)
			player:setSkin(player.m_Skin)
			player:setAlpha(255)
			player.bInWare = nil
			if not isServerStop then
				player:sendShortMessage(_("Du hast die Lobby verlassen!", player), "Deathmatch-Lobby", {255, 125, 0})
			end
		end
	end
end


function WareManager:Event_onTryJoinLobby( id )
	if client then
		if WareManager.Map[id] then
			if #WareManager.Map[id]:getPlayers() < MAX_PLAYERS_PER_WARE then
				self.Map[id]:joinPlayer( client )
			end
		end
	end
end

function WareManager:Event_onPickupHit( player )
	local dimension = source:getDimension() == player:getDimension()
	if dimension then
		player:triggerEvent("Ware:wareOpenGUI", WareManager.Map)
	end
end

function WareManager:Event_onPedClick()
	client:triggerEvent("Ware:wareOpenGUI", WareManager.Map)
end


function WareManager:destructor()

end
