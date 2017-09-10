-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
TurtleRace = inherit(Singleton)
TurtleRace.Effects = {"explosion_fuel_car", "explosion_small", "explosion_medium"}
addRemoteEvents{"turtleRaceInit", "turtleRaceSyncTurtles", "turtleRaceStop", "turtleRaceCountdown"}

function TurtleRace.load()
	local ped = Ped.create(198, Vector3(318, -1820, 4.19), 270)
	local turtleHat = createObject(1609, Vector3(318, -1820, 4.19))
	turtleHat:setScale(0.15)
	exports.bone_attach:attachElementToBone(turtleHat, ped, 1, -0.01, 0.01, 0.15, 10, 0)

	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Krötenprofi Diana", "TURTLE RACE!")
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			TurtleRaceGUI:new()
		end
	)
end

function TurtleRace:constructor(turtles)
	for _, turtle in pairs(turtles) do
		local shader = dxCreateShader("files/shader/texreplace.fx")
		local texture = dxCreateTexture(("files/images/Textures/Turtles/%s.png"):format(turtle.id))
		dxSetShaderValue(shader, "gTexture", texture)
		engineApplyShaderToWorldTexture(shader, "turtletop", turtle.object)
	end

	self.m_Turtles = turtles
	self.m_InterpolateTurtlePositions = bind(TurtleRace.interpolateTurtlePositions, self)
	self.m_OnTurtleGetRekt = bind(TurtleRace.onClientExplosion, self)
	addEventHandler("onClientRender", root, self.m_InterpolateTurtlePositions)
	addEventHandler("onClientExplosion", root, self.m_OnTurtleGetRekt)
end

function TurtleRace:destructor()
	removeEventHandler("onClientRender", root, self.m_InterpolateTurtlePositions)
	removeEventHandler("onClientExplosion", root, self.m_OnTurtleGetRekt)
end

function TurtleRace:interpolateTurtlePositions()
	for _, turtle in pairs(self.m_Turtles) do
		if turtle.startTick then
			local p = (getTickCount()-turtle.startTick)/(turtle.endTick-turtle.startTick)
			local position = Vector3(interpolateBetween(turtle.startPosition, turtle.endPosition, p, "Linear"))
			local rotation =  Vector3(interpolateBetween(turtle.startRotation, turtle.endRotation, math.min(1, p*4), "Linear")) + Vector3(interpolateBetween(0, 0, -5, 0, 0, 10, p, "SineCurve"))

			turtle.object:setPosition(position)
			turtle.object:setRotation(rotation)
		end
	end
end

function TurtleRace:updatePosition(turtles)
	for k, v in pairs(turtles) do
		local x, y, z = unpack(v.startPosition)
		v.startPosition = Vector3(x, y, getGroundPosition(x, y, z) + .1)

		local x, y, z = unpack(v.endPosition)
		v.endPosition = Vector3(x, y, getGroundPosition(x, y, z) + .1)

		local diff = v.endPosition.x-v.startPosition.x
		v.startRotation = v.object:getRotation()
		v.endRotation = Vector3(0, 0, 180 + diff*40)

		v.startTick = getTickCount()
		v.endTick = v.startTick + v.duration
	end

	self.m_Turtles = turtles
end

function TurtleRace:onClientExplosion(x, y, z)
	for _, turtle in pairs(self.m_Turtles) do
		if (turtle.object.position - Vector3(x, y, z)).length <= 10 then
			cancelEvent()
		end
	end
end

function TurtleRace:createTurtleEffects(wonTurtle)
	for _, turtle in pairs(self.m_Turtles) do
		if turtle.id == wonTurtle then
			local effect = createEffect("smoke_flare", turtle.object.position, -90)
			setTimer(destroyElement, 30000, 1, effect)
		else
			turtle.object:setAlpha(0)
			createEffect(TurtleRace.Effects[math.random(1, 3)], turtle.object.position)
		end
	end
end

addEventHandler("turtleRaceInit", root,
	function(turtles)
		if not TurtleRace:isInstantiated() then
			TurtleRace:new(turtles)
		end
	end
)

addEventHandler("turtleRaceSyncTurtles", root,
	function(turtles)
		if not TurtleRace:isInstantiated() then
			TurtleRace:new(turtles)
		end

		TurtleRace:getSingleton():updatePosition(turtles)
	end
)

addEventHandler("turtleRaceStop", root,
	function(wonTurtle)
		if TurtleRace:isInstantiated() then
			TurtleRace:getSingleton():createTurtleEffects(wonTurtle)
			delete(TurtleRace:getSingleton())
		end
	end
)

addEventHandler("turtleRaceCountdown", root,
	function()
		if not TurtleRace:isInstantiated() then return end

		local shortMessage = ShortMessage:new(_"Das Schildkrötenrennen startet in 3 Sekunden!", _"Schildkrötenrennen", {50, 170, 20}, 3000)
		local countdown = 3
		setTimer(
			function()
				countdown = countdown - 1
				shortMessage:setText(_("Das Schildkrötenrennen startet in %s Sekunden!", countdown))
			end, 1000, 3
		)
	end
)
