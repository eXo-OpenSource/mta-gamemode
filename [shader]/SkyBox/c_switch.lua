function switchSkyBox( sbOn )
	if sbOn then
		startShaderResource()
	else
		stopShaderResource()
	end
end
addEvent( "switchSkyBox", true )
addEventHandler( "switchSkyBox", resourceRoot, switchSkyBox )

