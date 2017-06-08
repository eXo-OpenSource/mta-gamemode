--
-- PewX (HorrorClown)
-- Using: IntelliJ IDEA 14 Ultimate
-- Date: 30.09.2015 - Time: 22:28
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
CAnimation = inherit(Object)

function CAnimation:constructor(CInstance, ...)
	self.isRendering = false
	self.doCall = true

	self.instance = CInstance
	self.tbl_Objects = {...}

	if type(self.tbl_Objects[1]) == "function" then
		self.callbackFunction = self.tbl_Objects[1]
		table.remove(self.tbl_Objects, 1)
	end

	self.renderFunc = bind(CAnimation.render, self)
end

function CAnimation:destructor()
	if self.isRendering then
		removeEventHandler("onClientPreRender", root, self.renderFunc)
	end
end

function CAnimation:updateCallbackFunction(...)
	self.callbackArguments = {...}

	if type(self.callbackArguments[1]) == "function" then
		self.callbackFunction = self.callbackArguments[1]
		table.remove(self.callbackArguments, 1)
	end
end

function CAnimation:callRenderTarget(state)
	self.doCall = state
	return self
end

function CAnimation:startAnimation(nDuration, sAnimationType, ...)
	self.startTick = getTickCount()
	self.endTick = self.startTick + nDuration
	self.animationType = sAnimationType
	self.tbl_animateTo = {...}

	if #self.tbl_Objects ~= #self.tbl_animateTo then
		outputDebugString("Invalid animations to object count")
		return false
	end

	self.n_ObjectCount = #self.tbl_Objects

	self.startValues = {}
	for i = 1, self.n_ObjectCount do
		self.startValues[i] = self.instance[self.tbl_Objects[i]]
	end

	if not self.isRendering then
		self.isRendering = true
		addEventHandler("onClientPreRender", root, self.renderFunc)
	end
end

function CAnimation:isAnimationRendered()
	return self.isRendering
end

function CAnimation:stopAnimation()
	removeEventHandler("onClientPreRender", root, self.renderFunc)
	self.isRendering = false
end

function CAnimation:render()
	local p = (getTickCount()-self.startTick)/(self.endTick-self.startTick)
	for i = 1, #self.tbl_Objects do
		self.instance[self.tbl_Objects[i]] = interpolateBetween(self.startValues[i], 0, 0, self.tbl_animateTo[i], 0, 0, p, self.animationType)
	end

	if self.doCall and self.instance.updateRenderTarget then
		self.instance:updateRenderTarget()
	end

	if p >= 1 then
		self.isRendering = false
		removeEventHandler("onClientPreRender", root, self.renderFunc)
		if self.callbackFunction then
			self.callbackFunction(unpack(self.callbackArguments or {}))
		end
	end
end
