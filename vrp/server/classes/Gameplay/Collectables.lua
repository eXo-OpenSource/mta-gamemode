-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Collectables.lua
-- *  PURPOSE:     Collectables server-side class
-- *
-- ****************************************************************************
Collectables = inherit(Singleton)

addEvent("requestCollectables", true)
addEvent("checkCollectableHit", true)

function Collectables:constructor()
	addEventHandler("requestCollectables", root, bind(self.sendCollectables,self))
	addEventHandler("checkCollectableHit", root, bind(self.checkCollectable,self))
end

function Collectables:checkCollectable(collectableID)
	if not client then return end
	local x,y,z = getElementPosition(client)
	local px,py,pz = unpack(Collectables.POSITIONS[collectableID])
	if getDistanceBetweenPoints3D (x,y,z,px,py,pz) >= 10 then
		print(("WARNING: %s is maybe cheatin' @ collectables"):format(getPlayerName(client)))
	else
		local collectables = client:getCollectables() or {}
		collectables[collectableID] = "1"
		client:setCollectables(collectables)

		client:sendShortMessage(_("Du hast ein eXó-Logo gefunden!\nDafür erhälst du %s eXo-Points!", client, 250))
		client:givePoints(250)
	end
end

function Collectables:sendCollectables()
	if not client then return end

	triggerClientEvent(client,"reciveCollectables",client,Collectables.POSITIONS,client:getCollectables() or {})
end

Collectables.POSITIONS = {
	{1117.60, -2037.10, 78.80},
	{1118.50, -1619.70, 20.5},
	{1349.60, -1665.50, 13.5},
	{1681.40, -1673.00, 20},
	{1691.30, -1951.90, 8.2},
	{1474.40, -2256.20, -3},
	{2370.30, -2544.00, 3},
	{2661.90, -1441.50, 16.30},
	{1971.20, -1157.00, 20.7},
	{1295.80, -985.30 , 32.5},
	{741.00 , -1018.00, 42.5},
	{854.00 , -1386.80, -0.5},
	{325.70 , -1495.60, 24.6},
	{401.90 , -2066.10, 10.5},
	{2955.60, -1486.50, 1.4},
	{2162.00, -103.00 , 2.4},
	{-2235.0, -1743.10, 481},
	{-47.80 , 29.60   , 6.1},
	{-210.50, 1770.00 , 101.3},
	{2186.70, 2416.50 , 72.8},
	{1954.50, 1343.00 , 15},
	{-2237.2, 2467.20 , 4.9},
	{-1426.8, 1490.00 , 1.6},
	{-2079.7, 1065.00 , 65.6},
	{-2481.7, -284.70 , 40.5}
}
