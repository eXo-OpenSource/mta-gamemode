-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/ElementInfo.lua
-- *  PURPOSE:     ElementInfo for help-captions over elements
-- *
-- ****************************************************************************

ElementInfo = inherit(Object)
ElementInfo.m_Font = VRPFont(64)
ElementInfo.m_FontAwesome = FontAwesome(64)
function ElementInfo:constructor(object, text, offset, icon, iconOnly)
	self.m_Object = object
	self.m_Text = text
	self.m_Offset = offset or 1
	self.m_Icon = icon or "Info"
	self.m_IconOnly = iconOnly
	ElementInfoManager:getSingleton().m_Infos[object] = self
end

function ElementInfo:destructor()
	ElementInfoManager:getSingleton():removeEventFromElement(self.m_Object)
	ElementInfoManager:getSingleton().m_Infos[self.m_Object] = nil
	ElementInfoManager:getSingleton().m_ActiveInfos[self.m_Object] = nil
end

function ElementInfo:draw(distance, prog)
	local anim = getEasingValue(prog, "SineCurve") * 0.1
	local x, y, z = getElementPosition(self.m_Object)
	local lx, ly, lz = getElementPosition(localPlayer)
	local x2, y2, z2 = getCameraMatrix()
	if getDistanceBetweenPoints3D(lx, ly, lz, x, y, z) < 1 then
		return
	end
	if isLineOfSightClear(x, y, z+2, x2, y2, z2) then
		local sx, sy = getScreenFromWorldPosition(x, y, z+self.m_Offset+anim)
		if sx then
			local scale =  1- (distance / 15)
			local height = dxGetFontHeight(scale, getVRPFont(self.m_Font))
			local height2 = dxGetFontHeight(scale*0.7, getVRPFont(self.m_FontAwesome))
			local width = dxGetTextWidth(self.m_Text, scale, getVRPFont(self.m_Font))
			local alpha = 255 * scale*1.5
			if alpha > 255 then alpha = 255 end
			if not self.m_IconOnly then
				dxDrawRectangle((sx-width/2)-3, sy, width+6, height, tocolor(0, 0, 0, 200))
				dxDrawBoxShape((sx-width/2)-3, sy, width+6, height, tocolor(50, 200, 255, alpha))
				dxDrawText(self.m_Text, sx+2, sy+2, sx, sy, tocolor(0, 0, 0, alpha), scale, getVRPFont(self.m_Font), "center", "top")
				dxDrawText(self.m_Text, sx, sy, sx, sy, tocolor(50, 200, 255, alpha), scale, getVRPFont(self.m_Font), "center", "top")

				dxDrawLine((sx-width/2)+width-10, sy-height*0.2, (sx-width/2)+width+10, sy-height*0.2, tocolor(50, 200, 255, alpha))
				dxDrawLine((sx-width/2)+width+10, sy-height*0.2, (sx-width/2)+width+10, sy+height*0.1, tocolor(50, 200, 255, alpha))

				dxDrawText(FontAwesomeSymbols[self.m_Icon], ((sx-width/2)+width-10)+2, (sy-height2*1.5)+2, ((sx-width/2)+width+10)+2, (sy-height2*1.5)+2, tocolor(0, 0, 0, alpha),  scale*0.7, getVRPFont(self.m_FontAwesome), "center", "top")
				dxDrawText(FontAwesomeSymbols[self.m_Icon], (sx-width/2)+width-10, sy-height2*1.5, (sx-width/2)+width+10, sy-height2*1.5, tocolor(50, 200, 255, alpha),  scale*0.7, getVRPFont(self.m_FontAwesome), "center", "top")

				dxDrawLine((sx-width/2)-10, sy+height*1.2, (sx-width/2)-10, sy+height*0.9, tocolor(50, 200, 255, alpha))
				dxDrawLine((sx-width/2)-10, sy+height*1.2, (sx-width/2)+10, sy+height*1.2, tocolor(50, 200, 255, alpha))
			else
				dxDrawText(FontAwesomeSymbols[self.m_Icon], sx+2, sy+2, sx, sy, tocolor(0, 0, 0, alpha),  scale*2, getVRPFont(self.m_FontAwesome), "center", "top")
				dxDrawText(FontAwesomeSymbols[self.m_Icon], sx, sy, sx, sy, tocolor(50, 200, 255, alpha),  scale*2, getVRPFont(self.m_FontAwesome), "center", "top")
			end
		end
	end
end
