-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/EasterEggs/DrWho.lua
-- *  PURPOSE:     DrWho EasterEggs
-- *
-- ****************************************************************************
EasterEgg.DrWho = inherit(Object)

function EasterEgg.DrWho:constructor()
	self.m_Spawns = {
		--Vector3(1474.652, -1678.340, 14.047),
		Vector3(1392.468, 1898.531, 13.501),
		Vector3(1252.972, -1523.225, 13.555),
		Vector3(1365.577, -1527.504, 13.547),
	}

	self.m_ColHitAnimation = bind(EasterEgg.DrWho.hitAnimation, self)
	self.m_ColHitAchievement = bind(EasterEgg.DrWho.hitAchievement, self)
	self.m_SpawnTardis = bind(EasterEgg.DrWho.spawnTardis, self)
	self.m_RenderTardisAlpha = bind(EasterEgg.DrWho.renderTardisAlpha, self)

	setTimer(self.m_SpawnTardis, 600000, 0)
end

function EasterEgg.DrWho:spawnTardis()
	if self.m_Tardis then return end

	if math.random(1, 50) == 1 then
		self.m_Position = self.m_Spawns[math.random(1, #self.m_Spawns)]
		self.m_Tardis = createObject(1337, self.m_Position) --todo change object
		self.m_AnimationColshape = createColSphere(self.m_Position, 40)
		self.m_AchievementColshape = createColSphere(self.m_Position, 3)
		self.m_TardisSound = playSound3D("files/audio/DrWho/tardis_landing.mp3", self.m_Position)
		self.m_TardisSound:setMaxDistance(200)

		addEventHandler("onClientColShapeHit", self.m_AnimationColshape, self.m_ColHitAnimation)
		addEventHandler("onClientColShapeHit", self.m_AchievementColshape, self.m_ColHitAchievement)
	end
end

function EasterEgg.DrWho:despawnTardis()
	removeEventHandler("onClientRender", root, self.m_RenderTardisAlpha)
	self.m_Tardis:destroy()
	self.m_Tardis = false
	self.m_AnimationColshape:destroy()
	self.m_AchievementColshape:destroy()
end

local rotationTick = getTickCount()
function EasterEgg.DrWho:renderTardisAlpha()
	local angle = math.fmod((getTickCount() - rotationTick) * 360 / 5000, 360)
	if not isElementStreamedIn(self.m_Tardis) then return end
	if self.m_TardisAlpha == "pulsating" then
		local x = interpolateBetween(160, 0, 0, 255, 0, 0, ((getTickCount()-self.m_StartTick)%2000)/2000, "CosineCurve")
		self.m_Tardis:setAlpha(x)
		self.m_Tardis:setRotation(0, 0, angle)
	elseif self.m_TardisAlpha == "takeoff" then
		local p = (getTickCount()-self.m_StartTick)/1800
		local x = interpolateBetween(255, 0, 0, 140, 0, 0, p, "OutQuad")
		self.m_Tardis:setAlpha(x)
		self.m_Tardis:setRotation(0, 0, angle)

		if p >= 1 then
			self:despawnTardis()
		end
	end
end

function EasterEgg.DrWho:hitAnimation(theElement, matchingDimension)
	removeEventHandler("onClientColShapeHit", self.m_AnimationColshape, self.m_ColHitAnimation)

	self.m_TardisAlpha = "pulsating"
	self.m_StartTick = getTickCount()
	addEventHandler("onClientRender", root, self.m_RenderTardisAlpha)

	setTimer(
		function()
			if self.m_TardisAlpha ~= "takeoff" then
				self.m_TardisAlpha = "takeoff"
				self.m_StartTick = getTickCount()
			end
		end, 4000, 1
	)

	self.m_TardisSound = playSound3D("files/audio/DrWho/tardis_takeoff.mp3", self.m_Position)
	self.m_TardisSound:setPlaybackPosition(14)
	self.m_TardisSound:setMaxDistance(60)
end

function EasterEgg.DrWho:hitAchievement(theElement, matchingDimension)
	self.m_TardisAlpha = "takeoff"
	self.m_StartTick = getTickCount()

	localPlayer:giveAchievement(86)
end
