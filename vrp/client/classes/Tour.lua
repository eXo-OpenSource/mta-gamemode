-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Tour.lua
-- *  PURPOSE:     eXo Tour Class (client)
-- *
-- ****************************************************************************

Tour = inherit(Singleton)

function Tour:constructor()
	if core:get("Tour", "done", false) == false then
		QuestionBox:new(
			_("Möchtest du eine Servertour starten? Diese bringt dir Erfahrung und eine kleine Belohnungen!"),
			function() triggerServerEvent("tourStart", localPlayer) end)
	end
	addRemoteEvents{"tourShow", "tourStop"}
	addEventHandler("tourShow", root, bind(self.show, self))
	addEventHandler("tourStop", root, bind(self.stop, self))


	self.m_updateArrow = bind(self.updateArrow, self)
end

function Tour:stop()
	if isElement(self.m_Arrow) then self.m_Arrow:destroy() end
	if isElement(self.m_TargetMarker) then self.m_TargetMarker:destroy() end
	if TourGUI:isInstantiated() then delete(TourGUI:getSingleton()) end
	core:set("Tour", "done", true)
end

function Tour:show(id, title, description, success, x, y, z)
	self.m_TargetPos = Vector3(x, y, z)
	self.m_CurrentId = id
	self.m_TargetMarker = createMarker(self.m_TargetPos, "cylinder", 2, 50, 200, 255)
	addEventHandler("onClientMarkerHit", self.m_TargetMarker, function(hitElement, dim)
		if hitElement:getType() == "player" and dim then
			self:onTargetHit(title, success)
		end
	end)
	self:showGUI(title, description)
	self:showArrow()
end

function Tour:onTargetHit(title, success)
	self:showGUI(title, success)
	triggerServerEvent("tourSuccess", localPlayer, self.m_CurrentId)
end

function Tour:showGUI(title, description)
	if TourGUI:isInstantiated() then delete(TourGUI:getSingleton()) end
	TourGUI:new(title, description)
end

function Tour:showArrow(position)
	if not isElement(self.m_Arrow) then
		self.m_Arrow = createObject(1318, localPlayer:getPosition())
		addEventHandler("onClientPreRender", root, self.m_updateArrow)
	end
end

function Tour:updateArrow()
	if isElement(self.m_Arrow) then
		local scale, pos
		if localPlayer.vehicle then
			pos = localPlayer:getOccupiedVehicle():getPosition()
			pos.z = pos.z + 2
			scale = 1.5
		else
			pos = localPlayer:getPosition()
			pos.z = pos.z + 1
			scale = 0.5
		end

		self.m_Arrow:setScale(scale)

		local horizontalRotation = findRotation(pos.x, pos.y, self.m_TargetPos.x, self.m_TargetPos.y) - 90
		local verticalRotation = math.deg(math.asin((self.m_TargetPos.z - pos.z) / getDistanceBetweenPoints3D(pos, self.m_TargetPos)))

		self.m_Arrow:setPosition(pos)
		self.m_Arrow:setRotation(0, 90 + verticalRotation, horizontalRotation)
	end
end
