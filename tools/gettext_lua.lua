--[[
File: 		 gettext_lua.lua
Description: A simple parser for Lua files to gather strings for translation
			 for the Open MTA:DayZ project. (vRoleplay)
]]

require("lfs")
local regex = require("regex")
local pattern = [[^.{0,}[^a-zA-Z0-9](\_|\_\()"((\\\"|[^\"\n\r]){0,})".{0,}$]]
local re, er = regex.new(pattern, "gm")

-- Processes a lua file and writes the strings to pothandle
function processLuaFile(path, name, pothandle)
	print("   Processing file "..path.."/"..name)

	-- Read the file
	local fh = io.open(path.."/"..name, "r")
	local line = 0
	while true do
		local input = fh:read()
		line = line + 1
		if input == nil then
			break
		else
			local match, err = re:match(input, 0)
			--print(input)
			if match or err then
				pothandle:write("#: "..path.."/"..name..":"..line.."\n")
				pothandle:write("msgid \""..match[3].."\"\n")
				pothandle:write("msgstr \"\"\n")
				pothandle:write("\n")
			end
		end
	end

	fh:close()
end

-- Processes all lua files in a directory and all subdirectories
function processDirectory(dir, pothandle)
	print("\nProcessing directory "..dir.."...")
	for file in lfs.dir(dir) do
		if file == "." or file == ".." then
		else
			if lfs.attributes(dir.."/"..file).mode == "directory" then
				processDirectory(dir.."/"..file, pothandle)
			else
				processLuaFile(dir, file, pothandle)
			end
		end
	end
end

function writePotHeader(pothandle)
	pothandle:write("# vRoleplay Translation File\n")
	pothandle:write("# http://www.v-roleplay.net\n")
	pothandle:write("\"Project-Id-Version: PACKAGE VERSION\\n\"\n",
					"\"Report-Msgid-Bugs-To: \\n\"\n",
					"\"POT-Creation-Date: "..os.date("%Y-%m-%d %H:%M+0000").."\\n\"\n", -- Note: This ignores the local timezone :(
					"\"PO-Revision-Date: "..os.date("%Y-%m-%d %H:%M+0000").."\\n\"\n", -- Note: This ignores the local timezone :(
					"\"Last-Translator: none <none@no.mail>\\n\"\n",
					"\"Language-Team: LANGUAGE <LL@li.org>\\n\"\n",
					"\"MIME-Version: 1.0\\n\"\n",
					"\"Content-Type: text/plain; charset=UTF-8\\n\"\n",
					"\"Content-Transfer-Encoding: 8bit\\n\"\n\n")
end

function genpot(name)
	local pot = io.open(name..".pot", "w")
	writePotHeader(pot)

	-- change to main directory
	lfs.chdir("../vrp")
	processDirectory(name, pot)

	-- go back to tools
	lfs.chdir("../tools")
	pot:close()
end

genpot("server")
genpot("client")
genpot("shared")
