-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIRating.lua
-- *  PURPOSE:     GUI Star Rating class
-- *
-- ****************************************************************************
GUIRating = inherit(GUIElement)
inherit(GUIColorable, GUIImage)

function GUIRating:constructor(posX, posY, width, height, amount, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIColorable.constructor(self, Color.White)

	self.m_Amount = amount
	self.m_Stars = {}
	self.m_HoverColor = Color.Accent

	self.m_Margin = math.floor(width/amount)

	self.m_Rated = false

	for i=1, amount do
		self.m_Stars[i] = GUIImage:new(self.m_Margin*(i-1), 0, self.m_Height, self.m_Height, "files/images/GUI/Star.png", self)
		self.m_Stars[i]:setColor(self.m_Color)
		self.m_Stars[i].onHover = bind(self.onStarHover, self, i)
		self.m_Stars[i].onLeftClick = bind(self.onRating, self, i)
	end

	self.onUnhover = bind(self.onUnhover, self)
end

function GUIRating:onStarHover(star)
	if self.m_Rated then return end
	for i=1, self.m_Amount do
		if i <= star then
			self.m_Stars[i]:setColor(self.m_HoverColor)
		else
			self.m_Stars[i]:setColor(self.m_Color)
		end
	end
end

function GUIRating:onUnhover()
	if self.m_Rated then return end
	for i=1, self.m_Amount do
		self.m_Stars[i]:setColor(self.m_Color)
	end
end

function GUIRating:onRating(star)
	if self.m_Rated then return end
	self:onStarHover(star)
	self.m_Rated = star

	if self.onChange then
		self.onChange(self.m_Rated)
	end
end

function GUIRating:reset()
	self.m_Rated = false
	self:onUnhover()
end

function GUIRating:getRating()
	return self.m_Rated
end
