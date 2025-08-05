// Big fugly wrapper for common byond BS

let __byond__ = function () {
	const _callbacks__ = [];
	const __assign__ = function (target) {
		for (var i = 1; i < arguments.length; i++) {
			var source = arguments[i];
			for (var key in source) {
				if (Object.prototype.hasOwnProperty.call(source, key)) {
					target[key] = source[key];
				}
			}
		}
		return target;
	};

	function call(path, params) {
		// Build the URL
		var url = (path || "") + "?";
		var i = 0;
		if (params) {
			for (var key in params) {
				if (Object.prototype.hasOwnProperty.call(params, key)) {
					if (i++ > 0) {
						url += "&";
					}
					var value = params[key];
					if (value === null || value === undefined) {
						value = "";
					}
					url +=
						encodeURIComponent(key) +
						"=" +
						encodeURIComponent(value);
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
	}

	function callAsync(path, params) {
		if (!window.Promise) {
			throw new Error(
				"Async calls require API level of ES2015 or later.",
			);
		}
		var index = _callbacks__.length;
		var promise = new window.Promise(function (resolve) {
			_callbacks__.push(resolve);
		});
		call(
			path,
			__assign__({}, params, {
				callback: "_callbacks__[" + index + "]",
			}),
		);
		return promise;
	}

	function command(command) {
		return call("winset", {
			command: command,
		});
	}

	function winget(id, propName) {
		if (id === null) {
			id = "";
		}
		var isArray = propName instanceof Array;
		var isSpecific = propName && propName !== "*" && !isArray;
		var promise = callAsync("winget", {
			id: id,
			property: (isArray && propName.join(",")) || propName || "*",
		});
		if (isSpecific) {
			promise = promise.then(function (props) {
				return props[propName];
			});
		}
		return promise;
	}

	function winset(id, propName, propValue) {
		if (id === null) {
			id = "";
		} else if (typeof id === "object") {
			return call("winset", id);
		}
		var props = {};
		if (typeof propName === "string") {
			props[propName] = propValue;
		} else {
			__assign__(props, propName);
		}
		props.id = id;
		return call("winset", props);
	}

	function sendMessage(type, payload) {
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
			window_id: __byond_window_handler_ref__,
		});
		topic(message);
	}

	function topic(params) {
		return call("", params);
	}

	const ServerStorage = {
		get(key) {
			const value = window.hubStorage.getItem(key);
			if (typeof value === "string") {
				return JSON.parse(value);
			}
		},

		set(key, value) {
			window.hubStorage.setItem(key, JSON.stringify(value));
		},

		remove(key) {
			window.hubStorage.removeItem(key);
		},

		clear() {
			window.hubStorage.clear();
		},
	};

	return {
		call: call,
		callAsync: callAsync,
		command: command,
		winget: winget,
		winset: winset,
		sendMessage: sendMessage,
		topic: topic,
		ServerStorage: ServerStorage,
	};
};

const Byond = __byond__();
