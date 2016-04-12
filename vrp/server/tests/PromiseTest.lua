PromiseTest = inherit(UnitTest)

function PromiseTest:init()

end

function PromiseTest:test_PromiseFullfill()
	local func = function (fullfill, reject)
		fullfill(true)
	end
	local fullfill = function (arg)
		self:assertTrue(arg)
		self:resume()
	end
	local reject = function ()
		self:assertFalse(true)
		self:resume()
	end

	Promise:new(func).done(fullfill, reject)
	self:yield()
end

function PromiseTest:test_PromiseReject()
	local func = function (fullfill, reject)
		reject(true)
	end
	local fullfill = function ()
		self:assertFalse(true)
		self:resume()
	end
	local reject = function (arg)
		self:assertTrue(arg)
		self:resume()
	end

	Promise:new(func).done(fullfill, reject)
	self:yield()
end

function PromiseTest:test_Thread()
	local func = function ()
		for i = 1, 100, 1 do
			if i%25 == 0 then
				Thread.pause()
			end
		end
	end
	local fullfill = function ()
		self:assertTrue(true)
		self:resume()
	end
	local reject = function ()
		self:assertFalse(true)
		self:resume()
	end

	Thread:new(func, THREAD_PRIORITY_HIGHEST).done(fullfill, reject)
	self:yield()
end

function PromiseTest:test_AdvancedPromise()
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
			self:assertTableEquals(result, {["name"] = "StiviK", ["date_of_birth"] = "11.05.1998", ["a_number"] = 12, ["a_boolean"] = false})
			self:resume()
		end,
		function (err) -- err function if file reading fails
			outputServerLog(("INFO: [PromiseTest:test_AdvancedPromise]: %s"):format(tostring(err)))

			self:assertTrue(true)
			self:resume()
		end
	)

	self:yield()
end
