 // This file contains all Nano procs/definitions for external classes/objects

// Used by SSnanoui (/datum/controller/subsystem/processing/nanoui) to track UIs opened by this mob
/mob
	var/list/open_nanouis

 /**
  * A "panic button" verb to close all UIs on current mob.
  * Use it when the bug with UI not opening (because the server still considers it open despite it being closed on client) pops up.
  * Feel free to remove it once the bug is confirmed to be fixed.
  *
  * @return nothing
  */
/client/verb/resetnano()
	set name = "Reset NanoUI"
	set category = "OOC"

	var/ui_amt = length(mob.open_nanouis)
	SSnanoui.close_user_uis(mob)
	to_chat(src, "[ui_amt] UI windows reset.")

 /**
  * Called when a Nano UI window is closed
  * This is how Nano handles closed windows
  * It must be a verb so that it can be called using winset
  *
  * @return nothing
  */
/client/verb/nanoclose(var/uiref as text)
	set hidden = 1	// hide this verb from the user's panel
	set name = "nanoclose"

	var/datum/nanoui/ui = locate(uiref)

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
  * The ui_interact proc is used to open and update Nano UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable
  *
  * @param user /mob The mob who is interacting with this UI
  * @param ui_key string A string key to use for this UI. Allows for multiple unique UIs on one obj/mob (defaut value "main")
  * @param ui /datum/nanoui This parameter is passed by the nanoui process() proc when updating an open UI
  * @param force_open boolean Force the UI to (re)open, even if it's already open
  *
  * @return nothing
  */
/datum/proc/nanoui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/nanoui/master_ui = null)
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
/datum/proc/nanoui_data(mob/user, ui_key = "main")
	return list()

/datum/proc/nanoui_act(action, list/params, list/href_list, datum/nanoui/ui)
	return FALSE


/**
 * Middleware for /client/Topic.
 *
 * return bool If TRUE, prevents propagation of the topic call.
 */
/proc/nanoui_Topic(href_list)
	var/mob/user = usr
	// Skip non-nanoui topics
	if(!href_list["nanoui"] || !istype(user))
		return FALSE
	var/type = href_list["type"]
	// // Unconditionally collect tgui logs
	// if(type == "log")
	// 	var/context = href_list["window_id"]
	// 	if (href_list["ns"])
	// 		context += " ([href_list["ns"]])"
	// 	log_tgui(usr, href_list["message"],
	// 		context = context)
	// // Reload all tgui windows
	// if(type == "cacheReloaded")
	// 	if(!check_rights(R_ADMIN) || usr.client.tgui_cache_reloaded)
	// 		return TRUE
	// 	// Mark as reloaded
	// 	usr.client.tgui_cache_reloaded = TRUE
	// 	// Notify windows
	// 	var/list/windows = usr.client.tgui_windows
	// 	for(var/window_id in windows)
	// 		var/datum/tgui_window/window = windows[window_id]
	// 		if (window.status == TGUI_WINDOW_READY)
	// 			window.on_message(type, null, href_list)
	// 	return TRUE
	// Locate window
	var/window_id = href_list["window_id"]
	var/datum/nanoui/window
	if(window_id)
		window = locate(window_id)
		if(!window)
			// log_tgui(usr,
			// 	"Error: Couldn't find the window datum, force closing.",
			// 	context = window_id)
			usr.client.uiclose(window_id)
			return TRUE
	// Decode payload
	var/payload
	if(href_list["payload"])
		payload = json_decode(href_list["payload"])
	// Pass message to window
	if(window)
		window.on_message(type, payload, href_list)
	return TRUE
