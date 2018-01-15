PickupWeapon = inherit(Object) 
PickupWeapon.Map = { }
local PICKUP_ANIMATION_BLOCK, PICKUP_ANIMATION_NAME = "misc", "pickup_box"

function PickupWeapon:constructor( x, y, z, int, dim, weapon, ammo, owner) 
	if WEAPON_MODELS_WORLD[weapon] then
		self.m_WeaponID = weapon 
		self.m_Ammo = ammo
		if owner then 
			self.m_Owner = owner.m_Id
			if owner:getFaction() then
				self.m_OwnerFaction = owner:getFaction()
			end
		end
		self.m_Entity = createPickup(x, y, z, 3, WEAPON_MODELS_WORLD[weapon], -1)
		setElementDoubleSided(self.m_Entity, true)
		setElementDimension(self.m_Entity, dim)
		setElementInterior(self.m_Entity, int)
		self.m_Entity.m_DroppedWeapon = true
		PickupWeaponManager.Map[self.m_Entity] = self
	end
end

function PickupWeapon:pickup( player ) 
	if player and isElement(player) then 
		if (player:getPlayTime() / 60) >=  3 then
			if not ( player:isFactionDuty() and player:getFaction():isStateFaction()) then
				giveWeapon(player, self.m_WeaponID, self.m_Ammo, true)
				outputChatBox("Du hast die Waffe erhalten!", client, 200,200,0)
			else
				FactionState:getSingleton():addWeaponToEvidence( player, self.m_WeaponID, self.m_Ammo, self.m_OwnerFaction or "Keine")
				outputChatBox("Du hast die Waffe konfesziert! Sie wird in die Asservatenkammer reingelegt.", player, 200,200,0)
			end
			player:meChat(true, "kniet sich nieder und hebt eine Waffe auf!")
			setPedAnimation( player, PICKUP_ANIMATION_BLOCK, PICKUP_ANIMATION_NAME, 200, false, false, false)
			setTimer(setPedAnimation, 1000, 1, player, nil)
			delete(self)
		else
			player:sendError("Du hast zu wenig Spielstunden!")
		end
	end
end

function PickupWeapon:destructor() 
	if self.m_Entity then 
		if isElement(self.m_Entity) then 
			destroyElement(self.m_Entity)
		end
	end
end