-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
TurtleRace = inherit(Singleton)
addRemoteEvents{"turtleRaceSyncTurtles"}

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
	for _, turtle in pairs(turtles) do
		local shader = dxCreateShader("files/shader/texreplace.fx")
		local texture = dxCreateTexture(("files/images/Textures/Turtles/%s.png"):format(turtle.id))
		dxSetShaderValue(shader, "gTexture", texture)
		engineApplyShaderToWorldTexture(shader, "turtletop", turtle.object)
	end

	self.m_Turtles = turtles
	--addEventHandler("onClientRender", root, bind(TurtleRace.interpolateTurtlePositions, self))
end

function TurtleRace:destructor()
end

function TurtleRace:interpolateTurtlePositions()
end

function TurtleRace:updatePosition(turtles)
	for k, v in pairs(turtles) do
		local x, y, z = unpack(v.toPosition)
		local groundPosition = getGroundPosition(x, y, z)
		v.object:setPosition(x, y, groundPosition + 0.1)
	end
end

addEventHandler("turtleRaceSyncTurtles", root,
	function(turtles)
		if not TurtleRace:isInstantiated() then
			TurtleRace:new(turtles)
		end

		TurtleRace:getSingleton():updatePosition(turtles)
	end
)
