/turf/closed/constructed_wall
	name = "wall"
	desc = "A huge chunk of iron used to separate rooms."
	icon = 'icons/turf/walls/bimmer_walls.dmi'
	icon_state = "wall-0"
	var/wall_connections = -1
	var/datum/material/material_plating //! the material that the exterior of the wall is made of.
	var/datum/material/material_reinforcement //! (if applicable) the material that the reinforcement rods are made of.
	var/datum/material/material_trim_low //! (if applicable) the material that the bottom trim is made of.
	var/datum/material/material_trim_high //! (if applicable) the material that the top trim is made of.
	var/deconstruction_stage = DECON_NONE //! the current stage of wall deconstruction
	var/deconstruction_r_step = DECON_REINF_NONE //! the current stage of reinforcement deconstruction

/turf/closed/constructed_wall/New(loc, material_plating, material_reinforcement, material_trim_low, material_trim_high)
	. = ..()
	src.material_plating = material_plating || /datum/material/steel
	src.material_reinforcement = material_reinforcement
	src.material_trim_low = material_trim_low
	src.material_trim_high = material_trim_high
	update_connections()

/turf/closed/constructed_wall/proc/trim_overlays()
	var/static/list/trim_map_low = alist(
		/datum/material/bronze = 'icons/walls/trim_low/bronze.dmi',
		/datum/material/steel = 'icons/walls/trim_low/iron.dmi',
		/datum/material/alloy/plasteel = 'icons/walls/trim_low/reinforced.dmi',
		/datum/material/silver = 'icons/walls/trim_low/silver.dmi',
		/datum/material/titanium = 'icons/walls/trim_low/titanium.dmi',
		/datum/material/wood = 'icons/walls/trim_low/wood.dmi',
	)
	var/static/list/trim_map_high = alist(
		/datum/material/bronze = 'icons/walls/trim_high/bronze.dmi',
		/datum/material/steel = 'icons/walls/trim_high/iron.dmi',
		/datum/material/alloy/plasteel = 'icons/walls/trim_high/reinforced.dmi',
		/datum/material/silver = 'icons/walls/trim_high/silver.dmi',
		/datum/material/titanium = 'icons/walls/trim_high/titanium.dmi',
		/datum/material/wood = 'icons/walls/trim_high/wood.dmi',
	)
	var/list/overlays = list()
	if(material_trim_low)
		if(!(material_trim_low in trim_map_low))
			stack_trace("unhandled material_trim_low: [material_trim_low]")
		else overlays += icon(trim_map_low[material_trim_low], "trim-[wall_connections]")

	if(material_trim_high)
		if(!(material_trim_high in trim_map_high))
			stack_trace("unhandled material_trim_high: [material_trim_high]")
		else overlays += icon(trim_map_high[material_trim_high], "trim-[wall_connections]")
	return overlays

/turf/closed/constructed_wall/update_icon()
	var/static/list/plating_map = alist(
		/*/datum/material/marbleblack*/ /datum/material/bananium = 'icons/walls/plating/blackmarble.dmi',
		/datum/material/bronze = 'icons/walls/plating/bronze.dmi',
		/datum/material/steel = 'icons/walls/plating/iron.dmi',
		/datum/material/alloy/plasteel = 'icons/walls/plating/reinforced.dmi',
		/*/datum/material/lead*/ /datum/material/cardboard = 'icons/walls/plating/lead.dmi',
		/datum/material/silver = 'icons/walls/plating/silver.dmi',
		/datum/material/wood = 'icons/walls/plating/wood.dmi',
	)
	if(!(material_plating in plating_map))
		stack_trace("plating_overlay(): invalid material_plating: [material_plating]")
		icon = /turf/closed/constructed_wall::icon
		return
	icon = plating_map[material_plating]
	return ..()

/turf/closed/constructed_wall/update_overlays()
	. = ..()
	. += trim_overlays()
	. += deconstruction_overlay()

/turf/closed/constructed_wall/update_icon_state()
	. = ..()
	icon_state = "wall-[wall_connections]"

/turf/closed/constructed_wall/proc/deconstruction_overlay()
	if(deconstruction_stage == 0)
		return
	var/list/overlays = list(mutable_appearance('icons/walls/decon.dmi', "d[deconstruction_stage]", alpha = 125))
	if(deconstruction_r_step > 0)
		overlays += list(mutable_appearance('icons/walls/decon.dmi', "r[deconstruction_r_step]", alpha = 125))
	return overlays

/turf/closed/constructed_wall/ChangeTurf(turf/path, list/new_baseturfs, flags)
	material_plating = null
	update_connections(from_changeturf = TRUE)
	return ..()
