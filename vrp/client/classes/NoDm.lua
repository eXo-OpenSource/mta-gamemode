NoDm = inherit(Singleton)
addRemoteEvents{"checkNoDm"}
NoDm.Zones = {
	[1] = {Vector3(1399.112, -1862.453, 12), Vector3(160,120,15)},
	[2] = {Vector3(1322.850, -1721.659, 12), Vector3(92,120, 15)},
	[3] = {Vector3(430, -100, 998), Vector3(50, 40, 10), 4},
	[4] = {Vector3{1770, -1342.12, 20.77},Vector3{65, 72, 123}},
	[5] = {Vector3(1700, -1800, 0), Vector3{111, 60, 100}}, -- Rescue
	[6] = {Vector3(1266, 22, 20), Vector3{150, 150, 50}}, -- Kart
}

function NoDm:constructor()
	self.m_NoDmZones = {}
	self.m_NoDmRadarAreas = {}
	self.m_NoDm = false

	self.m_RenderBind = bind(self.renderNoDmImage, self)
	self.m_UnRenderBind = bind(self.unrenderNoDmImage, self)

	local colshape

	for index, koords in pairs(NoDm.Zones) do
		colshape = createColCuboid(koords[1], koords[2])
		if koords[3] and koords[3] > 0 then
			colshape:setInterior(koords[3])
		else
			self.m_NoDmRadarAreas[index] = HUDRadar:getSingleton():addArea(koords[1].x, koords[1].y, koords[2].x, -1*koords[2].y, {0, 255, 0, 200})
		end
		self:addZone(colshape)
	end
end

function NoDm:onNoDmZoneHit(hitElement, dim)
	if hitElement== localPlayer and dim then
		self:setPlayerNoDm(true)
	end
end

function NoDm:onNoDmZoneLeave(hitElement, dim)
	if hitElement== localPlayer and dim then
		self:setPlayerNoDm(false)
	end
end

function NoDm:addZone(colShape)
	local index = #self.m_NoDmZones+1
	self.m_NoDmZones[index] = colShape
	addEventHandler ("onClientColShapeHit", colShape, bind(self.onNoDmZoneHit, self))
	addEventHandler ("onClientColShapeLeave", colShape, bind(self.onNoDmZoneLeave, self))
end

function NoDm:setPlayerNoDm(state)
	if state == true then
		if not localPlayer:getPublicSync("Faction:Duty") then
			toggleControl ("fire", false)
			toggleControl ("next_weapon", false)
			toggleControl ("previous_weapon", false)
			toggleControl ("aim_weapon", false)
			toggleControl ("vehicle_fire", false)
			setElementData(localPlayer, "no_driveby", true)
			setPedWeaponSlot(localPlayer, 0)
			if getPedWeapon ( localPlayer, 9 ) == 43 then
				if not isPedInVehicle(localPlayer) then
					setPedWeaponSlot(localPlayer,9)
					toggleControl ("aim_weapon", true)
					toggleControl ("fire", true)
					setTimer(showChat,100,1,true)
				end
			end
		end
		self:toggleNoDmImage(true)
	else
		toggleControl ("fire", true)
		toggleControl ("next_weapon", true)
		toggleControl ("previous_weapon", true)
		toggleControl ("aim_weapon", true)
		toggleControl ("vehicle_fire", true)
		setElementData(localPlayer, "no_driveby", false)
		setElementData(localPlayer,"schutzzone",false)
		self:toggleNoDmImage(false)
		localPlayer.m_FireToggleOff = false
	end
end

function NoDm:toggleNoDmImage(state)
	if state == true and self.m_NoDm == false then
		self.m_currentImagePosition = 0
		removeEventHandler ( "onClientRender", getRootElement(), self.m_RenderBind)
		addEventHandler ( "onClientRender", getRootElement(), self.m_RenderBind)
		self.m_NoDm = true
	elseif state == false and self.m_NoDm == true then
		removeEventHandler ( "onClientRender", getRootElement(), self.m_UnRenderBind)
		addEventHandler ( "onClientRender", getRootElement(), self.m_UnRenderBind)
		self.m_NoDm = false
	end
end

function NoDm:renderNoDmImage()
	local target = screenWidth*0.15
	if self.m_currentImagePosition < target then self.m_currentImagePosition = self.m_currentImagePosition +10 end

	local px = screenWidth-self.m_currentImagePosition
	local py = screenHeight/2
	if not Phone:getSingleton():isOpen() then
		dxDrawImage(px,py,screenWidth*0.15,screenWidth*0.08,"files/images/Other/nodm.png")
	end
	if localPlayer:getFactionId() ~= 1 and localPlayer:getFactionId() ~= 2 and localPlayer:getFactionId() ~= 3 and getPedWeapon ( localPlayer, 9 ) ~= 43 then
		setPedWeaponSlot(localPlayer,0)
	end
end

function NoDm:unrenderNoDmImage()
	if self.m_currentImagePosition > 0 then self.m_currentImagePosition = self.m_currentImagePosition -20 end
	if self.m_currentImagePosition <= 0 then
		removeEventHandler ( "onClientRender", getRootElement(), self.m_RenderBind)
		removeEventHandler ( "onClientRender", getRootElement(), self.m_UnRenderBind)
	end
end

function NoDm:isInNoDmZone()
	for i, shape in pairs (self.m_NoDmZones) do
		if isElementWithinColShape(localPlayer, shape) then
			return true
		end
	end
	return false
end

function NoDm:checkNoDm()
	if self:isInNoDmZone() then
		self:setPlayerNoDm(true)
	else
		self:setPlayerNoDm(false)
	end
end

addEventHandler("checkNoDm", localPlayer, function()
	for index, koords in pairs(NoDm:getSingleton().Zones) do
		local cols = NoDm:getSingleton().m_NoDmZones[index]
		if isElementWithinColShape(localPlayer, cols) then
			NoDm:getSingleton():setPlayerNoDm(true)
			break
		else
			toggleControl("aim_weapon",true)
		end
	end
end)
