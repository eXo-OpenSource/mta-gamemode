local IMAGE_PATH = EASTEREGG_IMAGE_PATH
local FILE_PATH = EASTEREGG_FILE_PATH
local SFX_PATH = EASTEREGG_SFX_PATH
local TICK_CAP = EASTEREGG_TICK_CAP
local NATIVE_RATIO = EASTEREGG_NATIVE_RATIO
local WINDOW_WIDTH, EASTEREGG_WINDOW_HEIGHT = EASTEREGG_WINDOW_WIDTH, EASTEREGG_WINDOW_HEIGHT
local FONT_SCALE = EASTEREGG_FONT_SCALE
local JUMP_RATIO = EASTEREGG_JUMP_RATIO
local PROJECTILE_SPEED = EASTEREGG_PROJECTILE_SPEED
local FONT_SCALE = EASTEREGG_FONT_SCALE
local WINDOW = EASTEREGG_WINDOW
local JUMP_RATIO = EASTEREGG_JUMP_RATIO
local PROJECTILE_SPEED = EASTEREGG_PROJECTILE_SPEED
local RESOLUTION_RATIO = EASTEREGG_RESOLUTION_RATIO
local KEY_MOVES = EASTEREGG_KEY_MOVES

EasterEggArcade.Render = inherit(Object) 

function EasterEggArcade.Render:constructor( start, bound )
	self.m_Start = start 
	self.m_Bound = bound
	self.m_RenderBind = bind(self.render, self)
	self.m_RenderTarget = dxCreateRenderTarget(bound.x, bound.y)
	self.m_RenderQueue = {}
	addEventHandler("onClientRender", root, self.m_RenderBind)
end


function EasterEggArcade.Render:destructor()
	removeEventHandler("onClientRender", root, self.m_RenderBind)
end

function EasterEggArcade.Render:addToQueue( object ) 
	table.insert(self.m_RenderQueue, object)
end

function EasterEggArcade.Render:removeFromQueue(object)
	for i = 1, #self.m_RenderQueue do 
		if self.m_RenderQueue[i] == object then 
			table.remove(self.m_RenderQueue, i)
		end
	end
end

function EasterEggArcade.Render:render()
	for i = 1, #self.m_RenderQueue do 
		if self.m_RenderQueue[i] then
			self:draw( self.m_RenderQueue[i] )
		end
	end
end

function EasterEggArcade.Render:draw( obj ) 
	dxSetRenderTarget(self.m_RenderTarget)
	local x, y, width, height, mat
	if obj then 
		x,y = obj:getPosition()
		width, height = obj:getBound()
		mat = obj:getMaterial()
		if x and y and width and height then
			local w  = WINDOW[1]
			local b = WINDOW[2]
			obj:draw(x-w.x, y-w.y, width, height, mat, obj:getTiled())
		end
	end
	
	if EasterEggArcade.Game:getSingleton():getGameLogic() and EasterEggArcade.Game:getSingleton():getGameLogic():getHUD() then 
		EasterEggArcade.Game:getSingleton():getGameLogic():getHUD():render()
	end
	dxSetRenderTarget()
	dxDrawImage(self.m_Start.x, self.m_Start.y, self.m_Bound.x, self.m_Bound.y, self.m_RenderTarget)
	if EasterEggArcade.Game:getSingleton():getGameLogic() and EasterEggArcade.Game:getSingleton():getGameLogic():getHUD() then 
		EasterEggArcade.Game:getSingleton():getGameLogic():getHUD():drawOverlay()
	end
end