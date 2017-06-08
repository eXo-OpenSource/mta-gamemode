function filePut(path, stuff)
	fileDelete(path)
	local fh = fileCreate(path)
	fileWrite(fh, stuff)
	fileClose(fh)
end
PRIVATE_DIMENSION_CLIENT = 0
setPlayerHudComponentVisible("all", false)
showChat(false)
Cutscene:new(Fishing):play()

addEventHandler( "onClientResourceStop", getRootElement(),
    function ( stoppedRes )
		if stoppedRes == getThisResource() then
			fadeCamera()
			setCameraTarget(getLocalPlayer())
			showChat(true)
			setPlayerHudComponentVisible("all", true)
		end
	end
)
