-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/Package.lua
-- *  PURPOSE:     Data files package class
-- *
-- ****************************************************************************
Package = {}

function Package.save(path, filelist, onlyFileList)
	local pack = setmetatable({}, { __index = Package })
	local fh = fileCreate(path)

	if onlyFileList then
		fileWrite(fh, toJSON(filelist))
	else
		for k, v in pairs(filelist) do
			pack:addFile(fh, v)
		end
	end

	fileClose(fh)
end

function Package.load(path)
	local fh = fileOpen(path)
	while fileGetSize(fh) ~= fileGetPos(fh) do
		local name = Package._readEntry(fh, 64)
		local size = Package._readEntry(fh, 32)
		local data = fileRead(fh, tonumber(size))
		if fileExists(name) then
			fileDelete(name)
		end

		local ff = fileCreate(name)
		fileWrite(ff, data)
		fileClose(ff)
	end
	fileClose(fh)
end

function Package._readEntry(fh, maxlen)
	local pos = fileGetPos(fh)
	local buf = fileRead(fh, maxlen)
	local name = gettok(buf, 1, "\00")
	fileSetPos(fh, pos + #name+1)
	return name
end

function Package:addFile(fh, file)
	local r = fileOpen(file)
	if not r then
		outputDebugString("[PACKAGE] Cant open file : "..file)
		return
	end
	local size = fileGetSize(r)
	local data = fileRead(r, size)
	fileClose(r)
	fileWrite(fh, file)
	fileWrite(fh, "\00")
	fileWrite(fh, tostring(size))
	fileWrite(fh, "\00")
	fileWrite(fh, data)
end
