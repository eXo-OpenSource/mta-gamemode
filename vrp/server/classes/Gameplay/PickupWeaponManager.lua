PickupWeaponManager = inherit(Singleton) 
PickupWeaponManager.Map = { }

function PickupWeaponManager:constructor() 
	addRemoteEvents{"onPlayerHitPickupWeapon"}
	addEventHandler("onPlayerHitPickupWeapon", root, bind(self.Event_onPlayerPickupWeaponUse, self))
end

function PickupWeaponManager:Event_onPlayerPickupWeaponUse( pickup ) 
	if client then 
		if PickupWeaponManager.Map[pickup] then 
			PickupWeaponManager.Map[pickup]:pickup( client ) 
		end
	end
end

function PickupWeaponManager:destructor() 

end
