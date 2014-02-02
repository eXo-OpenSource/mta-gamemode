Skin = inherit(Object)

function Skin:constructor(ped)
	assert(isElement(ped) and ( getElementType(ped) == "ped" or getElementType(ped) == "player" ))
	
	self.m_Ped = ped
	self.m_Shader = false
	self.m_Color = { }
end

function Skin:enable()
	if self.m_Shader then return end
	if not isElement(self.m_Ped) then
		delete(self)
		return
	end
	
	local model = getElementModel(self.m_Ped)
	if not skindata[model] then return end
	
	for i, entry in pairs(skindata[model].textures) do
		self.m_Shader = dxCreateShader("files/shader/skin.fx", 0, 0, false, "ped")
		engineApplyShaderToWorldTexture(self.m_Shader, entry.tex, self.m_Ped)
		dxSetShaderValue(self.m_Shader, "gAreaCount", #entry)
		for k, v in pairs(entry) do
			if k ~= "tex" then 
				if not self.m_Color[k] then 
					self.m_Color[k] = { 1, 0, 0}
				end
			
				dxSetShaderValue(self.m_Shader, ("gArea%d"):format(k), v[1], v[2], v[3], v[4])
				dxSetShaderValue(self.m_Shader, ("gAreaColor%d"):format(k), self.m_Color[k][1], self.m_Color[k][2], self.m_Color[k][3])
			end
		end				
	end
end

function Skin:setColor(index, r, g, b)
	self.m_Color[index] = { r, g, b }
	dxSetShaderValue(self.m_Shader, ("gAreaColor%d"):format(index), r, g, b)
end

function Skin:getColor(index)
	if not self.m_Color[index] then
		return
	end
	return self.m_Color[index][1], self.m_Color[index][2], self.m_Color[index][3]
end

function Skin:disable()
	destroyElement(self.m_Shader)
	self.m_Shader = false
end

function Skin:setActive(active)
	if active then 
		self:enable() 
	else 
		self:disable()
	end
end