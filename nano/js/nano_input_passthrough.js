/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// BYOND macros, in `key: command` format.
const byondMacros = {};

const KEY_TAB = 9;
const KEY_ENTER = 13;
const KEY_SHIFT = 16;
const KEY_CTRL = 17;
const KEY_ALT = 18;
const KEY_ESCAPE = 27;
const KEY_SPACE = 32;
const KEY_LEFT = 37;
const KEY_UP = 38;
const KEY_RIGHT = 39;
const KEY_DOWN = 40;
const KEY_F1 = 112;
const KEY_F5 = 116;
const KEY_F12 = 123;

// Default set of acquired keys, which will not be sent to BYOND.
const hotKeysAcquired = [
	KEY_ESCAPE,
	KEY_ENTER,
	KEY_SPACE,
	KEY_TAB,
	KEY_CTRL,
	KEY_SHIFT,
	KEY_UP,
	KEY_DOWN,
	KEY_LEFT,
	KEY_RIGHT,
	KEY_F5,
];

// State of passed-through keys.
const keyState = {};

// Custom listeners for key events
const keyListeners = [];

// Is hotkey mode on?
let hotkeyMode;

/**
 * Converts a browser keycode to BYOND keycode.
 */
const keyCodeToByond = (keyCode) => {
	if (keyCode === 16) return "Shift";
	if (keyCode === 17) return "Ctrl";
	if (keyCode === 18) return "Alt";
	if (keyCode === 33) return "Northeast";
	if (keyCode === 34) return "Southeast";
	if (keyCode === 35) return "Southwest";
	if (keyCode === 36) return "Northwest";
	if (keyCode === 37) return "West";
	if (keyCode === 38) return "North";
	if (keyCode === 39) return "East";
	if (keyCode === 40) return "South";
	if (keyCode === 45) return "Insert";
	if (keyCode === 46) return "Delete";
	if ((keyCode >= 48 && keyCode <= 57) || (keyCode >= 65 && keyCode <= 90)) {
		return String.fromCharCode(keyCode);
	}
	if (keyCode >= 96 && keyCode <= 105) {
		return "Numpad" + (keyCode - 96);
	}
	if (keyCode >= 112 && keyCode <= 123) {
		return "F" + (keyCode - 111);
	}
	if (keyCode === 188) return ",";
	if (keyCode === 189) return "-";
	if (keyCode === 190) return ".";
};

/**
 * Keyboard passthrough logic. This allows you to keep doing things
 * in game while the browser window is focused.
 */
const handlePassthrough = (key) => {
	const keyString = String(key);
	// In addition to F5, support reloading with Ctrl+R and Ctrl+F5
	if (keyString === "Ctrl+F5" || keyString === "Ctrl+R") {
		location.reload();
		return;
	}
	// Prevent passthrough on Ctrl+F
	if (keyString === "Ctrl+F") {
		return;
	}
	// Prevent passthrough on old non-hotkey mode
	if (!hotkeyMode) {
		return;
	}
	// NOTE: Alt modifier is pretty bad and sticky in IE11.
	if (
		key.event.defaultPrevented ||
		key.isModifierKey() ||
		hotKeysAcquired.includes(key.code)
	) {
		return;
	}
	const byondKeyCode = keyCodeToByond(key.code);
	if (!byondKeyCode) {
		return;
	}
	// Macro
	const macro = byondMacros[byondKeyCode];
	if (macro) {
		// logger.debug("macro", macro);
		return Byond.command(macro);
	}
	// KeyDown
	if (key.isDown() && !keyState[byondKeyCode]) {
		keyState[byondKeyCode] = true;
		const command = `KeyDown "${byondKeyCode}"`;
		// logger.debug(command);
		return Byond.command(command);
	}
	// KeyUp
	if (key.isUp() && keyState[byondKeyCode]) {
		keyState[byondKeyCode] = false;
		const command = `KeyUp "${byondKeyCode}"`;
		// logger.debug(command);
		return Byond.command(command);
	}
};

/**
 * Acquires a lock on the hotkey, which prevents it from being
 * passed through to BYOND.
 */
const acquireHotKey = (keyCode) => {
	hotKeysAcquired.push(keyCode);
};

/**
 * Makes the hotkey available to BYOND again.
 */
const releaseHotKey = (keyCode) => {
	const index = hotKeysAcquired.indexOf(keyCode);
	if (index >= 0) {
		hotKeysAcquired.splice(index, 1);
	}
};

const releaseHeldKeys = () => {
	for (let byondKeyCode of Object.keys(keyState)) {
		if (keyState[byondKeyCode]) {
			keyState[byondKeyCode] = false;
			// logger.log(`releasing key "${byondKeyCode}"`);
			Byond.command(`KeyUp "${byondKeyCode}"`);
		}
	}
};

const updateHotkeyMode = () =>
	Byond.winget("mainwindow", "macro").then((macro) => {
		hotkeyMode = macro !== "old_default";
	});

const setupHotKeys = () => {
	// Read macros
	Byond.winget("default.*").then((data) => {
		// Group each macro by ref
		const groupedByRef = {};
		for (let key of Object.keys(data)) {
			const keyPath = key.split(".");
			const ref = keyPath[1];
			const prop = keyPath[2];
			if (ref && prop) {
				// This piece of code imperatively adds each property to a
				// ByondSkinMacro object in the order we meet it, which is hard
				// to express safely in typescript.
				if (!groupedByRef[ref]) {
					groupedByRef[ref] = {};
				}
				groupedByRef[ref][prop] = data[key];
			}
		}
		// Insert macros
		const escapedQuotRegex = /\\"/g;
		const unescape = (str) =>
			str.substring(1, str.length - 1).replace(escapedQuotRegex, '"');
		for (let ref of Object.keys(groupedByRef)) {
			const macro = groupedByRef[ref];
			const byondKeyName = unescape(macro.name);
			byondMacros[byondKeyName] = unescape(macro.command);
		}
		// logger.debug("loaded macros", byondMacros);
	});
	updateHotkeyMode();
	globalEvents.on("window-focus", () => {
		updateHotkeyMode();
	});
	// Setup event handlers
	globalEvents.on("window-blur", () => {
		releaseHeldKeys();
	});
	globalEvents.on("input-focus", () => {
		releaseHeldKeys();
	});
	globalEvents.on("key", (key) => {
		for (const keyListener of keyListeners) {
			keyListener(key);
		}
		handlePassthrough(key);
	});
};

/**
 * Registers for any key events, such as key down or key up.
 * This should be preferred over directly connecting to keydown/keyup
 * as it lets tgui prevent the key from reaching BYOND.
 *
 * If using in a component, prefer KeyListener, which automatically handles
 * stopping listening when unmounting.
 *
 * @param callback The function to call whenever a key event occurs
 * @returns A callback to stop listening
 */
const listenForKeyEvents = (callback) => {
	keyListeners.push(callback);

	let removed = false;

	return () => {
		if (removed) {
			return;
		}

		removed = true;
		keyListeners.splice(keyListeners.indexOf(callback), 1);
	};
};
