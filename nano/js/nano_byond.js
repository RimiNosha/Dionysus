const byond__callbacks__ = [];
const __hasOwn__ = Object.prototype.hasOwnProperty;
var __assign__ = function (target) {
	for (var i = 1; i < arguments.length; i++) {
		var source = arguments[i];
		for (var key in source) {
			if (__hasOwn__.call(source, key)) {
				target[key] = source[key];
			}
		}
	}
	return target;
};

const byond_call = function (path, params) {
	// Build the URL
	var url = (path || "") + "?";
	var i = 0;
	if (params) {
		for (var key in params) {
			if (__hasOwn__.call(params, key)) {
				if (i++ > 0) {
					url += "&";
				}
				var value = params[key];
				if (value === null || value === undefined) {
					value = "";
				}
				url +=
					encodeURIComponent(key) + "=" + encodeURIComponent(value);
			}
		}
	}

	// Perform a standard call via location.href
	if (url.length < 2048) {
		location.href = "byond://" + url;
		return;
	}
	// Send an HTTP request to DreamSeeker's HTTP server.
	// Allows sending much bigger payloads.
	var xhr = new XMLHttpRequest();
	xhr.open("GET", url);
	xhr.send();
};

byond_callAsync = function (path, params) {
	if (!window.Promise) {
		throw new Error("Async calls require API level of ES2015 or later.");
	}
	var index = byond__callbacks__.length;
	var promise = new window.Promise(function (resolve) {
		byond__callbacks__.push(resolve);
	});
	byond_call(
		path,
		__assign__({}, params, {
			callback: "byond__callbacks__[" + index + "]",
		}),
	);
	return promise;
};

byond_command = function (command) {
	return byond_call("winset", {
		command: command,
	});
};

byond_winget = function (id, propName) {
	if (id === null) {
		id = "";
	}
	var isArray = propName instanceof Array;
	var isSpecific = propName && propName !== "*" && !isArray;
	var promise = byond_callAsync("winget", {
		id: id,
		property: (isArray && propName.join(",")) || propName || "*",
	});
	if (isSpecific) {
		promise = promise.then(function (props) {
			return props[propName];
		});
	}
	return promise;
};

byond_winset = function (id, propName, propValue) {
	if (id === null) {
		id = "";
	} else if (typeof id === "object") {
		return byond_call("winset", id);
	}
	var props = {};
	if (typeof propName === "string") {
		props[propName] = propValue;
	} else {
		__assign__(props, propName);
	}
	props.id = id;
	return byond_call("winset", props);
};

byond_sendMessage = function (type, payload) {
	console.log("sending_message");
	var message =
		typeof type === "string" ? { type: type, payload: payload } : type;
	// JSON-encode the payload
	if (message.payload !== null && message.payload !== undefined) {
		message.payload = JSON.stringify(message.payload);
	}
	// Append an identifying header
	__assign__(message, {
		nanoui: 1,
		window_id: byond_windowId,
	});
	byond_topic(message);
};

byond_topic = function (params) {
	return byond_call("", params);
};
