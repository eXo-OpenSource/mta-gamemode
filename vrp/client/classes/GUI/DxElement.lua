-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/DxElement.lua
-- *  PURPOSE:     Dx element super class
-- *
-- ****************************************************************************
DxElement = inherit(Object)

function DxElement:constructor(posX, posY, width, height, parent, isRelative)
	self.m_Parent = parent
	if not parent and not instanceof(self, CacheArea) then
		self.m_Parent = GUIRenderer.cacheroot
	end

	if self.m_Parent then
		self.m_Parent.m_Children[#self.m_Parent.m_Children+1] = self
		self.m_Parent.m_ChildrenByObject[self] = true
	end

	self.m_PosX   = math.floor(posX)
	self.m_PosY   = math.floor(posY)
	self.m_Width  = math.floor(width)
	self.m_Height = math.floor(height)

	self.m_Children = {}
	self.m_ChildrenByObject = {}
	self.m_Visible = true
	self.m_Alpha = 255

	-- Caching in Rendertargets
	--self:anyChange()

	-- Find cache area if exists
	if self.m_Parent and instanceof(self.m_Parent, CacheArea) and self.m_Parent.m_CachingEnabled then
		self.m_CacheArea = self.m_Parent
	end
	if self.m_Parent and self.m_Parent.m_CacheArea and self.m_Parent.m_CacheArea.m_CachingEnabled then
		self.m_CacheArea = self.m_Parent.m_CacheArea
	end

	-- AbsX and AbsY
	self.m_AbsoluteX, self.m_AbsoluteY = self.m_PosX, self.m_PosY
	local lastElement = parent
	while lastElement do
		self.m_AbsoluteX = self.m_AbsoluteX + lastElement.m_PosX
		self.m_AbsoluteY = self.m_AbsoluteY + lastElement.m_PosY
		lastElement = lastElement.m_Parent
	end

	-- Ignore cache areas as rendertargets have their own offset position
	if self.m_CacheArea then
		self.m_AbsoluteX = self.m_AbsoluteX - self.m_CacheArea.m_AbsoluteX
		self.m_AbsoluteY = self.m_AbsoluteY - self.m_CacheArea.m_AbsoluteY
	end
end

function DxElement:destructor(keepParent)
	if self.onHide then self:onHide() end
	--outputDebug("called destructor for ", DxHelper:getSingleton():getElementClassName(self) or "", self.getText and self:getText() or "")

	-- Delete the children (--> call their destructor)
	for k, v in ipairs(self.m_Children) do
		--outputDebug("called child destructor of ", DxHelper:getSingleton():getElementClassName(v) or "", v.getText and v:getText() or "")
		delete(v, true)
	end

	-- Unlink from parent
	if not keepParent and self.m_Parent then
		for k, v in ipairs(self.m_Parent.m_Children) do
			if v == self then
				table.remove(self.m_Parent.m_Children, k)
				break
			end
		end
		self.m_Parent.m_ChildrenByObject[self] = nil
	end

	self:anyChange()
end

function DxElement:anyChange()
	if self.m_CacheArea then
		return self.m_CacheArea:updateArea()
	end

	local cacheElement = self.m_Parent
	while cacheElement do
		-- Redraw everything in this area
		if cacheElement.updateArea then
			return cacheElement:updateArea()
		end
		cacheElement = cacheElement.m_Parent
	end
	return false
end

function DxElement:draw(incache)
	if self.m_Visible then
		-- Draw me
		if self.drawThis then
			self:drawThis(incache)
		end

		-- Draw children
		for k, v in ipairs(self.m_Children) do
			if v.m_Visible and v.draw then
				v:draw(incache)
			end
		end
	end
end

function DxElement:update(elapsedTime)
	for k, v in ipairs(self.m_Children) do
		if v.update then
			v:update(elapsedTime)
		end
	end
end

function DxElement:isVisible(checkParents)
	if checkParents and self.m_Parent then
		return self.m_Parent:isVisible(true)
	end
	return self.m_Visible
end

function DxElement:setVisible(visible, getPropagated)
	self.m_Visible = visible
	if visible then
		if self.onShow then self:onShow() end
	else
		if self.onHide then self:onHide() end
	end

	if getPropagated then
		for k, v in ipairs(self.m_Children) do
			v:setVisible(visible)
		end
	end

	if visible and self.m_CacheArea then
		self.m_CacheArea:bringToFront()
	end

	self:anyChange()
	return self
end

function DxElement:getChildren()
	return self.m_Children
end

function DxElement:getChildrenRecursive()
	local list = {}
	getSubelements = function(self)
		for k, v in pairs(self:getChildren()) do
			list[#list+1] = v
			getSubelements(v)
		end
	end
	getSubelements(self)
	return list
end

function DxElement:clearChildren()
	for k, v in ipairs(self.m_Children) do
		delete(v)
	end
	self.m_Children = {}

	self:anyChange()
end

function DxElement:getParent()
	return self.m_Parent
end

function DxElement:setParent(parent)
	-- Unlink from old parent first
	table.remove(self.m_Parent.m_Children, table.find(self.m_Parent.m_Children, self))

	-- Set the new parent element and link
	self.m_Parent = parent
	parent.m_Children[#self.m_Parent.m_Children+1] = self

	self:anyChange()
	return self
end

function DxElement:getPosition(isAbsolute)
	if not isAbsolute then
		return self.m_PosX, self.m_PosY
	end

	local absoluteX, absoluteY = self.m_AbsoluteX, self.m_AbsoluteY
	if self.m_CacheArea then
		absoluteX, absoluteY = absoluteX + self.m_CacheArea.m_AbsoluteX, absoluteY + self.m_CacheArea.m_AbsoluteY
	end
	return absoluteX, absoluteY
end

function DxElement:getSize()
	return self.m_Width, self.m_Height
end

function DxElement:setSize(width, height)
	if width == nil then width = self.m_Width end
	if height == nil then height = self.m_Height end

	self.m_Width = width
	self.m_Height = height

	self:anyChange()
	return self
end

function DxElement:setPosition(posX, posY)
	if posX == nil then
		posX = self.m_PosX
	end
	if posY == nil then
		posY = self.m_PosY
	end

	local diffX, diffY = posX-self.m_PosX, posY-self.m_PosY
	self.m_PosX, self.m_PosY = posX, posY
	self.m_AbsoluteX, self.m_AbsoluteY = self.m_AbsoluteX + diffX, self.m_AbsoluteY + diffY

	local children = self.m_Children
	while children and #children > 0 do
		for k, v in ipairs(children) do
			v.m_AbsoluteX = v.m_AbsoluteX + diffX
			v.m_AbsoluteY = v.m_AbsoluteY + diffY
		end
		children = children.m_Children
	end

	self:anyChange()
	return self
end

function DxElement:setAbsolutePosition(posX, posY)
	if posX == nil then
		posX = self.m_AbsoluteX
	end
	if posY == nil then
		posY = self.m_AbsoluteY
	end

	self.m_AbsoluteX = posX
	self.m_AbsoluteY = posY

	local diffX, diffY = posX-self.m_AbsoluteX, posY-self.m_AbsoluteY
	local children = self.m_Children
	while children and #children > 0 do
		for k, v in pairs(children) do
			v.m_AbsoluteX = v.m_AbsoluteX + diffX
			v.m_AbsoluteY = v.m_AbsoluteY + diffY
		end
		children = children.m_Children
	end

	if self.m_Parent == GUIRenderer.cacheroot or not self.m_Parent then
		self.m_PosX = posX
		self.m_PosY = posY
	end
	self:anyChange()
	return self
end

function DxElement:isCursorWithinBox(left, top, right, bottom)
	local relCursorX, relCursorY = getCursorPosition()
	if not relCursorX then
		return false
	end

	local cursorX, cursorY = relCursorX * screenWidth, relCursorY * screenHeight
	local absoluteX, absoluteY = self:getPosition(true)

	return cursorX >= absoluteX + left and cursorY >= absoluteY + top and cursorX < absoluteX + right and cursorY < absoluteY + bottom
end

function DxElement:setAlpha(alpha)
	self.m_Alpha = alpha
	self:anyChange()
	return self
end

function DxElement:getAlpha()
	return self.m_Alpha
end

function DxElement:show()
	return self:setVisible(true)
end

function DxElement:hide()
	return self:setVisible(false)
end
