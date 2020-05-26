--
-- c_switch.lua
--

----------------------------------------------------------------
----------------------------------------------------------------
-- Effect switching on and off
--
--	To switch on:
--			triggerEvent( "switchCarPaintReflect", root, true )
--
--	To switch off:
--			triggerEvent( "switchCarPaintReflect", root, false )
--
----------------------------------------------------------------
----------------------------------------------------------------

--------------------------------
-- Switch effect on or off
--------------------------------
function switchCarPaintReflect( cprOn )
	if cprOn then
		startCarPaintReflect()
	else
		stopCarPaintReflect()
	end
end

addEvent( "switchCarPaint", true )
addEventHandler( "switchCarPaint", resourceRoot, switchCarPaintReflect )
