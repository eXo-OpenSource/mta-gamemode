function switchDetail( bOn )
	if bOn then
		enableDetail()
	else
		disableDetail()
	end
end
addEvent( "switchDetail", true )
addEventHandler( "switchDetail", resourceRoot, switchDetail )