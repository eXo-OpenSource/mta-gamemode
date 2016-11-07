function switchContrast( bOn )
	if bOn then
		enableContrast()
	else
		disableContrast()
	end
end

addEvent( "switchContrast", true )
addEventHandler( "switchContrast", resourceRoot, switchContrast )