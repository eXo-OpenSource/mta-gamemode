Action.General = inherit(Object)

-- Switch to another scene
Action.General.change_scene = inherit(Object)
Action.General.change_scene.duration = false;
Action.General.change_scene.constructor = function(self, data, scene)
	self.scene = data.scene
	self.parentScene = scene
end

Action.General.change_scene.trigger = function(self)
	self.parentScene:getCutscene():setScene(self.scene)
end