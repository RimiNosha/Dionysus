/turf/closed/constructed_wall
	name = "wall"
	desc = "A huge chunk of iron used to separate rooms."
	icon = 'icons/walls/plating/steel.dmi'
	base_icon_state = "wall"
	smoothing_flags = SMOOTH_BITMASK|SMOOTH_OBJ
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	smoothing_groups_with = SMOOTH_GROUP_SHUTTERS_BLASTDOORS + SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_GRILLE
	uses_integrity = TRUE
	max_integrity = /datum/material/steel::wall_integrity
	var/last_damage = 0
	var/heat_resistance = /datum/material/steel::heat_resistance
	var/datum/material/material_plating //! the material that the exterior of the wall is made of.
	var/datum/material/material_reinforcement //! (if applicable) the material that the reinforcement rods are made of.
	var/datum/material/material_trim_low //! (if applicable) the material that the bottom trim is made of.
	var/datum/material/material_trim_high //! (if applicable) the material that the top trim is made of.
	var/deconstruction_stage = DECON_NONE //! the current stage of wall deconstruction
	var/deconstruction_r_step = DECON_REINF_NONE //! the current stage of reinforcement deconstruction

/turf/closed/constructed_wall/New(loc, material_plating, material_reinforcement, material_trim_low, material_trim_high)
	return ..()

/turf/closed/constructed_wall/Initialize(mapload, material_plating, material_reinforcement, material_trim_low, material_trim_high)
	src.material_plating = material_plating || /datum/material/steel
	src.material_reinforcement = material_reinforcement
	src.material_trim_low = material_trim_low
	src.material_trim_high = material_trim_high
	update_material_resistances()
	QUEUE_SMOOTH(src)
	QUEUE_SMOOTH_NEIGHBORS(src)
	return ..()

/turf/closed/constructed_wall/proc/update_material_resistances()
	var/new_heat_resistance = material_plating.heat_resistance
	var/new_max_integrity = material_plating.wall_integrity
	if(!isnull(material_reinforcement))
		new_heat_resistance += material_reinforcement.heat_resistance * 0.25
		new_max_integrity += material_reinforcement.wall_integrity * 0.5
	heat_resistance = new_heat_resistance
	var/integrity_pct = atom_integrity / max_integrity
	max_integrity = new_max_integrity
	update_integrity(max_integrity * integrity_pct)

/turf/closed/constructed_wall/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	if(exposed_temperature <= heat_resistance)
		return
	var/ratio_over = exposed_temperature / heat_resistance
	var/damage_ratio = (ratio_over - 1) ** 2
	take_damage(2 ** damage_ratio, BURN)
	if(prob(ratio_over * 25))
		playsound(src, SFX_ROCK_TAP, 25)
	if(prob(ratio_over * 10))
		visible_message(span_warning("\The [src] seems to warp slightly!"))

/turf/closed/constructed_wall/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armor_penetration)
	last_damage = damage_amount
	return ..()

