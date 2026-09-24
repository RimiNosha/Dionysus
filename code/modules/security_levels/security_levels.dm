// Security level datums. These should house any custom alert functionality of a security level.

#define SEC_LEVEL_GREEN 0
#define SEC_LEVEL_BLUE SEC_LEVEL_GREEN + 1
#define SEC_LEVEL_RED SEC_LEVEL_BLUE + 1
#define SEC_LEVEL_DELTA SEC_LEVEL_RED + 1

/datum/security_level
	abstract_type = /datum/security_level
	/// This is used to decide alert titles and icons of things that change depending on security levels. This should be one word, and lowercase.
	var/name = "ERROR"
	/// How bad and fucked up is this security level? Levels of the same value will be treated as adjacent.
	var/value
	var/announce_sound = ANNOUNCER_DEFAULT
	var/body
	var/body_downto
	var/shuttle_modifier
	var/auto_end_body

/datum/security_level/proc/get_title(change)
	return "Security level [change ? (change == SECURITY_LEVEL_LOWERED ? "lowered" : "raised") : "changed"] to [name]."

/datum/security_level/proc/get_body(change)
	return change == SECURITY_LEVEL_LOWERED ? body_downto : body

/datum/security_level/proc/on_change(change)
	return // Use this proc to play extra sounds or something.

/* -- Alert Entries -- */

/datum/security_level/green
	name = "green"
	value = SEC_LEVEL_GREEN
	shuttle_modifier = 2

/datum/security_level/green/get_body(raised)
	return "All threats to the station have passed. Security may not have weapons visible, privacy laws are once again fully enforced."

/datum/security_level/blue
	name = "blue"
	value = SEC_LEVEL_BLUE
	announce_sound = ANNOUNCER_ALERT
	body = "The station has received reliable information about possible hostile activity on the station. Security staff may have weapons visible, random searches are permitted."
	body_downto = "The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed."
	shuttle_modifier = 1

/datum/security_level/red
	name = "red"
	value = SEC_LEVEL_RED
	announce_sound = ANNOUNCER_ALERT
	body = "There is an immediate serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised."
	body_downto = "The station's destruction has been averted. There is still however an immediate serious threat to the station. Security may have weapons unholstered at all times, random searches are allowed and advised."
	auto_end_body = "Red Alert state confirmed: Dispatching priority shuttle. "
	shuttle_modifier = 0.5

/datum/security_level/delta
	name = "delta"
	value = SEC_LEVEL_DELTA
	announce_sound = ANNOUNCER_ALERT
	body = "Destruction of the station is imminent. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill."
	body_downto = "Somehow, the station is in a better situation than before, however, it is still going to explode."
	shuttle_modifier = 0.5

// These really shouldn't be used outside of here.
#undef SEC_LEVEL_GREEN
#undef SEC_LEVEL_BLUE
#undef SEC_LEVEL_RED
#undef SEC_LEVEL_DELTA
