-- Tar extraction module based off LUARocks : github.com/keplerproject/luarocks
-- By Danny @ anscamobile
--
-- Restored directory creation
-- Handles space-padded numbers, e.g. in the size field, so it can handle a TAR file
-- created by the OS X UNIX tar.
-- By David Gross

-- Adapted for Gideros Mobile by Emanuel Braz - fastencoding@gmail.com
-- test mock
-- delete tar file after unpacking
-- callback function if needed
-- https://gist.github.com/sbx320/61562aa7f08b67f42d70954290e5163c

local blocksize = 512
local _ceil = math.ceil
local _tonumber = tonumber
local byte = string.byte

-- trim from http://lua-users.org/wiki/StringTrim
function trim(s)
  return s:match'^%s*(.*%S)' or ''
end

local function get_typeflag(flag)
	if flag == "0" or flag == "\0" then return "file"
	elseif flag == "1" then return "link"
	elseif flag == "2" then return "symlink" -- "reserved" in POSIX, "symlink" in GNU
	elseif flag == "3" then return "character"
	elseif flag == "4" then return "block"
	elseif flag == "5" then return "directory"
	elseif flag == "6" then return "fifo"
	elseif flag == "7" then return "contiguous" -- "reserved" in POSIX, "contiguous" in GNU
	elseif flag == "x" then return "next file"
	elseif flag == "g" then return "global extended header"
	elseif flag == "L" then return "long name"
	elseif flag == "K" then return "long link name"
	end
	return "unknown"
end

local function octal_to_number(octal)
	local exp = 0
	local number = 0
	octal = trim(octal)
	for i = #octal,1,-1 do
		local digit = _tonumber(octal:sub(i,i))
		if not digit then break end
		number = number + (digit * 8^exp)
		exp = exp + 1
	end
	return number
end

-- Checksum
local function checksum_header(block)
	local sum = 256
	for i = 1,148 do
		byte = block:byte(i)
		if not byte then
			return false
		end
		sum = sum + byte
	end
	for i = 157,500 do
		byte = block:byte(i)
		if not byte then
			return false
		end
		sum = sum + byte
	end
	return sum
end

local function nullterm(s)
	return s:match("^[^%z]*")
end

local function read_header_block(block)
	outputDebugString(#block)
	outputDebugString(nullterm(block:sub(1,100)))
	outputDebugString(block:sub(258,263))
	outputDebugString(block:sub(264,265))
	local header = {}
	header.name = nullterm(block:sub(1,100))
	header.mode = nullterm(block:sub(101,108))
	header.uid = octal_to_number(nullterm(block:sub(109,116)))
	header.gid = octal_to_number(nullterm(block:sub(117,124)))
	header.size = octal_to_number(nullterm(block:sub(125,136)))
	header.mtime = octal_to_number(nullterm(block:sub(137,148)))
	header.chksum = octal_to_number(nullterm(block:sub(149,156)))
	header.typeflag = get_typeflag(block:sub(157,157))
	header.linkname = nullterm(block:sub(158,257))
	header.magic = block:sub(258,263)
	header.version = block:sub(264,265)
	header.uname = nullterm(block:sub(266,297))
	header.gname = nullterm(block:sub(298,329))
	header.devmajor = octal_to_number(nullterm(block:sub(330,337)))
	header.devminor = octal_to_number(nullterm(block:sub(338,345)))
	header.prefix = block:sub(346,500)
	header.pad = block:sub(501,512)
	if header.magic ~= "ustar " and header.magic ~= "ustar\0" then
		return false, "Invalid header magic "..header.magic
	end
	if header.version ~= "00" and header.version ~= " \0" then
		return false, "Unknown version "..header.version
	end
	assert(checksum_header(block) == header.chksum, "Failed header checksum")
	return header
end

--[[
	Untar file - Descompacta arquivo
	param(string) path for tar file
	param(string) path for destination folder
	param(bool) To delete after unpack
--]]

function untar(filePath, destPath)
	local tar_handle = fileOpen(filePath, true)
	assert(tar_handle, "Error opening file")

	local long_name, long_link_name
	while true do
		local block

		-- Read a header
		repeat
			block = tar_handle:read(blocksize)
			chk = checksum_header(block)

			--outputDebugString(block)
			--outputDebugString(chk)
		until (not block) or not chk or chk > 256
		if not block or chk == false then break end
		local header, err = read_header_block(block)
		outputDebugString(header)

		if not header then
			tar_handle:close()
			error(err)
		end

		-- read entire file that follows header
		local file_data = tar_handle:read(_ceil(header.size / blocksize) * blocksize):sub(1,header.size)

		if header.typeflag == "long name" then
			long_name = nullterm(file_data)
		elseif header.typeflag == "long link name" then
			long_link_name = nullterm(file_data)
		else
			if long_name then
				header.name = long_name
				long_name = nil
			end
			if long_link_name then
				header.name = long_link_name
				long_link_name = nil
			end
		end

		local pathname
		if (destPath and string.sub(destPath,-1) ~= "/") then
			pathname = destPath.."/"..header.name
		else
			pathname = destPath..header.name
		end

		if header.typeflag == "file" then
			if fileExists(pathname) then
				fileDelete(pathname)
			end
			local file_handle = fileCreate(pathname, false)
			file_handle:write(file_data)
			file_handle:close()

		end
	end

	tar_handle:close()
	return true
end
