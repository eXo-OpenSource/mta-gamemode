function filePut(path, stuff)
	fileDelete(path)
	local fh = fileCreate(path)
	fileWrite(fh, stuff)
	fileClose(fh)
end
PRIVATE_DIMENSION_CLIENT = 0
showPlayerHudComponent("all", false)
showChat(false)
s = Cutscene:new(introScene)
s:play()

