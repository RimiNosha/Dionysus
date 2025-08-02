/datum/nano_module
	var/name
	var/datum/host
	var/available_to_ai = TRUE
	var/list/using_access = list()

/datum/nano_module/New(datum/host)
	..()
	src.host = host

/datum/nano_module/Destroy()
	host = null
	. = ..()

/datum/nano_module/proc/can_still_topic(mob/user, var/datum/ui_state/state = GLOB.default_state)
	return state.can_use_topic(host, user) == UI_INTERACTIVE

/datum/nano_module/proc/check_eye(var/mob/user)
	return -1

/datum/proc/initial_data()
	return list()

/datum/proc/update_layout()
	return FALSE
