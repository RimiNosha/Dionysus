// This is the base state class, it is not to be used directly

function NanoStateClass() {
	if (typeof this.key != "string" || !this.key.length) {
		reportError(
			new Error(
				"Tried to create a state with an invalid state key: " +
					this.key,
			),
		);
		return;
	}

	this.key = this.key.toLowerCase();

	NanoStateManager.addState(this);
}

NanoStateClass.prototype.key = null;
NanoStateClass.prototype.mapInitialised = false;

NanoStateClass.prototype.isCurrent = function () {
	return NanoStateManager.getCurrentState() == this;
};

NanoStateClass.prototype.onAdd = function (previousState) {
	// Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

	NanoBaseCallbacks.addCallbacks();
};

NanoStateClass.prototype.onRemove = function (nextState) {
	// Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

	NanoBaseCallbacks.removeCallbacks();
};

NanoStateClass.prototype.onBeforeUpdate = function (data) {
	// Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

	data = NanoStateManager.executeBeforeUpdateCallbacks(data);

	return data; // Return data to continue, return false to prevent onUpdate and onAfterUpdate
};

NanoStateClass.prototype.onUpdate = function (data) {
	// Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function
	try {
		// DIONYSUS TODO: Make this less shit. Implement a last edited timestamp and lock other inputs or something.
		// Also add a way to make them explicitly client sided.
		let elem = document.createElement("div");
		elem.innerHTML = swig.renderFile(NanoStateManager.getTemplate(), data);

		morphdom(document.getElementById("uiLayout"), elem, {
			childrenOnly: true,
			onBeforeElUpdated: function (e) {
				return !$(e).attr("userEdited");
			},
		});
	} catch (error) {
		reportError(error);
		return;
	}
};

NanoStateClass.prototype.onAfterUpdate = function (data) {
	// Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

	NanoStateManager.executeAfterUpdateCallbacks(data);
};
