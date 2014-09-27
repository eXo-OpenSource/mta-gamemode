AmmuNation = inherit(Object)

AmmuNation.INTERIORID = 7
AmmuNation.ENTERPOS = { X = 315.15640, Y = -142.49582, Z = 999.60156 }

function AmmuNation:constructor(name)
	self.m_Name = name or "NO NAME"
	
	self.m_Players = {}
	
	addEventHandler("onPlayerWeaponBuy",root,bind(self.buyWeapon,self))
	addEventHandler("onPlayerMagazineBuy",root,bind(self.buyMagazine,self))
	addEventHandler("onPlayerQuit",root,bind(self.quit,self))
end

function AmmuNation:quit()
	if self.m_Players[source] then
		self.m_Players[source] = nil
	end
end

function AmmuNation:buyWeapon(id)
	if self.m_Players[client] then
		if client:getMoney() >= AmmuNationInfo[id].Weapon then
			giveWeapon(client,id,AmmuNationInfo[id].Magazine.amount)
			client:setMoney(client:getMoney()-AmmuNationInfo[id].Weapon)
			client:sendMessage(_("Waffe erhalten.",client),0,125,0)
			return
		end
		client:sendMessage(_("Du hast nicht genuegend Geld.",client),125,0,0)
	end
end

function AmmuNation:buyMagazine(id)
	if self.m_Players[client] then
		if not hasPedThisWeaponInSlots (client,id) then return false end
		if client:getMoney() >= AmmuNationInfo[id].Magazine.price then
			giveWeapon(client,id,AmmuNationInfo[id].Magazine.amount)
			client:setMoney(client:getMoney()-AmmuNationInfo[id].Magazine.price)
			client:sendMessage(_("Munition erhalten.",client),0,125,0)
			return
		end
		client:sendMessage(_("Du hast nicht genuegend Geld.",client),125,0,0)
	end
end

function AmmuNation:addEnter(x,y,z,dimension)

	local instance = InteriorEnterExit:new(Vector3(x, y, z), Vector3(AmmuNation.ENTERPOS.X, AmmuNation.ENTERPOS.Y, AmmuNation.ENTERPOS.Z), 0, 0, AmmuNation.INTERIORID, dimension)
	Blip:new("AmmuNation.png", x, y)
	
	addEventHandler ("onMarkerHit",instance:getEnterMarker(),
		function(hitElement,matchingDimension)
			if matchingDimension and not isPedInVehicle(hitElement) then
				outputChatBox(("Welcome %s, in Ammu Nation \"%s\""):format(getPlayerName(hitElement),self.m_Name),hitElement,255,255,255,false)
				hitElement:triggerEvent("AmmuNation:setDimension")
				if not self.m_Players[hitElement] then
					self.m_Players[hitElement] = true
				else
					self.m_Players[hitElement] = nil
				end
			end
		end
	)
end