/// Contains title names and any custom equipment or features they might have.
/datum/job_title
	var/name = "NOPE"
	var/description // TODO: Do we actually need this?
	/// Assoc list of species to outfit datums. Turned into an outfit instance during runtime.
	/// If a species doesn't have an outfit, it will fall back to using the human outfit.
	var/list/datum/outfit/outfits

/datum/job_title/New()
	. = ..()
	var/outfit
	for (var/species in outfits)
		outfit = outfits[species]
		outfits[species] = new outfit()

// Used for bank blank bank accounts.
/datum/job_title/unassigned
	name = "Unassigned"
