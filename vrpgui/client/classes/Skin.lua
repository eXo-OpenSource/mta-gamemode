Skin = inherit(Object)

function Skin:constructor(ped)
	assert(isElement(ped) and ( getElementType(ped) == "ped" or getElementType(ped) == "player" ))
	
	self.m_Ped = ped
	self.m_Shader = false
	self.m_Parts = {}
end

function Skin:enable()
	if self.m_Shader then return end
	if not isElement(self.m_Ped) then
		delete(self)
		return
	end
	
	local model = getElementModel(self.m_Ped)
	if not skindata[model] then return end

	self.m_Shader = dxCreateShader("files/shader/skin.fx", 0, 0, false, "ped")
	engineApplyShaderToWorldTexture(self.m_Shader, skindata[model].texture, self.m_Ped)
	dxSetShaderValue(self.m_Shader, "gAreaCount", #skindata[model])
	for k, data in ipairs(skindata[model]) do
		self.m_Parts[k] = 
		{
			name = data.name;
			colorSchemes = data.color;
			colorScheme = 1;
		}
		dxSetShaderValue(self.m_Shader, ("gArea%d"):format(k), data.position)
		dxSetShaderValue(self.m_Shader, ("gAreaColor%d"):format(k), self.m_Parts[k].colorSchemes[1])
	end
end

-- this has to be called when a ped changes its model
function Skin:refresh()
	self:disable()
	self:enable()
end

function Skin:setColorScheme(index, id)
	local part = self.m_Parts[index]
	part.colorScheme = id
	dxSetShaderValue(self.m_Shader, ("gAreaColor%d"):format(index), part.colorSchemes[part.colorScheme])
end

function Skin:getColorScheme(index)
	local part = self.m_Parts[index]
	return part.colorScheme
end

function Skin:getColorSchemes(index)
	local part = self.m_Parts[index]
	return part.colorSchemes
end

function Skin:getParts()
	return self.m_Parts
end

function Skin:disable()
	if self.m_Shader then
		destroyElement(self.m_Shader)
		self.m_Shader = false
	end
end

function Skin:setActive(active)
	if active then 
		self:enable() 
	else 
		self:disable()
	end
end