PickupWeaponManager = inherit(Singleton) 
PickupWeaponManager.Map = { }

function PickupWeaponManager:constructor() 
	addRemoteEvents{"onPlayerHitPickupWeapon"}
	addEventHandler("onPlayerHitPickupWeapon", root, bind(self.Event_onPlayerPickupWeaponUse, self))
	PlayerManager:getSingleton():getQuitHook():register(bind(self.Event_Quit, self))
end

function PickupWeaponManager:Event_onPlayerPickupWeaponUse( pickup ) 
	if client then 
		if not isPedDead(client) and getElementHealth(client) ~= 0 and ( client.getExecutionPed and not client:getExecutionPed()) then
			if PickupWeaponManager.Map[pickup] then 
				PickupWeaponManager.Map[pickup]:pickup( client ) 
			end
		end
	end
end

function PickupWeaponManager:destructor() 

end

function PickupWeaponManager:Event_Quit( player ) 
	player:dropReviveWeapons()
end

function PickupWeaponManager:detachWeapons(player)
	if player.m_ReviveWeapons then
		for i = 1, 12 do
			if isElement(player.m_ReviveWeapons[i].m_Entity) then
				player.m_ReviveWeapons[i].m_Entity:detach()
			end
		end
	end
end