function switchWaterRefract( wrOn )
	if wrOn then
		startWaterRefract()
	else
		stopWaterRefract()
	end
end
addEvent( "switchWaterRefract", true )
addEventHandler( "switchWaterRefract", resourceRoot, switchWaterRefract )