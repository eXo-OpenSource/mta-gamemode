var eventHandlers = [];

var MTAUtils = function() {};

MTAUtils.prototype.registerEvent = function(eventName, handler) {
	eventHandlers[eventName] = handler;
}

MTAUtils.prototype._callEvent = function(eventName, jsonArgs) {
	var func = eventHandlers[eventName];
	if (!func)
		return false;

	func.apply(null, JSON.parse(jsonArgs)[0]);
}


mtatools = new MTAUtils();
/*mtatools.registerMTAEvent("onChat", function(a, b) {
	console.log('onChat has been called');
	console.log("a = " + a); console.log("b = " + b);
});
mtatools._callEvent("onChat", "[1, {\"firstName\":\"John\"}]" );*/
