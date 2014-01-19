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