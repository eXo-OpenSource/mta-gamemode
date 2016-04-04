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
