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

EasterEggArcade.Game = inherit(Singleton)

function EasterEggArcade.Game:constructor()
	self.m_Logic = EasterEggArcade.GameLogic:new()
end

function EasterEggArcade.Game:restart() 
	if self.m_Logic then 
		delete(self.m_Logic)
	end
	self.m_Logic = EasterEggArcade.GameLogic:new()
end

function EasterEggArcade.Game:stop()
	if self.m_Logic then 
		self.m_Logic:delete()
	end
end

function EasterEggArcade.Game:getGameLogic()
	return self.m_Logic
end
