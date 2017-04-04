-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/Wearables/WearableHelmet.lua
-- *  PURPOSE:     Wearable Helmets Client
-- *
-- ****************************************************************************
addRemoteEvents{ "onClientToggleHelmet"}
WearableHelmet = inherit( Singleton )
	
function WearableHelmet:constructor() 

	addEventHandler("onClientToggleHelmet", localPlayer, bind( self.Event_toggleHelmet, self))
	self.m_Helmets = {}
	
end


function WearableHelmet:destructor() 

end

function WearableHelmet:Event_toggleHelmet( player, state )
	if state then 
		
	end
end

