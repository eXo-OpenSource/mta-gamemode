-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Item/WearableManager.lua
-- *  PURPOSE:     WearableManager class
-- *
-- ****************************************************************************

WearableManager = inherit( Singleton )

--[[
	*WearableManager handles WearableItems.*
	
	 ________________________________________
	|	inventory_slots						|	
	|---------------------------------------|
	|	+id									|
	|	+...								|
	|	+Value (metainfo: textureurl+...)	|
	|_______________________________________|
					|
					|
					|
					------> 	Value will be a url for the texture that will get 
								applied to the wearableItem.
							
								Example: 
								_____________________
								|	Helmet 			|
								|	id: 1			|
								|	...				|
								|	Value: tex.png	|
								____________________
	

]]
function WearableManager:constructor() 
	addEventHandler("onElementInteriorChange",root, bind(self.Event_onElementInteriorChange,self))
	addEventHandler("onElementDimensionChange",root, bind ( self.Event_onElementDimensionChange, self))
end

function WearableManager:destructor() 
end

function WearableManager:checkReference( sData )
	
end

function WearableManager:Event_onElementInteriorChange( int )
	if source.m_Helmet then 
		setElementInterior(source.m_Helmet, int)
	end
end

function WearableManager:Event_onElementDimensionChange( dim )
	if source.m_Helmet then 
		setElementDimension(source.m_Helmet, dim)
	end
end