-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/ElementInfo.lua
-- *  PURPOSE:     ElementInfoManager class
-- *
-- ****************************************************************************

ElementInfoManager = inherit(Singleton)

function ElementInfoManager:constructor()
	self.m_Infos = {}
	self.m_Start = getTickCount()
	self.m_RenderBind = bind(self.iterate, self)
	self:setState(core:get("HUD", "elementHelpCaption", true))
	GUIRenderer.reattachEvents()
end

function ElementInfoManager:destructor()
	removeEventHandler("onClientRender", root, self.m_RenderBind)
end

function ElementInfoManager:setState(bool)
	if bool then 
		removeEventHandler("onClientRender", root, self.m_RenderBind)
		addEventHandler("onClientRender", root, self.m_RenderBind)
	else 
		removeEventHandler("onClientRender", root, self.m_RenderBind)
	end
end

function ElementInfoManager:iterate()
	local now = getTickCount() 
	local prog = (now - self.m_Start) / 2000
	if prog > 1 then self.m_Start = getTickCount() end
	for object, info in pairs(self.m_Infos) do 
		if object and isElement(object) and isElementOnScreen(object) then
			local check = self:check(object) 
			if check then
				info:draw(check, prog)
			end
		end
	end
end

function ElementInfoManager:check(object)
	if object:getInterior() == localPlayer:getInterior() then 
		if object:getDimension() == localPlayer:getDimension() then 
			local cx, cy, cz = getCameraMatrix()
			local dist = Vector3(object:getPosition() - Vector3(cx, cy, cz)):getLength()
			if dist < 15 then 
				return dist
			end
		end
	end
	return false
end

addEvent("elementInfoCreate", true)
addEventHandler("elementInfoCreate", root,
	function(object, text, offset)
		if object and isElement(object) then
			ElementInfo:new(object, text, offset)
		end
	end
	)

addEvent("elementInfoRetrieve", true)
addEventHandler("elementInfoRetrieve", root,
	function(data) 
		for object, subdata in pairs(data) do 
			if object and isElement(object) then
				ElementInfo:new(object, subdata[1], subdata[2], subdata[3])
			end
		end
	end)