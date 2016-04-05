Promise = inherit(Object)
local PENDING = 0;
local FULFILLED = 1;
local REJECTED = 2;

function Promise:constructor(func)
	self.m_State = PENDING
	self.m_Value = nil
	self.m_Handlers = {}

	self.done = function (onFulfilled, onRejected)
		self.m_OnFulfilled = onFulfilled
		self.m_OnRejected = onRejected
 	end
	self.next = function (...)
		Promise.addNext(self)
		return self.next(...)
	end

	Promise.doResolve(self, func, bind(self.resolve, self), bind(self.reject, self))
end

function Promise:fulfill(result)
	self.m_State = FULFILLED
	self.m_Value = result
end

function Promise:reject(error)
	self.m_State = REJECTED
	self.m_Value = error
end

function Promise:resolve(result)
	self:fulfill(result);
end

function Promise:handle(handler)
	if self.m_State == PENDING then
		table.insert(self.m_Handlers, handler)
	else
		if (self.m_State == FULFILLED and type(handler.onFulfilled) == "function") then
			handler.onFulfilled(self.m_Value)
		end
		if (self.m_State == REJECTED and type(handler.onRejected) == "function") then
			handler.onRejected(self.m_Value)
		end
	end
end

function Promise:doResolve(func, onFulfilled, onRejected)
	local done = false;
	func(
		function (value)
			if (done) then return end
			done = true
			onFulfilled(value)

			-- 'cause of Asynchronous functions we have to call it here!
			nextframe(
				function ()
					self:handle({onFulfilled = self.m_OnFulfilled, onRejected = self.m_OnRejected})
				end
			)
		end,
		function (reason)
			if (done) then return end
			done = true
			onRejected(reason)

			-- 'cause of Asynchronous functions we have to call it here!
			nextframe(
				function ()
					self:handle({onFulfilled = self.m_OnFulfilled, onRejected = self.m_OnRejected})
				end
				)
		end
	)
end

function Promise.addNext(self)
	self.next = function (onFulfilled, onRejected)
		return Promise:new(
			function (resolve, reject)
				return self.done(
					function (result)
						if (type(onFulfilled) == "function")  then
							return resolve(onFulfilled(result));
						else
							return resolve(result);
						end
					end,
					function (error)
						if (type(onRejected) == "function") then
							return resolve(onRejected(error));
						else
							return reject(error);
						end
					end
				);
			end
		);
	end
end
