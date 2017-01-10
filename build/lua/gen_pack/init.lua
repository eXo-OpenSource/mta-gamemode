local Package = require("Package")
local scripts = {}
local currIndex = 1

for i, v in ipairs(arg) do
	if not scripts[currIndex] then
		scripts[currIndex] = {}
	end
	table.insert(scripts[currIndex], v)

	if i%10 == 0 then
		currIndex = currIndex + 1
	end
end

for i, files in ipairs(scripts) do
	Package.save(("%d.data"):format(i), files)
end
