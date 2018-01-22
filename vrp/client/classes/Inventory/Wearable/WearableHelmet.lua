-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/Wearables/WearableHelmet.lua
-- *  PURPOSE:     Wearable Helmets Client
-- *
-- ****************************************************************************
addRemoteEvents{ "onClientToggleHelmet"}
WearableHelmet = inherit( Singleton )
local w, h = guiGetScreenSize()
function WearableHelmet:constructor() 

	addEventHandler("onClientToggleHelmet", localPlayer, bind( self.Event_toggleHelmet, self))
	addEventHandler("onClientRender", root, bind(self.Event_draw, self), true, "high+999")
	self.m_Helmets = {}
	
end


function WearableHelmet:destructor() 

end

function WearableHelmet:Event_toggleHelmet( state, item )
	if state then 
		if item == "Gasmaske" then 
			self.m_GasMask = true
			self.m_StartTick = getTickCount() 
			self.m_EndTick = self.m_StartTick + 3000
			self.m_MaskSound = playSound("files/audio/gasmask.ogg", true)
		end
	else 
		self.m_GasMask = false
		if self.m_MaskSound then 
			stopSound(self.m_MaskSound) 
		end
	end
end

function WearableHelmet:Event_draw() 
	if self.m_GasMask then 
		local vx, vy, vz = getElementVelocity(localPlayer)
		local speed = 1 + ((vx^2 + vy^2 + vz^2)^(0.5))
		local now = getTickCount() 
		local elap = now - self.m_StartTick 
		local dur = self.m_EndTick - self.m_StartTick 
		local prog = (elap / dur) * speed
		local sway_x, sway_y, rot = interpolateBetween(-w*0.005, -h*0.03, -3, w*0.005, h*0.03, 3, prog, "SineCurve")
		if prog >= 1 then 
			self.m_StartTick = getTickCount() 
			self.m_EndTick = self.m_StartTick + 3000
		end
		dxDrawImage(-w*0.05, -h*0.05+sway_y, w*1.1, h*1.1, "files/images/Other/gasmask.png", 0, 0, 0)
	end
end
