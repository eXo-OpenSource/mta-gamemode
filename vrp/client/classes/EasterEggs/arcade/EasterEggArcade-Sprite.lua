EasterEggArcade.Sprite = inherit(Object) 

function EasterEggArcade.Sprite:virtual_constructor( tiled ) 
	self.m_Sprites = {}
	self.m_Positions = {}
	self.m_Bounds = {}
	self.m_Tiled = tiled
	self.m_Mirrored = false
	self.m_State = ""
	self.m_Static = false
	self.m_Color = tocolor(255, 255, 255, 255)
end

function EasterEggArcade.Sprite:virtual_destructor()
	for i = 1, #self.m_Sprites do 
		if self.m_Sprites[i] and isElement(self.m_Sprites[i]) then
			if getElementType(self.m_Sprites[i]) == "texture" then 
				destroyElement(self.m_Sprites[i])
			end
		end
	end
end

function EasterEggArcade.Sprite:addSpriteIndex( path, dxType ) 
	if path then 
		local material = dxCreateTexture( path , dxType or "argb", true) 
		if material then
			if not self.m_Sprites then self.m_Sprites = {} end
			table.insert( self.m_Sprites, material)
			return #self.m_Sprites
		else 
			if not self.m_Sprites then self.m_Sprites = {} end
			table.insert( self.m_Sprites, path)
			return #self.m_Sprites
		end
	end
end

function EasterEggArcade.Sprite:setSprite( index ) 
	if self.m_Sprites[index] then
		self.m_Sprite = self.m_Sprites[index]
	end
end

function EasterEggArcade.Sprite:setTiled( bool ) 
	self.m_Tiled = bool
end

function EasterEggArcade.Sprite:setMirrored( bool ) 
	self.m_Mirrored = bool
end

function EasterEggArcade.Sprite:setStatic( bool ) 
	self.m_Static = bool
end

function EasterEggArcade.Sprite:getTiled( )
	return self.m_Tiled
end

function EasterEggArcade.Sprite:getMirrored() 
	return self.m_Mirrored
end

function EasterEggArcade.Sprite:getState()
	return self.m_State
end

function EasterEggArcade.Sprite:setState(state)
	self.m_State = state
end

function EasterEggArcade.Sprite:getMaterial() 
	return self.m_Sprite
end

function EasterEggArcade.Sprite:setColor( color )
	self.m_Color = color
end

function EasterEggArcade.Sprite:setTileSize( sx, sy)
	self.m_SpriteSizeX = sx
	self.m_SpriteSizeY = sy
end

function EasterEggArcade.Sprite:setPosition(x, y)
	self.m_Positions = { x, y}
end

function EasterEggArcade.Sprite:getPosition() 
	if not self.m_Positions then self.m_Positions = {} end
	return self.m_Positions[1], self.m_Positions[2]
end

function EasterEggArcade.Sprite:setBound( width, height)
	local aspect_width, aspect_height = EASTEREGG_WINDOW[2].x / EASTEREGG_NATIVE_RATIO.x, EASTEREGG_WINDOW[2].y / EASTEREGG_NATIVE_RATIO.y
	self.m_Bounds = { width*aspect_width, height *aspect_height}
end

function EasterEggArcade.Sprite:draw( x, y, width, height, material, tiled) 
	if tiled then 
		dxDrawImageSection(x, y, width, height, 0, 0, width, height, material, 0, 0, 0, self.m_Color)
	else 
		if self:getMirrored() then
			if material then
				dxDrawImage( x+width, y, -1*width, height, material, 0, 0, 0, self.m_Color )
			end
		else 
			if material then
				dxDrawImage( x, y, width, height, material, 0, 0, 0, self.m_Color )
			end
		end
	end
end

function EasterEggArcade.Sprite:getBound() 
	if not self.m_Bounds then self.m_Bounds = {} end
	return self.m_Bounds[1], self.m_Bounds[2]
end
