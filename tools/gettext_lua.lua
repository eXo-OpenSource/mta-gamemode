--[[
File: 		 gettext_lua.lua
Description: A simple parser for Lua files to gather strings for translation
				for the Open MTA:DayZ project.
]]

require("lfs")

function removeComments(input)
	-- Remove multiline comments
	input = input:gsub("%-%-%[%[.-%]%]", "")
	-- Remove single lined comments
	input = input:gsub("%-%-.-\n", "\n")
	
	return input
end

-- Processes a lua file and writes the strings to pothandle
function processLuaFile(path, name, pothandle)
	-- Read the file
	local fh = io.open(path.."/"..name, "r")
	local input = fh:read("*all")
	fh:close()
	input = removeComments(input)
	
	-- 	this gmatch matches _("foo") and _"foo" 
	for match in string.gmatch(input, '.-_%(?"(.-)"%)?') do
		pothandle:write("#: "..path.."/"..name..":0\n")
		pothandle:write("msgid \""..match.."\"\n")
		pothandle:write("msgstr \"\"\n")
		pothandle:write("\n")
	end
end

-- Processes all lua files in a directory and all subdirectories
function processDirectory(dir, pothandle)
	print("Processing directory "..dir.."...")
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
	pothandle:write("# Open MTA:DayZ Translation File\n")
	pothandle:write("# Licensed under the GPLv3\n")
	pothandle:write("# https://github.com/OpenMTADayZ/open_dayz\n")
	pothandle:write("msgid \"\"\n")
	pothandle:write("msgstr \"\"\n")
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
	lfs.chdir("../open_dayz")
	processDirectory(name, pot)
	
	-- go back to tools
	lfs.chdir("../tools")
	pot:close()
end

genpot("server")
genpot("client")
genpot("shared")