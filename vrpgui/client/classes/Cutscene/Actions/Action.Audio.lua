Action.Audio = inherit(Object)

-- Draw some text
Action.Audio.playSound = inherit(Object)
Action.Audio.playSound.constructor = function(self, data, scene)
	self.path = data.path
	self.looped = data.looped or false
	self.sound = false
end
Action.Audio.playSound.start = function(self)
	self.sound = playSound(self.path, self.looped)
end
Action.Audio.playSound.stop = function(self)
	destroyElement(self.sound)
end