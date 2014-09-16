Action.Graphic = inherit(Object)

-- Draw some text
Action.Graphic.drawText = inherit(Object)
Action.Graphic.drawText.constructor = function(self, data, scene)
	self.text = data.text
	local sw, sh = guiGetScreenSize()
	self.x = data.pos[1] * sw
	self.y = data.pos[2] * sh
	self.color = data.color or tocolor(255, 255, 255)
	self.scale = data.scale or 1
	self.font = data.font or "default"
end

Action.Graphic.drawText.render = function(self)
	dxDrawText(self.text, self.x, self.y, self.w, self.h, self.color, self.scale, self.font, "center", "center")
end


Action.Graphic.drawImage = inherit(Object)
Action.Graphic.drawImage.constructor = function(self, data, scene)
	self.path = data.path
	local sw, sh = guiGetScreenSize()
	self.x = data.pos[1] * sw
	self.y = data.pos[2] * sh
	self.width = data.size[1] * sw
	self.height = data.size[2] * sh
	self.rotation = data.rotation or 0
end

Action.Graphic.drawImage.render = function(self)
	dxDrawImage(self.x, self.y, self.width, self.height, self.path, self.rotation)
end


Action.Graphic.setLetterBoxText = inherit(Object)
Action.Graphic.setLetterBoxText.constructor = function(self, data, scene)
	self.text = data.text
end

Action.Graphic.setLetterBoxText.render = function(self)
	local sw, sh = guiGetScreenSize()
	dxDrawText(self.text, sw/2, sh*0.92, sw/2, sh*0.91, tocolor(255, 255, 255), 2, "default", "center", "center")
end
