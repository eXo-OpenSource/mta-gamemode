PickupWeaponManager = inherit(Singleton) 
local LAST_USE_CHECK = 500
local LAST_BIND_CHECK = 2000

function PickupWeaponManager:constructor() 
	addEventHandler("onClientPickupHit", root, bind(self.Event_onPickupHit, self))
	self.m_KeyBind = bind(self.checkKey, self)
	bindKey("m", "down", self.m_KeyBind)	-- for m+alt
	bindKey("lalt", "down", self.m_KeyBind) -- for alt+m
end

function PickupWeaponManager:destructor() 
	
end

function PickupWeaponManager:Event_onPickupHit( player, dimension) 
	if dimension then 
		if getElementType(player) == "player" and player == localPlayer then 
			if not getPedOccupiedVehicle(player) then 
				if getElementData(source, "pickupWeapon") then
					self.m_HitWeaponPickup = source
					ShortMessage:new("Drücke Links-Alt + M um die Waffe aufzuheben!", "Waffe auf dem Boden")
				end
			end
		end
	end
end

function PickupWeaponManager:checkKey(key)
	if ( key == "m" and getKeyState("lalt")) or (key == "lalt" and getKeyState("m"))  then
		if self.m_HitWeaponPickup and isElement(self.m_HitWeaponPickup ) and not getPedOccupiedVehicle(localPlayer) then 
			self:Event_onTryPickupWeapon()
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