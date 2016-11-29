## Klassen Crash-Kurs
### Promises
Beispiel:
```lua
-- See JS-Example: https://www.promisejs.org @ Constructing a promise + Transformation / Chaining

local readString = function ()
	return Promise:new(function (fullfill, reject)
		-- Example (here shorten): We're reading a json string from a file
		local err = false -- err is true, when file reading fails
		if err then
			reject("A error")
		else
			-- The string is the json string from a file
			fullfill("[ { \"a_number\": 12, \"date_of_birth\": \"11.05.1998\", \"name\": \"StiviK\", \"a_boolean\": false } ]")
		end
	end)
end
local readJSON = function () -- function which reads json from the file and parses it
	return readString().next(fromJSON)
end

readJSON().done( -- implement handlers for the readJSON function
	function (result) -- function if the progress is successful
		outputDebug(table.compare(result, {["name"] = "StiviK", ["date_of_birth"] = "11.05.1998", ["a_number"] = 12, ["a_boolean"] = false}))
	end,
	function (err) -- err function if file reading fails
		error(err)
	end
)
```
