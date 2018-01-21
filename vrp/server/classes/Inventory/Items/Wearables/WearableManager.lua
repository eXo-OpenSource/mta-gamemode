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
	addEventHandler("onPlayerQuit",root, bind ( self.Event_onPlayerQuit, self))
end

function WearableManager:destructor() 
end

function WearableManager:checkReference( sData )
	
end

function WearableManager:Event_onElementInteriorChange( int )
	local obj = false
	if source.m_Helmet then 
		setElementInterior(source.m_Helmet, int)
		obj = source.m_Helmet
	end
	if source.m_Shirt then 
		setElementInterior(source.m_Shirt, int)
		obj = source.m_Shirt
	end
	if source.m_Portables then 
		setElementInterior(source.m_Portables, int)
		obj = source.m_Portables
	end
	if obj then 
		local x,y,z = getElementPosition(source)
		setElementPosition(obj, x,y,z)
	end
end

function WearableManager:Event_onElementDimensionChange( dim )
	local obj = false
	if source.m_Helmet then 
		setElementDimension(source.m_Helmet, dim)
		obj = source.m_Helmet
	end
	if source.m_Shirt then 
		setElementDimension(source.m_Shirt, dim)
		obj = source.m_Shirt
	end
	if source.m_Portables then 
		setElementDimension(source.m_Portables, dim)
		obj = source.m_Portables
	end
	if obj then 
		local x,y,z = getElementPosition(source)
		setElementPosition(obj, x,y,z)
	end
end

function WearableManager:Event_onPlayerQuit(  )
	if source.m_Helmet then 
		destroyElement(source.m_Helmet)
	end
	if source.m_Shirt then 
		destroyElement(source.m_Shirt)
	end
		if source.m_Portables then 
		destroyElement(source.m_Portables)
	end
end

function WearableManager:removeAllWearables( player )
	if player.m_Helmet then 
		destroyElement(player.m_Helmet)
		player.m_IsWearingHelmet = false
		player.m_Helmet = false
		player:triggerEvent("onClientToggleHelmet", false, "Gasmaske")
		player:setData("isFaceConcealed", false)
	end
	if player.m_Shirt then 
		destroyElement(player.m_Shirt)
		player.m_IsWearingShirt = false
		player.m_Shirt = false
	end
	if player.m_Portables then 
		destroyElement(player.m_Portables)
		player.m_Portables = false
		player.m_IsWearingPortables = false
	end
end

function WearableManager:removeWearable( player, itemName, value )
	if itemName then
		local itemManager = ItemManager:getSingleton()
		if itemManager then 
			local classes = itemManager.m_ClassItems
			if classes then 
				local wearableClass = classes[itemName]
				if wearableClass then 
					if wearableClass == WearablePortables then 
						destroyElement(player.m_Portables)
						player.m_Portables = false
						player.m_IsWearingPortables = false
					elseif wearableClass == WearableHelmet then 
						destroyElement(player.m_Helmet)
						player.m_IsWearingHelmet = false
						player.m_Helmet = false
						player:setData("isFaceConcealed", false)
					elseif wearableClass == WearableShirt then 
						destroyElement(player.m_Shirt)
						player.m_IsWearingShirt = false
						player.m_Shirt = false
					elseif wearableClass == WearableClothes then 
						if getElementModel(player) == tonumber(value) then
							player:setSkin(252)
							player:meChat(true, "zieht seine Kleidung aus!")
							setPedAnimation(player,"on_lookers","lkaround_in",1000,true,true,true)
							setTimer(setPedAnimation,1000,1,player,false)
						end
					end
				end
			end
		end
	end
end