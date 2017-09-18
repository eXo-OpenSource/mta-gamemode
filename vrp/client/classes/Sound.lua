-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Sound.lua
-- *  PURPOSE:     Manage sounds easier -- Todo: should be optimized
-- *
-- ****************************************************************************
SoundManager = inherit(Object)

function SoundManager:constructor(path, format)
	self.m_Sounds = {}
	self.m_Path = path
	self.m_SoundFormat = format or "mp3"
end

function SoundManager:destructor()
	-- Stop Sounds
	self:stopAll()
end

function SoundManager:stopAll()
	for _, v in pairs(self.m_Sounds) do
		delete(v)
	end
end

function SoundManager:play(sound, looped)
	--if self.m_Sounds[sound] then delete(self.m_Sounds[sound]) end

	self.m_Sounds[sound] = Sound:new(("%s/%s.%s"):format(self.m_Path, sound, self.m_SoundFormat), looped)
	return self.m_Sounds[sound]
end

function SoundManager:stop(sound)
	if self.m_Sounds[sound] then
		delete(self.m_Sounds[sound])
	end
end

function SoundManager:fadeIn(sound, length)
	self.m_Sounds[sound]:fadeIn(length)
end

function SoundManager:fadeOut(sound, length)
	self.m_Sounds[sound]:fadeOut(length)
end

-----------
Sound = inherit(Object)

function Sound:constructor(sound, looped)
	self.m_Sound = playSound(sound, looped)

	self.m_Fade = CAnimation:new(self, "m_Volume")
	self.m_Volume = 0
end

function Sound:destructor()
	if isElement(self.m_Sound) then
		self.m_Sound:destroy()
		self.m_Sound = nil
	end
end

function Sound:fadeIn(length)
	self.m_Sound:setVolume(0)
	self.m_Fade:startAnimation(length or 10000, "OutQuad", 1)
	
	return self
end

function Sound:fadeOut(length)
	self.m_Sound:setVolume(1)
	self.m_Fade:startAnimation(length or 10000, "OutQuad", 0)
	
	return self
end

function Sound:setVolume(volume)
	self.m_Sound:setVolume(volume)
	
	return self
end

function Sound:updateRenderTarget()
	self.m_Sound:setVolume(self.m_Volume)
end

function Sound.create(sound, looped)
	return playSound(sound, looped)
end
