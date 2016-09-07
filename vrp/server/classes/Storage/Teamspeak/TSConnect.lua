TSConnect = inherit(Singleton)

function TSConnect:constructor(url, user, pass, port, ip, tsport)
	self.m_URL = "https://exo-reallife.de/ingame/TSConnect/ts_connect.php"
	self.m_Auth = {
		qUser = "exoServerBot";
		qPass = "wgCEAoO8";
		qPort = 10011;
		tsIP  = "46.105.96.223";
		tsPort = 9999;
	}
end

function TSConnect:perform(request, ...)
	local args = {...}
	return Promise:new(
		function (fullfill, reject)
			callRemote(
				self.m_URL,
				function(state)
					if state then
						fullfill()
					else
						reject()
					end
				end,
				request,
				unpack(args),
				self.m_Auth["qUser"],
				self.m_Auth["qPass"],
				self.m_Auth["tsIP"],
				self.m_Auth["qPort"],
				self.m_Auth["tsPort"]
			)
		end
	)
end
