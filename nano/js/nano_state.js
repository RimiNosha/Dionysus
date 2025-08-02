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
NanoStateClass.prototype.layoutRendered = false;
NanoStateClass.prototype.contentRendered = false;
NanoStateClass.prototype.mapInitialised = false;

NanoStateClass.prototype.isCurrent = function () {
	return NanoStateManager.getCurrentState() == this;
};

NanoStateClass.prototype.onAdd = function (previousState) {
	// Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

	NanoBaseCallbacks.addCallbacks();
	NanoBaseHelpers.addHelpers();
};

NanoStateClass.prototype.onRemove = function (nextState) {
	// Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

	NanoBaseCallbacks.removeCallbacks();
	NanoBaseHelpers.removeHelpers();
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
			!this.layoutRendered ||
			(data["config"].hasOwnProperty("autoUpdateLayout") &&
				data["config"]["autoUpdateLayout"])
		) {
			// render the 'mail' template to the #mainTemplate div
			$("#uiLayout").html(NanoTemplate.parse("layout", data)); // render the 'mail' template to the #mainTemplate div
			this.layoutRendered = true;
		}
		if (
			!this.contentRendered ||
			(data["config"].hasOwnProperty("autoUpdateContent") &&
				data["config"]["autoUpdateContent"])
		) {
			let elem = document.createElement("div");
			elem.innerHTML = NanoTemplate.parse("main", data);

			morphdom(document.getElementById("uiContent"), elem, {
				childrenOnly: true,
				onBeforeElUpdated: function (e) {
					return !$(e).attr("userEdited");
				},
			});

			if (NanoTemplate.templateExists("layoutHeader")) {
				$("#uiHeaderContent").html(
					NanoTemplate.parse("layoutHeader", data),
				);
			}
			this.contentRendered = true;
		}
	} catch (error) {
		reportError(error);
		alert(
			"ERROR: An error occurred while rendering the UI: " + error.message,
		);
		return;
	}

	$("[id]").each(function (_, e) {
		e.onKeydown = function (e) {
			$(e).attr("userEdited", true);
		};
	});
};

NanoStateClass.prototype.onAfterUpdate = function (data) {
	// Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

	NanoStateManager.executeAfterUpdateCallbacks(data);
};

NanoStateClass.prototype.alertText = function (text) {
	// Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

	alert(text);
};
