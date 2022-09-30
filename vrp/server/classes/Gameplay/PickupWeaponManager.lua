PickupWeaponManager = inherit(Singleton)
PickupWeaponManager.Map = { }

function PickupWeaponManager:constructor()
	addRemoteEvents{"onPlayerHitPickupWeapon", "onPlayerDropWeapon", }
	addEventHandler("onPlayerHitPickupWeapon", root, bind(self.Event_onPlayerPickupWeaponUse, self))
	addEventHandler("onPlayerDropWeapon", root, bind(self.Event_onPlayerDropWeapon, self))
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

function PickupWeaponManager:Event_onPlayerDropWeapon(data)
	takeWeapon(client, data[6])
	PickupWeapon:new(data[1], data[2], data[3], data[4], data[5], data[6], data[7], client, false)
end

function PickupWeaponManager:destructor()

end

function PickupWeaponManager:Event_Quit( player )
	player:dropReviveWeapons()
	player:dropReviveMoney()
end

function PickupWeaponManager:detachWeapons(player)
	if player.m_ReviveWeapons then
		for i = 1, 12 do
			if player.m_ReviveWeapons[i] then
				if isElement(player.m_ReviveWeapons[i].m_Entity) then
					player.m_ReviveWeapons[i].m_Entity:detach()
				end
			end
		end
	end
end
