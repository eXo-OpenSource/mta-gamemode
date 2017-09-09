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

	local rouletteMarkers = {
		createMarker(2230.30, 1615.95, 1005.225, "cylinder", 1, 255, 80, 0, 200),
		createMarker(2242.00, 1615.95, 1005.225, "cylinder", 1, 255, 80, 0, 200),
		createMarker(2230.40, 1618.25, 1005.225, "cylinder", 1, 255, 80, 0, 200),
		createMarker(2242.00, 1618.25, 1005.225, "cylinder", 1, 255, 80, 0, 200),
		createMarker(2230.30, 1596.13, 1005.225, "cylinder", 1, 255, 80, 0, 200),
		createMarker(2230.30, 1590.56, 1005.225, "cylinder", 1, 255, 80, 0, 200),
		createMarker(2242.00, 1596.13, 1005.225, "cylinder", 1, 255, 80, 0, 200),
		createMarker(2242.00, 1590.56, 1005.225, "cylinder", 1, 255, 80, 0, 200),

	}
	--local marker_BomberMan2D = createMarker(self.m_BomberMan2DMarker, "cylinder", 1, 255, 80, 0, 200)

	marker_GoJump:setInterior(1)
	marker_SideSwipe:setInterior(1)
	marker_2Cars:setInterior(1)
	--marker_BomberMan2D:setInterior(1)

	addEventHandler("onClientMarkerHit", marker_GoJump,
		function(hitElement)
			if hitElement:getType() ~= "player" then return end
			if hitElement ~= localPlayer then return end

			MinigameGUI:new("GoJump")
		end
	)

	addEventHandler("onClientMarkerHit", marker_SideSwipe,
		function(hitElement)
			if hitElement:getType() ~= "player" then return end
			if hitElement ~= localPlayer then return end

			MinigameGUI:new("SideSwipe")
		end
	)

	addEventHandler("onClientMarkerHit", marker_2Cars,
		function(hitElement)
			if hitElement:getType() ~= "player" then return end
			if hitElement ~= localPlayer then return end

			MinigameGUI:new("2Cars")
		end
	)

	for index, marker in pairs(rouletteMarkers) do
		marker:setInterior(1)
		addEventHandler("onClientMarkerHit", marker,
			function(hitElement)
				if hitElement:getType() ~= "player" then return end
				if hitElement ~= localPlayer then return end

				MinigameGUI:new("Roulette")
			end
		)
	end
end
