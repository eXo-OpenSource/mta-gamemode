Action.General = inherit(Object)

-- Switch to another scene
Action.General.change_scene = inherit(Object)
Action.General.change_scene.duration = false;
Action.General.change_scene.constructor = function(self, data, scene)
	assert(data.scene)
	self.scene = data.scene
	self.parentScene = scene
end

Action.General.change_scene.trigger = function(self)
	self.parentScene:getCutscene():setScene(self.scene)
end

-- Stop the cutscene and call the finish callback
Action.General.finish = inherit(Object)
Action.General.finish.duration = false;
Action.General.finish.constructor = function(self, data, scene)
	self.parentScene = scene
end

Action.General.finish.trigger = function(self)
	self.parentScene:getCutscene():stop()
end

-- Fade
Action.General.fade = inherit(Object)
Action.General.fade.duration = false;
Action.General.fade.constructor = function(self, data, scene)
	assert(data.fadein ~= nil)
	assert(data.time)
	self.fadein = data.fadein
	self.time = data.time
	self.parentScene = scene
end

Action.General.fade.trigger = function(self)
	fadeCamera(self.fadein, self.time/1000)
end

-- Explosion
Action.General.explode = inherit(Object)
Action.General.explode.duration = false;
Action.General.explode.constructor = function(self, data, scene)
	assert(data.pos)
	assert(data.explosionType)
	self.x, self.y, self.z = unpack(data.pos)
	self.explosionType = data.explosionType
	self.parentScene = scene
end

Action.General.explode.trigger = function(self)
	createExplosion(self.x, self.y, self.z, self.explosionType)
end

-- Weather
Action.General.weather = inherit(Object)
Action.General.weather.duration = false;
Action.General.weather.constructor = function(self, data, scene)
	assert(data.weather)
	self.weather = data.weather
	self.parentScene = scene
end

Action.General.weather.trigger = function(self)
	setWeather(self.weather)
end

-- Time
Action.General.explode = inherit(Object)
Action.General.explode.duration = false;
Action.General.explode.constructor = function(self, data, scene)
	assert(data.pos)
	assert(data.explosionType)
	self.x, self.y, self.z = unpack(data.pos)
	self.explosionType = data.explosionType
	self.parentScene = scene
end

Action.General.explode.trigger = function(self)
	createExplosion(self.x, self.y, self.z, self.explosionType)
end