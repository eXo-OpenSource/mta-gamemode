AmmuNation = inherit(Object)

AmmuNation.INTERIORID = 7
AmmuNation.ENTERPOS = { X = 315.15640, Y = -142.49582, Z = 999.60156 }

function AmmuNation:constructor(name)
	self.m_Name = name or "NO NAME"
	
	addEventHandler("onPlayerWeaponBuy",root,bind(self.buyWeapon,self))
	addEventHandler("onPlayerMagazineBuy",root,bind(self.buyMagazine,self))
end

function AmmuNation:buyWeapon()

end

function AmmuNation:buyMagazine()
	
end

function AmmuNation:addEnter(x,y,z,dimension)

	local instance = InteriorEnterExit:new({X=x,Y=y,Z=z},{X=AmmuNation.ENTERPOS.X,Y=AmmuNation.ENTERPOS.Y,Z=AmmuNation.ENTERPOS.Z}, 0, 0, AmmuNation.INTERIORID,dimension)
	
	addEventHandler ("onMarkerHit",instance:getEnterMarker(),
		function(hitElement,matchingDimension)
			if matchingDimension and not isPedInVehicle(hitElement) then
				outputChatBox(("Welcome %s, in Ammu Nation \"%s\""):format(getPlayerName(hitElement),self.m_Name),hitElement,255,255,255,false)
				hitElement:triggerEvent("AmmuNation:setDimension")
			end
		end
	)
end