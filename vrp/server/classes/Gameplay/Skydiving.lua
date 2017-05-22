-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Skydiving.lua
-- *  PURPOSE:     Skydiving class
-- *
-- ****************************************************************************
SkydivingManager = inherit(Singleton)

function SkydivingManager:constructor()
	local elevator = Elevator:new()
	elevator:addStation("Erdgeschoss", Vector3(1570.842, -1337.266, 16.484), 308)
	elevator:addStation("Dachgeschoss", Vector3(1548.535, -1363.746, 326.218), 172)

	Skydiving.Map[1] = Skydiving:new(1, Vector3(1529.250, -1356.471, 328.5), Vector3(1523.536, -1359.087, 330.055), 104)
	Skydiving.Map[2] = Skydiving:new(2, Vector3(1643.218, -2238.326, 12.6), Vector3(1887.5, -2493, 2076.8), 80)

	addEvent("skydivingStart", true)
	addEventHandler("skydivingStart", root, bind(self.startSkydiving, self))
end

function SkydivingManager:startSkydiving(id)
	if Skydiving.Map[id] then
		if source:getMoney() >= Skydiving.Costs then
			source:takeMoney(Skydiving.Costs, "Skydiving")
			Skydiving.Map[id]:start(source)
		else
			source:sendError(_("Du hast zuwenig Geld dabei! (%d$)", source, Skydiving.Costs))
		end
	else
		source:sendError("Internal Error: Skydiving not found! ID:"..id)
	end
end

Skydiving = inherit(Object)
Skydiving.Costs = 250
Skydiving.Map = {}

function Skydiving:constructor(id, markerPos, spawnPos, rot)
	self.m_Id = id
	self.m_Marker = createMarker(markerPos, "cylinder", 1, 255, 0, 0)
	self.m_SpawnPos = spawnPos
	self.m_SpawnRot = Vector3(0, 0, rot or 0)

	addEventHandler("onMarkerHit", self.m_Marker, bind(self.onMarkerHit, self))
end

function Skydiving:onMarkerHit(hitElement, dim)
	if hitElement.type == "player" and dim and not hitElement.vehicle then
		QuestionBox:new(hitElement, hitElement, _("Möchtest du die Fallschirm springen? Kosten: %d$", hitElement, Skydiving.Costs), "skydivingStart", nil, self.m_Id)
	end
end

function Skydiving:start(player)
	player:fadeCamera(false)
	setTimer(function()
		player:setPosition(self.m_SpawnPos)
		player:setRotation(self.m_SpawnRot)
		giveWeapon(player, 46, 1, true)
		player:fadeCamera(true)
		player:sendSuccess(_("Viel Spaß beim Absprung!", player))
	end, 1000, 1)

end
