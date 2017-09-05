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
	--local shader = dxCreateShader("files/shader/texreplace.fx")
	--local texture = dxCreateTexture(DATEIPFAD_ZUM_BILD_MIT_ZAHL_DRAUF_UND_DEM_TURTLETOP_HINTERGRUND)
	--dxSetShaderValue(shader, "gTexture", texture)
	--engineApplyShaderToWorldTexture(shader, turtletop, OBJEKT_DAS_MIT_CREATEOBJECT_ERSTELLT_WURDE)

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
		if not TurtleRace:getSingleton() then
			TurtleRace:new(turtles)
		end

		TurtleRace:updatePosition(turtles)
	end
)
