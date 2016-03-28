-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/DrugsCocaine.lua
-- *  PURPOSE:     Cocaine class client
-- *
-- ****************************************************************************
local w,h = guiGetScreenSize()
DrugsCocaine = inherit( Object )


function DrugsCocaine:constructor( )

end

function DrugsCocaine:onUse(  )
  if isElement( self.m_ScreenSource )  then
      destroyElement( self.m_ScreenSource )
  end
  if  isElement( self.m_Shader ) then
    destroyElement( self.m_Shader )
  end
  if self.m_RenderBindFunc then
    removeEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)
  end
  self.m_ScreenSource = dxCreateScreenSource( w, h)
  self.m_StartTick = getTickCount()
  self.m_EndTick = self.m_StartTick + 1000
  --self.m_Shader = dxCreateShader( "files/shader/drug-cocaineshader.fx" )
  self.m_RenderBindFunc = function() self:onRender() end
  self.m_TextureCircle = dxCreateTexture( "files/images/Other/Circle.png" )
  addEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)
end

function DrugsCocaine:stopRender( )
  removeEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)
end


function DrugsCocaine:onRender()
  --dxUpdateScreenSource( self.m_ScreenSource )
  --dxSetShaderValue( self.m_Shader, "ScreenTexture", self.m_ScreenSource)
  --dxDrawImage( 0, 0, w, h , self.m_Shader)

  local now = getTickCount()
  local elap = now - self.m_StartTick
  local dur = self.m_EndTick - self.m_StartTick
  local dur2 = ( self.m_EndTick +1000 ) - self.m_StartTick
  local prog = elap / dur
  local prog2 = elap / dur2
  local radius, alpha,rot = interpolateBetween( 0 ,255 ,0 ,4 ,0 ,360 ,prog ,"Linear")
  local radius2 = interpolateBetween( 0 ,255 ,0 ,4 ,0 ,360 ,prog2 ,"Linear")
  local players = getElementsByType("player", root, true)
  local x,y,z
  for key, pl in ipairs( players ) do
    x,y,z = getPedBonePosition( pl, 53) 
	x2,y2,z2 = getPedBonePosition( pl, 43)
	dxDrawImage3D(x-radius/2 ,y-radius/2 , z , radius , radius , self.m_TextureCircle,tocolor(255,255,255,alpha), 0, x,y,z+4)
	dxDrawImage3D(x2-radius2/2 ,y2-radius2/2 ,z2 ,radius2 ,radius2 , self.m_TextureCircle ,tocolor(255,255,255,alpha) ,0,x2,y2,z2+4)
  end
  if prog >= 1 then 
	self.m_StartTick = getTickCount()
	self.m_EndTick = self.m_StartTick + 1000
  end
end

function DrugsCocaine:onExpire()
  removeEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)
  if self.m_ScreenSource then
    destroyElement( self.m_ScreenSource )
  end
  if self.m_Shader then
    destroyElement( self.m_Shader )
  end
end

function DrugsCocaine:destructor( )

end


local white = tocolor(255,255,255,255)
function dxDrawImage3D(x,y,z,w,h,m,c,r,...)
        local lx, ly, lz = x+w, y+h, (z+tonumber(r or 0)) or z
	return dxDrawMaterialLine3D(x,y,z, lx, ly, lz, m, h, c or white, ...)
end
