PickupWeaponManager = inherit(Singleton) 
local LAST_USE_CHECK = 500
local LAST_BIND_CHECK = 2000

function PickupWeaponManager:constructor() 
	addEventHandler("onClientPickupHit", root, bind(self.Event_onPickupHit, self))
	addEventHandler("onClientRender", root, bind(self.Event_checkForPickup, self))
end

function PickupWeaponManager:destructor() 
	
end

function PickupWeaponManager:Event_onPickupHit( player, dimension) 
	if dimension then 
		if getElementType(player) == "player" then 
			if not getPedOccupiedVehicle(player) then 
				self.m_HitWeaponPickup = source
				ShortMessage:new("Drücke Links-Alt + M um die Waffe aufzuheben!", "Waffe auf dem Boden")
			end
		end
	end
end

function PickupWeaponManager:Event_onTryPickupWeapon() 
	if self.m_HitWeaponPickup and isElement(self.m_HitWeaponPickup) then 
		local x, y, z = getElementPosition(localPlayer) 
		local px, py, pz = getElementPosition(self.m_HitWeaponPickup) 
		local dist = getDistanceBetweenPoints3D(x, y, z, px, py, pz) 
		local now = getTickCount() 
		if dist <= 5 then 
			if not self.m_LastPickup or ( self.m_LastPickup+LAST_USE_CHECK <= now ) then
				triggerServerEvent("onPlayerHitPickupWeapon", localPlayer, self.m_HitWeaponPickup)
				self.m_LastPickup = now
			end
		end
	end
end

function PickupWeaponManager:Event_checkForPickup() 
	if self.m_HitWeaponPickup and isElement(self.m_HitWeaponPickup ) then 
		local now = getTickCount()
		if getKeyState("lalt") and getKeyState("m") then
			if not self.m_LastBindCheck or (self.m_LastBindCheck+LAST_BIND_CHECK <= now ) then
				self.m_LastBindCheck = now
				self:Event_onTryPickupWeapon()
			end
		end
	end
end
