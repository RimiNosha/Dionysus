// This generates and supplies species previews to the preferences constants json.
/datum/preference_middleware/species_previews

/datum/preference_middleware/species_previews/get_constant_data()
	var/static/list/female_male = list(FEMALE, MALE) // Microop go brrr
	var/static/list/south_only = list(SOUTH)

	var/mob/living/carbon/human/dummy/dummy = new
	var/list/previews = list(FEMALE = list(), MALE = list())
	for (var/species_type in GLOB.roundstart_races_by_type)
		var/datum/species/species = new species_type

		for (var/gender in female_male)
			for (var/index in 1 to 4)
				species.prepare_human_for_preview(dummy, gender, index)
				previews[gender] += icon2base64(get_flat_existing_human_icon(dummy, south_only))

	return previews
