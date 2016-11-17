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
	self.ms_GUIInstance:setStatus("current file", self.ms_URL.."index.xml")
    local responseData, errno = self:fetchAsync("index.xml")
	if errno ~= 0 then
		outputDebug(errno)
		self.ms_GUIInstance:setStatus("failed", ("HTTP-Error #%d"):format(errno))
		return false
	end

	if responseData ~= "" then
		local tempFile = fileCreate("files.tmp")
		tempFile:write(responseData)
		tempFile:close()

		local xml = xmlLoadFile("files.tmp")
		local files = {}
		for k, v in pairs(xmlNodeGetChildren(xml)) do
			if xmlNodeGetName(v) == "file" then
				files[#files+1] = {name = xmlNodeGetAttribute(v, "name"), path = xmlNodeGetAttribute(v, "path"), target_path = xmlNodeGetAttribute(v, "target_path")}
				outputTable(files[#files])
			end
		end
		xmlUnloadFile(xml)

		self.ms_GUIInstance:setStatus("file count", table.getn(files))
		for i, v in ipairs(files) do
			self.ms_GUIInstance:setStatus("current file", self.ms_URL..v.path)
			local responseData, errno = self:fetchAsync(v.path)
			if errno ~= 0 then
				self.ms_GUIInstance:setStatus("failed", ("HTTP-Error #%d"):format(errno))
				return false
			end

			if responseData ~= "" then
				local file = fileCreate(("files/%s"):format(v.target_path))
				file:write(responseData)
				file:close()
				-- continue
			else
				self.ms_GUIInstance:setStatus("ignored", ("Empty file %s"):format(v.path))
				-- continue
			end
		end

		for i, v in ipairs(files) do
			self.ms_GUIInstance:setStatus("unpacking", ("all files have been downloaded. unpacking now the packages... (%d / %d packages)"):format(i, table.getn(files)))

			local callback = Async.waitFor()
			setTimer(function ()
				callback()
			end, 1500, 1)
			Async.wait()
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
    return fetchRemote( ("%s/%s"):format(self.ms_URL, file),
        function(responseData, errno)
            callback(responseData, errno)
        end
    )
end

function HTTPProvider:fetchAsync(...)
	self:fetch(Async.waitFor(), ...)
	return Async.wait()
end

addCommandHandler("http", function()
	HUDUI:getSingleton():hide()
	HUDRadar:getSingleton():hide()
	showChat(false)
	fadeCamera(false, 0.05)

	local dgi = HTTPDownloadGUI:getSingleton()
	local instance = HTTPProvider:new("192.168.178.102:80/mtasa/", dgi)
	Async.create(
		function()
			if instance:start() then
				outputDebug("download succeded")
				delete(dgi)

				HUDUI:getSingleton():show()
				HUDRadar:getSingleton():show()
				showChat(true)
				fadeCamera(true, 0.05)
			else
				outputDebug("download failed (see gui)")
			end
		end
	)()
end)
