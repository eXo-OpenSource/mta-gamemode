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
  outputChatBox("USED")
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
  self.m_EndTick = self.m_StartTick + 4000
  --self.m_Shader = dxCreateShader( "files/shader/drug-cocaineshader.fx" )
  self.m_RenderBindFunc = function() self:onRender() end
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
  local prog = elap / dur
  local radius = interpolateBetween( 0,0,0,2,0,0,prog,"SineCurve")
  local players = getElementsByType("player", root, true)
  local x,y,z
  outputChatBox("RENDER")
  for key, pl in ipairs( players ) do
    x,y,z = getElementPosition( pl )
    dxDrawImage3D(x,y,z,radius,radius,"vrp/files/other/circle.png",tocolor(255,255,255,255),0,false,false,z+4)
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
