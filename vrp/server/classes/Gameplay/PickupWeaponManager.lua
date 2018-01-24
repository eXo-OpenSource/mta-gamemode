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
