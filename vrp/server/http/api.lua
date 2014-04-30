<*
for k, v in pairs({call(getThisResource(), "api_request", user, hostname, form)}) do
	httpWrite(v)
	httpWrite("\n")
end
*>