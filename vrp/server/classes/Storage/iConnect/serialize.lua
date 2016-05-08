--[[
	LUA variant of the php unserialize/serialize function
	Port of http://phpjs.org/functions/unserialize
	Thanks to Cristobal Dabed (https://gist.github.com/cristobal)
]]--
function unserialize (data)
	local function utf8Overhead (chr)
		local code = chr:byte()
		if (code < 0x0080) then
			return 0
		end

		if (code < 0x0800) then
			return 1
		end

		return 2
	end

	local function error (type, msg, filename, line)
		outputDebugString ("[Error unserialize(" .. type .. ", " ..  message ..")]", 1)
	end

	local function read_until (data, offset, stopchr)
		local buf, chr, len;

	    buf = {}; chr = data:sub(offset, offset);
		len = string.len(data);
	    while (chr ~= stopchr) do
	        if (offset > len) then
	           outputDebugString ('[Error unserialize(Error, Invalid input)]', 1)
		    end
	        table.insert(buf, chr)
			offset = offset + 1

	        chr = data:sub(offset, offset)
		end

	    return {table.getn(buf), table.concat(buf,'')};
	end

	local function read_chrs(data, offset, length)
		local i, buf;
		buf = {};
	    for i = 0, length - 1, 1 do
	        chr = data:sub(offset + i, offset + i);
	        table.insert(buf, chr);

	        length = length - utf8Overhead(chr);
		end
	    return {table.getn(buf), table.concat(buf,'')};
	end


	local function _unserialize(data, offset)
		local dtype, dataoffset, keyandchrs, keys,
			  readdata, readData, ccount, stringlength,
			  i, key, kprops, kchrs, vprops, vchrs, value,
              chrs, typeconvert;
		chrs = 0;
		typeconvert = function(x) return x end;

		if offset == nil then
			offset = 1 -- lua offsets starts at 1
		end

		dtype = string.lower(data:sub(offset, offset))
		-- print ("dtype " .. dtype .. " offset " ..offset)

		dataoffset = offset + 2
		if (dtype == 'i') or (dtype == 'd') then
			typeconvert = function(x)
				return tonumber(x)
			end

			readData = read_until(data, dataoffset, ';');
            chrs     = tonumber(readData[1]);
            readdata = readData[2];
            dataoffset = dataoffset + chrs + 1;

		elseif dtype == 'b' then
			typeconvert = function(x)
				return tonumber(x) ~= 0
			end

			readData = read_until(data, dataoffset, ';');
            chrs 	 = tonumber(readData[1]);
            readdata = readData[2];
            dataoffset = dataoffset + chrs + 1;
		elseif dtype == 'n' then
			readData = nil

		elseif dtype == 's' then
			ccount = read_until(data, dataoffset, ':');

			chrs         = tonumber(ccount[1]);
            stringlength = tonumber(ccount[2]);
            dataoffset = dataoffset + chrs + 2;

            readData = read_chrs(data, dataoffset, stringlength);
            chrs     = readData[1];
            readdata = readData[2];
            dataoffset = dataoffset + chrs + 2;

            if ((chrs ~= stringlength) and (chrs ~= string.length(readdata.length))) then
                 outputDebugString ('[Error unserialize(SyntaxError, String length mismatch)]', 1);
			end

		elseif dtype == 'a' then
			readdata = {}

			keyandchrs = read_until(data, dataoffset, ':');
            chrs = tonumber(keyandchrs[1]);
            keys = tonumber(keyandchrs[2]);

			dataoffset = dataoffset + chrs + 2

			for i = 0, keys - 1, 1 do
				kprops = _unserialize(data, dataoffset);

				kchrs  = tonumber(kprops[2]);
				key    = kprops[3];
				dataoffset = dataoffset + kchrs

				vprops = _unserialize(data, dataoffset)
                vchrs  = tonumber(vprops[2]);
                value  = vprops[3];
				dataoffset = dataoffset + vchrs;

                readdata[key] = value;
			end

			dataoffset = dataoffset + 1
		else
			outputDebugString ('[Error unserialize(SyntaxError, Unknown / Unhandled data type(s): ' .. dtype .. ')]', 1);
		end

		return {dtype, dataoffset - offset, typeconvert(readdata)};
	end

	return _unserialize((data .. ''), 1)[3];
end


function serialize (mixed_value)
	-- body
	local val, key, okey,
		  ktype, vals, count, _type;

		  ktype = ''; vals = ''; count = 0;

	-- https://gist.github.com/978154
	_round = function(num) return math.floor(num + .5) end

	_utf8Size = function (str)
		local size, i, l, code, val;
		size = 0; i = 0;
		l = string.len(str); code = '';

		for i = 1, l, 1 do
			code = str:byte(i)
	        if code < 0x0080 then
	            val = 1
	        elseif code < 0x0800 then
	            val = 2
	        else
	            val = 3
			end
			size = size + val
		end

		return size
	end


	_type = type(mixed_value)

	if _type == 'function' then
		val = ''

	elseif _type == 'boolean' then
		val = 'b:' .. (mixed_value and '1' or '0')

	elseif _type == 'number' then
		val = (_round(mixed_value) == mixed_value and 'i' or 'd') .. ':' .. tostring(mixed_value)

	elseif _type == 'string' then
		val = 's:' .. _utf8Size(mixed_value) .. ':"' .. mixed_value .. '"'

	elseif _type == 'table' then
		val = 'a'

		for k,v in pairs(mixed_value) do
			ktype = type(v)
			if ktype ~= 'function' then

				vals = vals .. serialize(k) .. serialize(v)
				count = count + 1
			end
		end
		val = val .. ':' .. count .. ':{' .. vals .. '}'
	else
		--- if the object has a property which contains a null value, the string cannot be unserialized by PHP
		val = 'N'
	end

	if _type ~= 'table' then
		val = val ..';'
	end

	return val
end
