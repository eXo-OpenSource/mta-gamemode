-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/BreakingNews.lua
-- *  PURPOSE:     Breaking News class
-- *
-- ****************************************************************************
BreakingNews = inherit(Singleton)

function BreakingNews:constructor(text)
	self.m_Width, self.m_Height = screenWidth*0.6, 50
	self.m_NewsOffset = 0
	self.m_News = {text}
	
	self.m_Render = bind(BreakingNews.render, self)	
	addEventHandler("onClientRender", root, self.m_Render)
	
	self.m_AnimationDone = 
		function()
			--todo show next news if any is in queue
		end
	self.m_NewsAnimation = CAnimation:new(self, "m_NewsOffset")
end

function BreakingNews:destructor()
	removeEventHandler("onClientRender", root, self.m_Render)
end

function BreakingNews:addNews(text)
	table.insert(self.m_News, text)
	
	if not self.m_NewsAnimation:isAnimationRendered() then
		self.m_NewsAnimation:startAnimation(1000, "OutQuad", self.m_Height)
	end
end

function BreakingNews:updateRenderTarget()
	self.m_RenderTarget:setAsTarget()
	
	dxDrawImage(0, 0, self.m_Width - 24, self.m_Height, "files/images/Other/BreakingNewsBG.png")
	dxDrawImage(self.m_Width - 24, 0, 24, self.m_Height, "files/images/Other/BreakingNewsEnd.png")
	dxDrawImage(5, self.m_Height/2 - 40/2, 71, 40, "files/images/Other/BreakingNews.png")
	
	for i, news in ipairs(self.m_News) do
		local offset = (i-1)*self.m_Height - self.m_NewsOffset
		dxDrawText(news, 85, offset, self.m_Width - 85, self.m_Height, Color.White, 1, VRPFont(32), "left", "center")
	end
	
	dxSetRenderTarget()
end

function BreakingNews:render()
	dxDrawImage(0, 0, self.m_Width, self.m_Height, self.m_RenderTarget)
end

addEvent("breakingNews", true)
addEventHandler("breakingNews", root, function(...)
	if BreakingNews:isInstantiated() then 
		BreakingNews:getSingleton():addNews(...)
		return
	end
	
	BreakingNews:new(...)
end)