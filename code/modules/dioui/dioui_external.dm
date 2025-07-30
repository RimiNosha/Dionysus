 // This file contains all Dio procs/definitions for external classes/objects

// Used by SSdioui (/datum/controller/subsystem/processing/dio) to track UIs opened by this mob
/mob
	var/list/open_diouis

 /**
  * A "panic button" verb to close all UIs on current mob.
  * Use it when the bug with UI not opening (because the server still considers it open despite it being closed on client) pops up.
  * Feel free to remove it once the bug is confirmed to be fixed.
  *
  * @return nothing
  */
/client/verb/resetdio()
	set name = "Reset DioUI"
	set category = "OOC"

	var/ui_amt = length(mob.open_diouis)
	SSdioui.close_user_uis(mob)
	to_chat(src, "[ui_amt] UI windows reset.")

 /**
  * Called when a Dio UI window is closed
  * This is how Dio handles closed windows
  * It must be a verb so that it can be called using winset
  *
  * @return nothing
  */
/client/verb/dioclose(var/uiref as text)
	set hidden = 1	// hide this verb from the user's panel
	set name = "dioclose"

	var/datum/dioui/ui = locate(uiref)

	if (istype(ui))
		ui.close()
		if(ui.ref)
			var/href = "close=1"
			src.Topic(href, params2list(href), ui.ref)	// this will direct to the datum's Topic() proc via client.Topic()
		else if (ui.on_close_logic)
			// no atomref specified (or not found)
			// so just reset the user mob's machine var
			if(src && src.mob)
				src.mob.unset_machine()

 /**
  * The ui_interact proc is used to open and update Dio UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable
  *
  * @param user /mob The mob who is interacting with this UI
  * @param ui_key string A string key to use for this UI. Allows for multiple unique UIs on one obj/mob (defaut value "main")
  * @param ui /datum/dioui This parameter is passed by the dioui process() proc when updating an open UI
  * @param force_open boolean Force the UI to (re)open, even if it's already open
  *
  * @return nothing
  */
/datum/proc/dioui_interact(mob/user, ui_key = "main", datum/dioui/ui = null, force_open = 1, datum/dioui/master_ui = null, state = GLOB.default_state)
	return

 /**
  * Data to be sent to the UI.
  * This must be implemented for a UI to work.
  *
  * @param user /mob The mob who interacting with the UI
  * @param ui_key string A string key to use for this UI. Allows for multiple unique UIs on one obj/mob (defaut value "main")
  *
  * @return data /list Data to be sent to the UI
 **/
/datum/proc/dioui_data(mob/user, ui_key = "main")
	return list()


/**
 * Called on a UI when the UI receieves a href.
 * Think of this as Topic().
 *
 * required action string The action/button that has been invoked by the user.
 * required params list A list of parameters attached to the button.
 *
 * return bool If the user's input has been handled and the UI should update.
 */
/datum/proc/dioui_act(action, list/params, datum/dioui/ui, datum/ui_state/state)
	return
