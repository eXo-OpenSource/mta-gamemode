-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/WorldText.lua
-- *  PURPOSE:     WorldText class
-- *
-- ****************************************************************************
WorldTextManager = inherit(Singleton)

function WorldTextManager:constructor()
	self.m_Texts = {}
	
	addEventHandler("onClientPreRender", root, bind(self.renderAll, self))
end

function WorldTextManager:addText(text, position, maxdistance)
	table.insert(self.m_Texts, {text, position, maxdistance or 50})
end

function WorldTextManager:renderAll()
	for k, v in pairs(self.m_Texts) do
		if (localPlayer.position - v[2]).length < v[3] then
			local screenX, screenY = getScreenFromWorldPosition(v[2])
			if screenX then
				dxDrawText(v[1], screenX, screenY, screenX, screenY, Color.White, 1.1, "bankgothic", "center", "center")
			end
		end
	end
end
