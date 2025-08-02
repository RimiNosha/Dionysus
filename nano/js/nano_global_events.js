/**
 * Normalized browser focus events and BYOND-specific focus helpers.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

class EventEmitter {
	constructor() {
		this.listeners = {};
	}

	on(name, listener) {
		this.listeners[name] = this.listeners[name] || [];
		this.listeners[name].push(listener);
	}

	off(name, listener) {
		const listeners = this.listeners[name];
		if (!listeners) {
			throw new Error(`There is no listeners for "${name}"`);
		}
		this.listeners[name] = listeners.filter((existingListener) => {
			return existingListener !== listener;
		});
	}

	emit(name, ...params) {
		const listeners = this.listeners[name];
		if (!listeners) {
			return;
		}
		for (let i = 0, len = listeners.length; i < len; i += 1) {
			const listener = listeners[i];
			listener(...params);
		}
	}

	clear() {
		this.listeners = {};
	}
}

const globalEvents = new EventEmitter();
let ignoreWindowFocus = false;

const setupGlobalEvents = (options = {}) => {
	ignoreWindowFocus = !!options.ignoreWindowFocus;
};

// Window focus
// --------------------------------------------------------

let windowFocusTimeout;
let windowFocused = true;

// Pretend to always be in focus.
const setWindowFocus = (value, delayed) => {
	if (ignoreWindowFocus) {
		windowFocused = true;
		return;
	}
	if (windowFocusTimeout) {
		clearTimeout(windowFocusTimeout);
		windowFocusTimeout = null;
	}
	if (delayed) {
		windowFocusTimeout = setTimeout(() => setWindowFocus(value));
		return;
	}
	if (windowFocused !== value) {
		windowFocused = value;
		globalEvents.emit(value ? "window-focus" : "window-blur");
		globalEvents.emit("window-focus-change", value);
	}
};

// Focus stealing
// --------------------------------------------------------

let focusStolenBy = null;

const canStealFocus = (node) => {
	const tag = String(node.tagName).toLowerCase();
	return tag === "input" || tag === "textarea";
};

const stealFocus = (node) => {
	releaseStolenFocus();
	focusStolenBy = node;
	focusStolenBy.addEventListener("blur", releaseStolenFocus);
	globalEvents.emit("input-focus");
};

const releaseStolenFocus = () => {
	if (focusStolenBy) {
		focusStolenBy.removeEventListener("blur", releaseStolenFocus);
		focusStolenBy = null;
		globalEvents.emit("input-blur");
	}
};

// Focus follows the mouse
// --------------------------------------------------------

let focusedNode = null;
let lastVisitedNode = null;
const trackedNodes = [];

const addScrollableNode = (node) => {
	trackedNodes.push(node);
};

const removeScrollableNode = (node) => {
	const index = trackedNodes.indexOf(node);
	if (index >= 0) {
		trackedNodes.splice(index, 1);
	}
};

const focusNearestTrackedParent = (node) => {
	if (focusStolenBy || !windowFocused) {
		return;
	}
	const body = document.body;
	while (node && node !== body) {
		if (trackedNodes.includes(node)) {
			// NOTE: Contains is a DOM4 method
			if (node.contains(focusedNode)) {
				return;
			}
			focusedNode = node;
			node.focus();
			return;
		}
		node = node.parentElement;
	}
};

window.addEventListener("mousemove", (e) => {
	const node = e.target;
	if (node !== lastVisitedNode) {
		lastVisitedNode = node;
		focusNearestTrackedParent(node);
	}
});

// Focus event hooks
// --------------------------------------------------------

// Handle stealing focus for textbox elements
document.addEventListener(
	"focus",
	(e) => {
		// Window
		if (!(e.target instanceof Element)) {
			lastVisitedNode = null;
			focusedNode = null;
			return;
		}
		lastVisitedNode = null;
		focusedNode = e.target;
		if (canStealFocus(e.target)) {
			stealFocus(e.target);
		}
	},
	true,
);

// When we click on any element on the page, untrack the last
// visited node.
document.addEventListener(
	"blur",
	(e) => {
		lastVisitedNode = null;
	},
	true,
);

// Handle setting the window focus
window.addEventListener("focus", () => {
	setWindowFocus(true);
});

// If we blur any element, the window may have unfocused if we didn't
// click on the background
window.addEventListener("blur", (e) => {
	setWindowFocus(false, true);
});

window.addEventListener("close", (e) => {
	setWindowFocus(false);
});

// Key events
// --------------------------------------------------------

const keyHeldByCode = {};

class KeyEvent {
	constructor(e, type, repeat) {
		this.event = e;
		this.type = type;
		this.code = e.keyCode;
		this.ctrl = e.ctrlKey;
		this.shift = e.shiftKey;
		this.alt = e.altKey;
		this.repeat = !!repeat;
	}

	hasModifierKeys() {
		return this.ctrl || this.alt || this.shift;
	}

	isModifierKey() {
		return (
			this.code === KEY_CTRL ||
			this.code === KEY_SHIFT ||
			this.code === KEY_ALT
		);
	}

	isDown() {
		return this.type === "keydown";
	}

	isUp() {
		return this.type === "keyup";
	}

	toString() {
		if (this._str) {
			return this._str;
		}
		this._str = "";
		if (this.ctrl) {
			this._str += "Ctrl+";
		}
		if (this.alt) {
			this._str += "Alt+";
		}
		if (this.shift) {
			this._str += "Shift+";
		}
		if (this.code >= 48 && this.code <= 90) {
			this._str += String.fromCharCode(this.code);
		} else if (this.code >= KEY_F1 && this.code <= KEY_F12) {
			this._str += "F" + (this.code - 111);
		} else {
			this._str += "[" + this.code + "]";
		}
		return this._str;
	}
}

// IE8: Keydown event is only available on document.
document.addEventListener("keydown", (e) => {
	if (canStealFocus(e.target)) {
		$(e.target).attr("userEdited", true);
		return;
	}
	const code = e.keyCode;
	const key = new KeyEvent(e, "keydown", keyHeldByCode[code]);
	globalEvents.emit("keydown", key);
	globalEvents.emit("key", key);
	keyHeldByCode[code] = true;
});

document.addEventListener("keyup", (e) => {
	if (canStealFocus(e.target)) {
		return;
	}
	const code = e.keyCode;
	const key = new KeyEvent(e, "keyup");
	globalEvents.emit("keyup", key);
	globalEvents.emit("key", key);
	keyHeldByCode[code] = false;
});
