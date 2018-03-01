-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Casino.lua
-- *  PURPOSE:     Casino singleton class
-- *
-- ****************************************************************************
Casino = inherit(Singleton)


function Casino:constructor()
	--Minigames
	self.m_GoJumpMarker = Vector3(2252.187, 1596.476, 1005.225)
	self.m_SideSwipeMarker = Vector3(2255.223, 1589.773, 1005.225)
	self.m_2CarsMarker = Vector3(2255.223, 1596.476, 1005.225)
	--self.m_BomberMan2DMarker = Vector3(2252.187, 1589.773, 1005.225)	--temp	(Todo: implement multiplayer to BomberMan2D (up to 4 players))
	--self.m_TetrisMarker = Vector3(2252.187, 1589.773, 1005.225)		--temp	(Todo: Tetris (multiplayer up to 6 players))

	self.m_RoulettePositions = {
		--Caligulas
		{Vector3(2230.30, 1615.95, 1005.225), 1},
		{Vector3(2242.00, 1615.95, 1005.225), 1},
		{Vector3(2230.40, 1618.25, 1005.225), 1},
		{Vector3(2242.00, 1618.25, 1005.225), 1},
		{Vector3(2230.30, 1596.13, 1005.225), 1},
		{Vector3(2230.30, 1590.56, 1005.225), 1},
		{Vector3(2242.00, 1596.13, 1005.225), 1},
		{Vector3(2242.00, 1590.56, 1005.225), 1},
		--Four Dragons
		{Vector3(1962.34, 1009.96, 991.47), 10},
		{Vector3(1958.03, 1009.92, 991.47), 10},
		{Vector3(1958.03, 1025.39, 991.47), 10},
		{Vector3(1962.34, 1025.54, 991.47), 10},
	}

	self.m_RouletteCroupiers = {
		--Caligulas
		{Vector3(2230.30, 1588.10, 1006.18), 0, 1},
		{Vector3(2230.30, 1593.60, 1006.18), 0, 1},
		{Vector3(2230.30, 1613.50, 1006.18), 0, 1},
		{Vector3(2230.30, 1620.70, 1006.18), 180, 1},
		{Vector3(2241.90, 1620.70, 1006.18), 180, 1},
		{Vector3(2241.90, 1613.50, 1006.18), 0, 1},
		{Vector3(2241.90, 1593.60, 1006.18), 0, 1},
		{Vector3(2241.94, 1588.10, 1006.18), 0, 1},
		--Four Dragons
		{Vector3(1960.49, 1025.36, 992.47), 90, 10},
		{Vector3(1964.80, 1025.59, 992.47), 90, 10},
		{Vector3(1964.80, 1009.85, 992.47), 90, 10},
		{Vector3(1960.49, 1009.86, 992.47), 90, 10},
	}

	self:createGameMarker()

	addRemoteEvents{"openChessGui"}
	addEventHandler("openChessGui", root, function(col)
		MultiPlayerGameGUI:new("Multiplayer Schach", col,
			function(player)
				triggerServerEvent("casinoStartMultiplayerGame", localPlayer, "chess", player)
			end
		)
	end)
end

function Casino:createGameMarker()
	local marker_GoJump = createMarker(self.m_GoJumpMarker, "cylinder", 1, 255, 80, 0, 200)
	local marker_SideSwipe = createMarker(self.m_SideSwipeMarker, "cylinder", 1, 255, 80, 0, 200)
	local marker_2Cars = createMarker(self.m_2CarsMarker, "cylinder", 1, 255, 80, 0, 200)
	--local marker_BomberMan2D = createMarker(self.m_BomberMan2DMarker, "cylinder", 1, 255, 80, 0, 200)

	marker_GoJump:setInterior(1)
	marker_SideSwipe:setInterior(1)
	marker_2Cars:setInterior(1)
	--marker_BomberMan2D:setInterior(1)

	addEventHandler("onClientMarkerHit", marker_GoJump,
		function(hitElement, dim)
			if not dim then return end
			if (hitElement.position - source.position).length > 5 then return end
			if hitElement:getType() ~= "player" then return end
			if hitElement ~= localPlayer then return end

			MinigameGUI:new("GoJump")
		end
	)

	addEventHandler("onClientMarkerHit", marker_SideSwipe,
		function(hitElement, dim)
			if not dim then return end
			if (hitElement.position - source.position).length > 5 then return end
			if hitElement:getType() ~= "player" then return end
			if hitElement ~= localPlayer then return end

			MinigameGUI:new("SideSwipe")
		end
	)

	addEventHandler("onClientMarkerHit", marker_2Cars,
		function(hitElement, dim)
			if not dim then return end
			if (hitElement.position - source.position).length > 5 then return end
			if hitElement:getType() ~= "player" then return end
			if hitElement ~= localPlayer then return end

			MinigameGUI:new("2Cars")
		end
	)

	local marker
	for index, pos in pairs(self.m_RoulettePositions) do
		marker = createMarker(pos[1], "cylinder", 1, 255, 80, 0, 200)
		marker:setInterior(pos[2] or 0)
		addEventHandler("onClientMarkerHit", marker,
			function(hitElement, dim)
				if not dim then return end
				if (hitElement.position - source.position).length > 5 then return end
				if hitElement:getType() ~= "player" then return end
				if hitElement ~= localPlayer then return end

				MinigameGUI:new("Roulette")
			end
		)
	end
	local ped
	for index, data in pairs(self.m_RouletteCroupiers) do
		ped = createPed(math.random(171, 172), data[1], data[2])
		ped:setInterior(data[3] or 0)
		ped:setData("NPC:Immortal", true)
		ped:setFrozen(true)
	end
end