/turf/closed/constructed_wall/welder_act(mob/living/user, obj/item/tool)
	if(!Adjacent(user))
		return ..()
	if(atom_integrity >= max_integrity)
		return TRUE
	var/repair_amount = max(10, max_integrity * 0.1) // always repair at least 10 damage, otherwise 10% of the wall's max health
	balloon_alert_to_viewers("repairing...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 50))
		return TRUE
	repair_damage(repair_amount)

/turf/closed/constructed_wall/atom_destruction(damage_flag)
	. = ..()
	if(last_damage < /obj/structure/girder::max_integrity)
		deconstruct_to_girder()
	else ScrapeAway()

/turf/closed/constructed_wall/can_smooth(atom/other)
	if(!istype(other, /obj/structure/girder))
		return ..()
	var/obj/structure/girder/girder = other
	return !isnull(girder.material_plating)

/turf/closed/constructed_wall/examine(mob/user)
	. = ..()
	if(atom_integrity < max_integrity)
		. += span_notice("The wall can be repaired with a <i>welder</i>.")
		switch((atom_integrity / max_integrity) * 100)
			if(00 to 01)
				. += span_warning("You're not even sure if this qualifies as a wall right now.")
			if(02 to 25)
				. += span_warning("The wall is almost destroyed.")
			if(25 to 50)
				. += span_warning("The wall has seen better days.")
			if(50 to 75)
				. += span_warning("Looks fine to me.")
			if(75 to 100)
				. += span_warning("One could argue that the damage is soul.")
	if(!isnull(material_trim_low) || !isnull(material_trim_high))
		if(!isnull(material_trim_low))
			. += span_notice("You could remove the bottom trim with a <i>crowbar</i>.")
		if(!isnull(material_trim_high))
			. += span_notice("You could remove the top trim with a <i>crowbar</i>.")
		return .
	switch(deconstruction_stage)
		if(DECON_NONE)
			. += span_notice("You could loosen the [isnull(material_reinforcement) ? "plating" : "bulkhead"] with a <i>welder</i>.")
		if(DECON_WALL_WEAKENED)
			if(!isnull(material_reinforcement))
				switch(deconstruction_r_step)
					if(DECON_REINF_NONE)
						. += span_notice("You could remove the bulkhead with a <i>crowbar</i>.")
					if(DECON_REINF_BULKHEAD_REMOVED)
						. += span_notice("You could remove the grille with a <i>wirecutters</i>.")
					if(DECON_REINF_GRILLE_REMOVED)
						. += span_notice("You could remove the bracing with a <i>welder</i>.")
					if(DECON_REINF_BRACING_REMOVED)
						. += span_notice("You could remove the bolts with a <i>wrench</i>.")
					if(DECON_REINF_BOLTS_UNDONE)
						. += span_notice("You could remove the plating with a <i>crowbar</i>.")
			else
				. += span_notice("You could remove the plating with a <i>crowbar</i>.")

/turf/closed/constructed_wall/proc/trim_overlays()
	var/static/list/trim_map_low = alist(
		// /datum/material/bronze = 'icons/walls/trim_low/bronze.dmi',
		// /datum/material/steel = 'icons/walls/trim_low/iron.dmi',
		// /datum/material/alloy/plasteel = 'icons/walls/trim_low/reinforced.dmi',
		/datum/material/silver = 'icons/walls/trim_low/silver.dmi',
		// /datum/material/titanium = 'icons/walls/trim_low/titanium.dmi',
		// /datum/material/wood = 'icons/walls/trim_low/wood.dmi',
	)
	var/static/list/trim_map_high = alist(
		// /datum/material/bronze = 'icons/walls/trim_high/bronze.dmi',
		// /datum/material/steel = 'icons/walls/trim_high/iron.dmi',
		// /datum/material/alloy/plasteel = 'icons/walls/trim_high/reinforced.dmi',
		/datum/material/silver = 'icons/walls/trim_high/silver.dmi',
		// /datum/material/titanium = 'icons/walls/trim_high/titanium.dmi',
		// /datum/material/wood = 'icons/walls/trim_high/wood.dmi',
	)
	var/list/overlays = list()
	if(material_trim_low)
		if(!(material_trim_low in trim_map_low))
			stack_trace("unhandled material_trim_low: [material_trim_low]")
		else overlays += icon(trim_map_low[material_trim_low], icon_state)
	if(material_trim_high)
		if(!(material_trim_high in trim_map_high))
			stack_trace("unhandled material_trim_high: [material_trim_high]")
		else overlays += icon(trim_map_high[material_trim_high], icon_state)
	return overlays

/turf/closed/constructed_wall/update_icon()
	var/static/list/plating_map = alist(
		// /datum/material/marbleblack = 'icons/walls/plating/blackmarble.dmi',
		// /datum/material/bronze = 'icons/walls/plating/bronze.dmi',
		/datum/material/steel = 'icons/walls/plating/steel.dmi',
		// /datum/material/alloy/plasteel = 'icons/walls/plating/reinforced.dmi',
		// /datum/material/lead = 'icons/walls/plating/lead.dmi',
		// /datum/material/silver = 'icons/walls/plating/silver.dmi',
		// /datum/material/wood = 'icons/walls/plating/wood.dmi',
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
	if(deconstruction_stage == 0)
		return
	var/list/overlays = list(mutable_appearance('icons/walls/decon.dmi', "d[deconstruction_stage]", alpha = 125))
	if(deconstruction_r_step > 0)
		overlays += list(mutable_appearance('icons/walls/decon.dmi', "r[deconstruction_r_step]", alpha = 125))
	return overlays
