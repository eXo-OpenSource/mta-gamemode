function critical_error(errmsg)
	outputDebugString("[CRITICAL ERROR] "..tostring(errmsg))
	outputDebugString("[CRITICAL ERROR] DayZ Script will now halt")
	outputDebugString("[CRITICAL ERROR] If you cannot solve this issue please report at fixme: forumurl ")
	stopResource(getThisResource())
	error("Critical Error")
end
