SUBSYSTEM_DEF(security_level)
	name = "Security Level"
	flags = SS_NO_FIRE
	var/list/datum/keycard_auth_action/kad_actions

	/// Currently set security level
	var/datum/security_level/current_level
	/// An assoc list of security level paths to their instance.
	var/list/datum/security_level/security_levels
	/// An assoc list of security level names to their instance.
	var/list/datum/security_level/security_levels_by_name
	/// An assoc list of secuity level values as strings to a list of security level instances.
	var/list/list/datum/security_level/security_level_value_to_security_levels
	/// The highest known security level value. Mostly for sanity checks.
	var/highest_level_value

/datum/controller/subsystem/security_level/Initialize(start_timeofday)
	security_levels = list()
	security_levels_by_name = list()
	security_level_value_to_security_levels = list()
	for (var/datum/security_level/sec_type as anything in subtypesof(/datum/security_level))
		if (initial(sec_type.abstract_type) == sec_type)
			continue
		var/datum/security_level/sec_level = new sec_type
		security_levels[sec_type] = sec_level
		security_levels_by_name[sec_level.name] = sec_level

		if (length(security_level_value_to_security_levels) < sec_level.value + 1)
			security_level_value_to_security_levels["[sec_level.value]"] = list(sec_level)
		else
			security_level_value_to_security_levels["[sec_level.value]"] += sec_level

		if (sec_level.value > highest_level_value)
			highest_level_value = sec_level.value

	current_level = security_levels[/datum/security_level/green]

	kad_actions = list()
	for(var/datum/keycard_auth_action/kaa_type as anything in subtypesof(/datum/keycard_auth_action))
		if(isabstract(kaa_type) || !initial(kaa_type.available_roundstart))
			continue
		kad_actions[kaa_type] = new kaa_type

	. = ..()

/**
 * Sets a new security level as our current level
 *
 * Arguments:
 * * new_level The new security level that will become our current level. Can be a path or instance
 */
/datum/controller/subsystem/security_level/proc/set_level(datum/security_level/level)
	if (ispath(level))
		level = security_levels[level]
	if (!level)
		return
	if (level == current_level)
		return

	var/difference = 0
	difference = (level.value <=> current_level.value) 

	priority_announce(level.get_body(difference), sub_title = level.get_title(difference), sound_type = level.announce_sound, do_not_modify = TRUE)

	if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
		SSshuttle.emergency.callTime = scale_to_modifier(SSshuttle.emergency.callTime, SSshuttle.emergency_call_time, SSsecurity_level.current_level.shuttle_modifier, level.shuttle_modifier)

	level.on_change(difference)
	current_level = level
	SEND_SIGNAL(src, COMSIG_SECURITY_LEVEL_CHANGED, level)
	SSblackbox.record_feedback("tally", "security_level_changes", 1, level.name)
