require("./build/lua/gen_pack/utils")
Package = {}

function Package.save(path, filelist)
	local pack = setmetatable({}, { __index = Package })
	local fh = io.open(path, "w")

	for k, v in pairs(filelist) do
		pack:addFile(fh, v)
	end

	fh:close()
end

function Package:addFile(fh, file)
	local r = io.open(file, "r")
	if not r then
		print(("Failed to open file: %s!"):format(file))
		return
	end
	local size = fsize(r)
	local data = r:read("*all")
	r:close()

	fh:write(file:gsub("vrp/", ""))
	fh:write("\00")
	fh:write(tostring(size))
	fh:write("\00")
	fh:write(data)
end

return Package
