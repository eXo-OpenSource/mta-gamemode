function filePut(path, stuff)
	fileDelete(path)
	local fh = fileCreate(path)
	fileWrite(fh, stuff)
	fileClose(fh)
end

s = Cutscene:new(scene)
s:play()

