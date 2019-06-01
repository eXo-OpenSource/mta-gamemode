-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/DrugsCocaine.lua
-- *  PURPOSE:     Cocaine class client
-- *
-- ****************************************************************************
DrugsCocaine = inherit( Object )

DrugsCocaine.m_MoveState = {
  ["walk"] = 0.6,
  ["jog"] = 0.8,
  ["stand"] = 0,
  ["crouch"]  = 0,
  ["powerwalk"] = 1,
  ["crawl"] = 0.4,
  ["sprint"] = 2,
}

function DrugsCocaine:constructor( )
end

function DrugsCocaine:destructor( )
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
  self.m_ScreenSource = dxCreateScreenSource(screenWidth, screenHeight)
  self.m_StartTick = getTickCount()
  self.m_EndTick = self.m_StartTick + 1000
  self.m_Shader = dxCreateShader( "files/shader/drug-cocaineshader.fx" )
  self.m_RenderBindFunc = function() self:onRender() end
  self.m_TextureCircle = dxCreateTexture( "files/images/Other/Circle.png" )
  addEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)
end

function DrugsCocaine:stopRender( )
  removeEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)
  if isElement( self.m_ScreenSource )  then
      destroyElement( self.m_ScreenSource )
  end
  if  isElement( self.m_Shader ) then
    destroyElement( self.m_Shader )
  end
end


function DrugsCocaine:onRender()
  local now = getTickCount()
  local elap = now - self.m_StartTick
  local dur = self.m_EndTick - self.m_StartTick
  local dur2 = ( self.m_EndTick +1000 ) - self.m_StartTick
  local prog = elap / dur
  local prog2 = elap / dur2

  local radius, alpha,radius3 = interpolateBetween( 0 ,255 ,0 ,4 ,0 ,10 ,prog ,"Linear")
  local radius2,radius4,magrate = interpolateBetween( 0 ,0 ,1 ,4 ,10 ,1.3 ,prog2 ,"Linear")
  local innerradius,oradius = interpolateBetween( 0.0, 0.0, 0, 0.4, 0.6, 0,prog ,"SineCurve")
  local players = getElementsByType("player", root, true)

  dxUpdateScreenSource( self.m_ScreenSource )
  dxSetShaderValue( self.m_Shader, "ScreenTexture", self.m_ScreenSource)
  dxSetShaderValue( self.m_Shader, "magnification", magrate)
  dxSetShaderValue( self.m_Shader, "inner_radius", innerradius)
  dxSetShaderValue( self.m_Shader, "outer_radius", oradius)
  dxDrawImage( 0, 0, screenWidth, screenHeight , self.m_Shader)

  local x,y,z,mstate,multiplier
  for key, pl in ipairs( players ) do
    if pl ~= localPlayer then
      mstate = getPedMoveState( pl )
      if self.m_MoveState[mstate] then
        multiplier = self.m_MoveState[mstate]
      else
        multiplier = 0
      end
      radius = radius * multiplier
      radius2 = radius2 * multiplier
      radius3 = radius3 * multiplier
      radius4 = radius4 * multiplier
      x,y,z = getPedBonePosition( pl, 53)
	    x2,y2,z2 = getPedBonePosition( pl, 43)
	    self:dx3D(x-radius/2 ,y-radius/2 , z , radius , radius , self.m_TextureCircle,tocolor(255,255,255,alpha), 0, x,y,z+4)
	    self:dx3D(x2-radius2/2 ,y2-radius2/2 ,z2 ,radius2 ,radius2 , self.m_TextureCircle ,tocolor(255,255,255,alpha) ,0,x2,y2,z2+4)
      self:dx3D(x-radius3/2 ,y-radius3/2 , z , radius3 , radius3 , self.m_TextureCircle,tocolor(255,255,255,alpha), 0, x,y,z+4)
      self:dx3D(x2-radius4/2 ,y2-radius4/2 ,z2 ,radius4 ,radius4 , self.m_TextureCircle ,tocolor(255,255,255,alpha) ,0,x2,y2,z2+4)
    end
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
  if isElement( self.m_TextureCircle ) then
    destroyElement( self.m_TextureCircle )
  end
end

function DrugsCocaine:dx3D(x,y,z,w,h,m,c,r,...)
  local lx, ly, lz = x+w, y+h, (z+tonumber(r or 0)) or z
	return dxDrawMaterialLine3D(x,y,z, lx, ly, lz, m, h, c or tocolor(255,255,255,255), ...)
end
