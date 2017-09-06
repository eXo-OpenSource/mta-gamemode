-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
TurtleRace = inherit(Singleton)
addRemoteEvents{"turtleRaceInit", "turtleRaceSyncTurtles", "turtleRaceStop"}

function TurtleRace.load()
	local ped = Ped.create(198, Vector3(318, -1820, 4.19), 270)

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
	outputChatBox("constructor")

	for _, turtle in pairs(turtles) do
		local shader = dxCreateShader("files/shader/texreplace.fx")
		local texture = dxCreateTexture(("files/images/Textures/Turtles/%s.png"):format(turtle.id))
		dxSetShaderValue(shader, "gTexture", texture)
		engineApplyShaderToWorldTexture(shader, "turtletop", turtle.object)
	end

	self.m_Turtles = turtles
	addEventHandler("onClientRender", root, bind(TurtleRace.interpolateTurtlePositions, self))
end

function TurtleRace:destructor()
	outputChatBox("Remove event")
	removeEventHandler("onClientRender", root, bind(TurtleRace.interpolateTurtlePositions, self))
end

function TurtleRace:interpolateTurtlePositions()
	for _, turtle in pairs(self.m_Turtles) do
		if turtle.startTick then
			local p = (getTickCount()-turtle.startTick)/(turtle.endTick-turtle.startTick)
			local x, y, z = interpolateBetween(turtle.startPosition, turtle.endPosition, p, "Linear")
			turtle.object:setPosition(x,y,z)
		end
	end
end

function TurtleRace:updatePosition(turtles)
	for k, v in pairs(turtles) do
		local x, y, z = unpack(v.startPosition)
		v.startPosition = Vector3(x, y, getGroundPosition(x, y, z) + .1)

		local x, y, z = unpack(v.endPosition)
		v.endPosition = Vector3(x, y, getGroundPosition(x, y, z) + .1)

		v.startTick = getTickCount()
		v.endTick = v.startTick + v.duration
	end

	self.m_Turtles = turtles
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
	function()
		if TurtleRace:isInstantiated() then
			delete(TurtleRace:getSingleton())
		end
	end
)
