HTTPProvider = inherit(Object)

function HTTPProvider:constructor(url, dgi)
	self.ms_URL = url
	self.ms_GUIInstance = dgi
end

--[[
	index.xml structure
	<files>
		<file
			name="Texture1"
			path="files/folder1/Texture1.png" (Path on the http server to the file)
			target_path = "textures/texture1.png" (Path on the client where the file should get saved)
		/>
	</files>
]]

function HTTPProvider:start()
	self.ms_GUIInstance:setStatus("current file", "index.xml")
    local responseData, errno = self:fetchAsync("index.xml")
	if errno ~= 0 then
		self.ms_GUIInstance:setStatus("failed", ("HTTP-Error got returned! (%d)"):format(errno))
		return false
	end

	if responseData ~= "" then
		local tempFile = fileCreate("files.tmp")
		tempFile:write(responseData)
		tempFile:close()

		local xml = xmlLoadFile("meta.xml")
		local files = {}
		for k, v in pairs(xml:getChildren()) do
			if v:getName() == "file" then
				files[#files+1] = {name = v:getAttribute(v, "name"), path = v:getAttribute(v, "path"), target_path = v:getAttribute(v, "target_path")}
			end
		end
		xml:unload()

		self.ms_GUIInstance:setStatus("file count", table.getn(files))
		for i, v in ipairs(files) do
			self.ms_GUIInstance:setStatus("current file", v.name)
			local responseData, errno = self:fetchAsync(v.path)
			if errno ~= 0 then
				self.ms_GUIInstance:setStatus("failed", ("HTTP-Error got returned! (%d)"):format(errno))
				return false
			end

			if responseData ~= "" then
				local file = fileCreate(("files/%s"):format(v.target_path))
				file:write(responseData)
				file:close()
				-- continue
			else
				self.ms_GUIInstance:setStatus(("ignored", "Empty file %s"):format(v.path))
				-- continue
			end
		end

		-- remove temp file
		fileDelete("files.tmp")

		-- success
		return true
	else
		self.ms_GUIInstance:setStatus("failed", "Got empty index file!")
	end
end

function HTTPProvider:fetch(callback, file)
    self.ms_GUIInstance:setCurrentFile(file)
    return fetchRemote( ("%s/%s"):format(self.ms_URL, file),
        function(responseData, errno)
            local args = {responseData, errno}
            callback(args)
        end
    )
end

function HTTPProvider:fetchAsync(...)
	self:fetch(Async.waitFor(), ...)
	return Async.wait()
end

addCommandHandler( "http", function()
	local instance = HTTPProvider:new("localhost", HTTPDownloadGUI:new())
	Async.create(
		function()
			if instance:start() then
				outputDebug("download succeded")
			else
				outputDebug("download failed (see gui)")
			end
		end
	)
end)
