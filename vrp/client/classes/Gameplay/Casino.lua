-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Casino.lua
-- *  PURPOSE:     Casino singleton class
-- *
-- ****************************************************************************
Casino = inherit(Singleton)

function Casino:constructor()
	--Todo: Make game console clickable instead of markers

	--Minigames
	self.m_GoJumpMarker = Vector3(2252.187, 1596.476, 1005.225)			--temp
	self.m_SideSwipeMarker = Vector3(2255.223, 1589.773, 1005.225)		--temp
	self.m_DTSMarker = Vector3(2255.223, 1596.476, 1005.225)			--temp
	self.m_BomberMan2DMarker = Vector3(2252.187, 1589.773, 1005.225)	--temp	(Todo: implement multiplayer to BomberMan2D (up to 4 players))
	--self.m_TetrisMarker = Vector3(2252.187, 1589.773, 1005.225)		--temp	(Todo: Tetris (multiplayer up to 6 players))

	self:createGameMarker()
end

function Casino:createGameMarker()
	local marker_GoJump = createMarker(self.m_GoJumpMarker, "cylinder", 1, 255, 80, 0, 200)
	local marker_SideSwipe = createMarker(self.m_SideSwipeMarker, "cylinder", 1, 255, 80, 0, 200)
	local marker_DTS = createMarker(self.m_DTSMarker, "cylinder", 1, 255, 80, 0, 200)
	local marker_BomberMan2D = createMarker(self.m_BomberMan2DMarker, "cylinder", 1, 255, 80, 0, 200)

	marker_GoJump:setInterior(1)
	marker_SideSwipe:setInterior(1)
	marker_DTS:setInterior(1)
	marker_BomberMan2D:setInterior(1)

	addEventHandler("onClientMarkerHit", marker_GoJump,
		function(hitElement)
			if hitElement:getType() ~= "player" then return end
			if hitElement ~= localPlayer then return end

			GoJump:new()
		end
	)

	addEventHandler("onClientMarkerHit", marker_SideSwipe,
		function(hitElement)
			if hitElement:getType() ~= "player" then return end
			if hitElement ~= localPlayer then return end

			SideSwipe:new()
		end
	)

	addEventHandler("onClientMarkerHit", marker_DTS,
		function(hitElement)
			if hitElement:getType() ~= "player" then return end
			if hitElement ~= localPlayer then return end

			--DTS:new()
		end
	)

	addEventHandler("onClientMarkerHit", marker_BomberMan2D,
		function(hitElement)
			if hitElement:getType() ~= "player" then return end
			if hitElement ~= localPlayer then return end

			--DTS:new()
		end
	)
end
