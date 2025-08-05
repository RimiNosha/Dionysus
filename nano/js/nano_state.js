// This is the base state class, it is not to be used directly

function NanoStateClass() {
	/*if (typeof this.key != 'string' || !this.key.length)
	{
		alert('ERROR: Tried to create a state with an invalid state key: ' + this.key);
		return;
	}

    this.key = this.key.toLowerCase();

	NanoStateManager.addState(this);*/
}

NanoStateClass.prototype.key = null;
NanoStateClass.prototype.contentRendered = false;
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
		if (
			!this.contentRendered ||
			(data["config"].hasOwnProperty("autoUpdateContent") &&
				data["config"]["autoUpdateContent"])
		) {
			let elem = document.createElement("div");
			elem.innerHTML = swig.renderFile(
				NanoStateManager.getTemplate(),
				data,
			);

			morphdom(document.getElementById("uiLayout"), elem, {
				childrenOnly: true,
				onBeforeElUpdated: function (e) {
					return !$(e).attr("userEdited");
				},
			});
			this.contentRendered = true;
		}
	} catch (error) {
		reportError(error);
		// alert(
		// 	"ERROR: An error occurred while rendering the UI: " + error.message,
		// );
		return;
	}
};

NanoStateClass.prototype.onAfterUpdate = function (data) {
	// Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

	NanoStateManager.executeAfterUpdateCallbacks(data);
};

// Ew. Probably will outright remove, this is terrible UX. - Rimi
// NanoStateClass.prototype.alertText = function (text) {
// 	// Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

// 	alert(text);
// };
