
#define DECON_REINF_NONE 0
#define DECON_REINF_BULKHEAD_REMOVED 1
#define DECON_REINF_GRILLE_REMOVED 2
#define DECON_REINF_BRACING_REMOVED 3
#define DECON_REINF_BOLTS_UNDONE 4
#define DECON_NONE 0
#define DECON_WALL_WEAKENED 1
#define DECON_PLATING_REMOVED 2
#define DECON_GIRDER_DETACHED 3

/turf/closed/constructed_wall
	name = "wall"
	desc = "A huge chunk of iron used to separate rooms."
	icon = 'icons/turf/walls/bimmer_walls.dmi'
	icon_state = "wall-0"
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
	update_appearance()

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
		else overlays += mutable_appearance(trim_map_low[material_trim_low], "trim_low")
	if(material_trim_high)
		if(!(material_trim_high in trim_map_high))
			stack_trace("unhandled material_trim_high: [material_trim_high]")
		else overlays += trim_map_high[material_trim_high]
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

/turf/closed/constructed_wall/proc/deconstruction_overlay()
	// MASSIVE TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	if(deconstruction_stage == 0)
		return
	var/list/overlays = list(mutable_appearance('icons/walls/decon.dmi', "d[deconstruction_stage]"))
	if(deconstruction_r_step > 0)
		overlays += list(mutable_appearance('icons/walls/decon.dmi', "r[deconstruction_r_step]"))
	return overlays

/obj/item/wall_trim_kit
	name = "trim kit"
	desc = "An all-in-one kit for trimming walls."
	icon_state = "skub"
	color = "green"
	var/datum/material/trim_material
	var/uses_left = 0

/obj/item/wall_trim_kit/attackby(obj/item/item, mob/living/user, params)
	if(!istype(item, /obj/item/stack/sheet))
		return ..()
	var/obj/item/stack/sheet/sheet = item
	if(trim_material && sheet.material_type != trim_material)
		balloon_alert(user, "wrong material!")
		return TRUE
	trim_material = sheet.material_type
	if(!sheet.use(1))
		balloon_alert(user, "not enough!")
		return TRUE
	uses_left += 1
	balloon_alert(user, "restocked one")
	return TRUE

/obj/item/wall_trim_kit/attackby_secondary(obj/item/weapon, mob/user, params)
	if(!istype(weapon, /obj/item/stack/sheet))
		return ..()
	var/obj/item/stack/sheet/sheet = weapon
	if(trim_material && sheet.material_type != trim_material)
		balloon_alert(user, "wrong material!")
		return TRUE
	trim_material = sheet.material_type
	var/to_take = sheet.get_amount()
	sheet.use(to_take)
	uses_left += to_take
	balloon_alert(user, "restocked all")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/turf/closed/constructed_wall/welder_act(mob/living/user, obj/item/tool)
	if(!Adjacent(tool))
		return ..()
	switch(deconstruction_stage)
		if(DECON_NONE)
			if(material_trim_high || material_trim_low)
				balloon_alert("remove the trim!")
				return TRUE
			balloon_alert_to_viewers("cutting frame...")
			if(!tool.use_tool(src, user, 1 SECONDS))
				return TRUE
			deconstruction_stage = DECON_WALL_WEAKENED
			return TRUE
		if(DECON_WALL_WEAKENED)
			if(material_reinforcement && deconstruction_r_step == DECON_REINF_GRILLE_REMOVED)
				balloon_alert_to_viewers("removing bracing...")
				if(!tool.use_tool(src, user, 1 SECONDS))
					return TRUE
				deconstruction_r_step = DECON_REINF_BRACING_REMOVED
				return TRUE
	return ..()

/turf/closed/constructed_wall/crowbar_act(mob/living/user, obj/item/tool)
	if(material_trim_high)
		balloon_alert_to_viewers("removing trim...")
		if(!tool.use_tool(src, user, 1 SECONDS))
			return TRUE
		user.put_in_hands(new material_trim_high.sheet_type(drop_location(), 1))
		material_trim_high = null
		return TRUE
	if(material_trim_low)
		balloon_alert_to_viewers("removing trim...")
		if(!tool.use_tool(src, user, 1 SECONDS))
			return TRUE
		user.put_in_hands(new material_trim_low.sheet_type(drop_location(), 1))
		material_trim_low = null
		return TRUE
	switch(deconstruction_stage)
		if(DECON_WALL_WEAKENED)
			if(material_reinforcement && deconstruction_r_step == DECON_REINF_NONE)
				balloon_alert_to_viewers("removing bulkhead...")
				if(!tool.use_tool(src, user, 1 SECONDS))
					return TRUE
				deconstruction_r_step = DECON_REINF_BULKHEAD_REMOVED
				return TRUE
			else
				balloon_alert_to_viewers("removing plating...")
				if(!tool.use_tool(src, user, 1 SECONDS))
					return TRUE
				deconstruction_stage = DECON_PLATING_REMOVED
				return TRUE
	return ..()

/turf/closed/constructed_wall/proc/check_shock(mob/living/user)
	var/obj/structure/cable/cable = locate() in src
	if(isnull(cable))
		return TRUE
	return !cable.shock(user, 75)

/turf/closed/constructed_wall/wirecutter_act(mob/living/user, obj/item/tool)
	if(!Adjacent(tool))
		return ..()
	switch(deconstruction_stage)
		if(DECON_WALL_WEAKENED)
			if(material_reinforcement && deconstruction_r_step == DECON_REINF_BULKHEAD_REMOVED)
				balloon_alert_to_viewers("removing grille...")
				if(!tool.use_tool(src, user, 1 SECONDS, extra_checks = CALLBACK(src, PROC_REF(check_shock), user)))
					return TRUE
				deconstruction_r_step = DECON_REINF_GRILLE_REMOVED
				return TRUE
	return ..()

/turf/closed/constructed_wall/wrench_act(mob/living/user, obj/item/tool)
	if(!Adjacent(tool))
		return ..()
	switch(deconstruction_stage)
		if(DECON_PLATING_REMOVED)
			balloon_alert_to_viewers("detaching girder...")
			if(!tool.use_tool(src, user, 1 SECONDS))
				return TRUE
			deconstruction_stage = DECON_GIRDER_DETACHED
			return TRUE
	return ..()

/turf/closed/constructed_wall/screwdriver_act(mob/living/user, obj/item/tool)
	if(!Adjacent(tool))
		return ..()
	switch(deconstruction_stage)
		if(DECON_GIRDER_DETACHED)
			balloon_alert_to_viewers("dismantling...")
			if(!tool.use_tool(src, user, 1 SECONDS))
				return TRUE
			ScrapeAway()
			return TRUE
	return ..()

#undef DECON_REINF_NONE
#undef DECON_REINF_BULKHEAD_REMOVED
#undef DECON_REINF_GRILLE_REMOVED
#undef DECON_REINF_BRACING_REMOVED
#undef DECON_REINF_BOLTS_UNDONE
#undef DECON_NONE
#undef DECON_WALL_WEAKENED
#undef DECON_PLATING_REMOVED
#undef DECON_GIRDER_DETACHED
