/obj/structure/girder
	name = "girder"
	desc = "An interconnected network of metal rods."
	icon = 'icons/obj/girders.dmi'
	icon_state = "girder_base"
	density = TRUE
	/// The material that the girder walls are made of.
	var/datum/material/material_plate = null
	/// the material that the reinforcement rods are made of.
	var/datum/material/material_reinforce = null
	/// The current state the girder is in; used for construction of walls.
	var/girder_state = GIRDER_NOTHING
	var/reinforcement_secure = FALSE

/obj/structure/girder/update_overlays()
	. = ..()
	if(girder_state == GIRDER_NOTHING)
		return
	. += "girder"
	if(!isnull(material_reinforce))
		. += "girder_reinforced"
	if(girder_state == GIRDER_PLATED)
		. += "girder_plate"

/obj/structure/girder/examine(mob/user)
	. = ..()
	switch(girder_state)
		if(GIRDER_NOTHING)
			. += span_notice("You could <i>weld</i> some [/datum/material/steel::name] into a girder.")
		if(GIRDER_STRUCTURAL)
			. += span_notice("You could <i>wrench</i> the floor bolts [anchored ? "loose" : "secured"].")
			if(material_reinforce)
				. += span_notice("You could <i>screw</i> the reinforcement bolts [reinforcement_secure ? "loose" : "secured"].")
				if(!reinforcement_secure)
					. += span_notice("You could <i>cut</i> the reinforcements off.")
			else
				. += span_notice("You could attach some reinforcements to the girder.")
				. += span_notice("You could dismantle the girder with a <i>welder</i>.")
		if(GIRDER_PLATED)
			. += span_notice("You could <i>crowbar</i> the plating off.")
			if(anchored)
				. += span_notice("You could <i>screw</i> the plating into place.")

/obj/structure/girder/proc/do_finish(mob/user)
	var/turf/my_turf = get_turf(src)
	if(my_turf != loc)
		balloon_alert(user, "can't reach!")
		return
	var/turf/closed/constructed_wall/new_wall = my_turf.ChangeTurf(/turf/closed/constructed_wall)
	new_wall.material_plating = material_plate
	new_wall.material_reinforcement = material_reinforce
	qdel(src)

/obj/structure/girder/proc/use_sheet(mob/user, obj/item/stack/sheet/material_sheet)
	if(girder_state == GIRDER_NOTHING)
		if(material_sheet.material_type != /datum/material/steel)
			balloon_alert(user, "wrong material!")
			return
		create_structure(user, material_sheet)
		return

	apply_plating(user, material_sheet)

/**
 * Creates the structure of the girder.
 * Expects the provided material to be iron(steel).
 */
/obj/structure/girder/proc/create_structure(mob/user, obj/item/stack/sheet/structure_material)
	// are we at the correct state?
	if(girder_state != GIRDER_NOTHING)
		balloon_alert(user, "no") // shouldn't be able to get here anyway
		return FALSE

	// verify that the material is iron
	if(structure_material.material_type != /datum/material/steel)
		balloon_alert(user, "wrong material!")
		return FALSE
	// do we have enough material?
	if(structure_material.get_amount() < STRUCTURE_COST)
		balloon_alert(user, "not enough!")
		return FALSE
	// do we have a welder?
	var/obj/item/weldingtool/welder = locate() in user.held_items
	if(!istype(welder))
		balloon_alert(user, "need welder!")
		return FALSE
	user.balloon_alert_to_viewers("welding...")
	if(!welder.use_tool(src, user, 2 SECONDS))
		balloon_alert(user, "interrupted!")
		return FALSE
	if(!structure_material.use(STRUCTURE_COST))
		balloon_alert(user, "not enough!")
		return FALSE
	girder_state = GIRDER_STRUCTURAL
	update_appearance()
	return TRUE

/**
 * Attempts to apply the given material as a plating to the girder.
 */
/obj/structure/girder/proc/apply_plating(mob/user, obj/item/stack/sheet/material)
	if(girder_state != GIRDER_STRUCTURAL)
		balloon_alert(user, "no") // shouldn't be able to get here anyway
		return FALSE
	if(!anchored)
		balloon_alert(user, "anchor first!")
		return FALSE
	// do we have enough material?
	if(material.get_amount() < PLATING_COST)
		balloon_alert(user, "not enough!")
		return FALSE
	// do we have a screwdriver?
	var/obj/item/screwdriver/screwdriver = locate() in user.held_items
	if(!istype(screwdriver))
		balloon_alert(user, "need screwdriver!")
		return FALSE
	user.balloon_alert_to_viewers("plating...")
	if(!screwdriver.use_tool(src, user, 2 SECONDS))
		balloon_alert(user, "interrupted!")
		return FALSE
	if(!material.use(PLATING_COST))
		balloon_alert(user, "not enough!")
		return FALSE
	material_plate = material.material_type
	girder_state = GIRDER_PLATED
	update_appearance()
	return TRUE

/**
 * Attempts to apply the given material as reinforcement to the girder.
 */
/obj/structure/girder/proc/create_reinforcement(mob/user, obj/item/stack/sheet/reinforcement_material)
	if(girder_state != GIRDER_STRUCTURAL)
		balloon_alert(user, "can't attach!")
		return FALSE
	// are we already reinforced?
	if(!isnull(material_reinforce))
		balloon_alert(user, "already reinforced!")
		return FALSE
	// do we have enough material?
	if(reinforcement_material.get_amount() < REINFORCEMENT_COST)
		balloon_alert(user, "not enough!")
		return FALSE
	// do we have a screwdriver?
	var/obj/item/screwdriver/screwdriver = locate() in user.held_items
	if(!istype(screwdriver))
		balloon_alert(user, "need screwdriver!")
		return FALSE
	user.balloon_alert_to_viewers("reinforcing...")
	if(!screwdriver.use_tool(src, user, 2 SECONDS))
		balloon_alert(user, "interrupted!")
		return FALSE
	if(!reinforcement_material.use(REINFORCEMENT_COST))
		balloon_alert(user, "not enough!")
		return FALSE
	material_reinforce = reinforcement_material.material_type
	reinforcement_secure = FALSE
	update_appearance()
	return TRUE

/obj/structure/girder/attackby(obj/item/object, mob/user, params)
	if(!Adjacent(object))
		return ..()
	if(istype(object, /obj/item/stack/sheet) && girder_state != GIRDER_PLATED)
		use_sheet(user, object)
		return TRUE
	return ..()

/obj/structure/girder/attackby_secondary(obj/item/object, mob/user, params)
	if(!Adjacent(object))
		return ..()
	if(istype(object, /obj/item/stack/sheet))
		create_reinforcement(user, object)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/structure/girder/welder_act_secondary(mob/living/user, obj/item/tool)
	if(!Adjacent(tool))
		return ..()
	if(girder_state != GIRDER_STRUCTURAL || !isnull(material_reinforce))
		return ..()
	balloon_alert_to_viewers("dismantling...")
	if(!tool.use_tool(src, user, 2 SECONDS))
		return TRUE
	user.put_in_hands(new /obj/item/stack/sheet/iron(drop_location(), STRUCTURE_COST + 2)) // the girder base costs 2; change this if you change the girder cost
	qdel(src)
	return TRUE

/obj/structure/girder/crowbar_act(mob/living/user, obj/item/tool)
	if(!Adjacent(tool))
		return ..()
	if(girder_state != GIRDER_PLATED)
		return ..()
	balloon_alert_to_viewers("removing plating...")
	if(!tool.use_tool(src, user, 2 SECONDS))
		return TRUE
	user.put_in_hands(new material_plate.sheet_type(drop_location(), PLATING_COST))
	material_plate = null
	girder_state = GIRDER_STRUCTURAL
	update_appearance()
	return TRUE

/obj/structure/girder/screwdriver_act(mob/user, obj/item/tool)
	if(!Adjacent(tool))
		return ..()
	if(girder_state != GIRDER_PLATED)
		return ..()
	if(!anchored)
		balloon_alert(user, "anchor first!")
		return TRUE
	if(material_reinforce && !reinforcement_secure)
		balloon_alert(user, "secure first!")
		return TRUE
	balloon_alert_to_viewers("finishing...")
	if(!tool.use_tool(src, user, 2 SECONDS))
		return TRUE
	do_finish(user)
	return TRUE

/obj/structure/girder/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	if(!Adjacent(tool))
		return ..()
	if(girder_state != GIRDER_STRUCTURAL)
		return ..()
	if(isnull(material_reinforce))
		return ..()
	if(reinforcement_secure)
		balloon_alert_to_viewers("unsecuring reinforcements...")
		if(!tool.use_tool(src, user, 2 SECONDS))
			return TRUE
		reinforcement_secure = FALSE
		return TRUE
	balloon_alert_to_viewers("securing reinforcements...")
	if(!tool.use_tool(src, user, 2 SECONDS))
		return TRUE
	reinforcement_secure = TRUE
	return TRUE

/obj/structure/girder/wirecutter_act(mob/living/user, obj/item/tool)
	if(!Adjacent(tool))
		return ..()
	if(girder_state != GIRDER_STRUCTURAL)
		return ..()
	if(isnull(material_reinforce))
		return ..()
	if(reinforcement_secure)
		balloon_alert("unsecure first!")
		return TRUE
	balloon_alert_to_viewers("removing reinforcements...")
	if(!tool.use_tool(src, user, 2 SECONDS))
		return TRUE
	user.put_in_hands(new material_reinforce.sheet_type(drop_location(), REINFORCEMENT_COST))
	material_reinforce = null
	update_appearance()
	return TRUE

/obj/structure/girder/wrench_act(mob/user, obj/item/tool)
	if(!Adjacent(tool))
		return ..()
	if(girder_state != GIRDER_STRUCTURAL)
		balloon_alert(user, "can't reach!")
		return TRUE
	var/turf/my_loc = get_turf(src)
	if(!isopenturf(my_loc) || isopenspaceturf(my_loc))
		balloon_alert(user, "what floor?")
		return TRUE
	balloon_alert(user, "adjusting floor bolts!")
	if(!tool.use_tool(src, user, 2 SECONDS))
		return TRUE
	anchored = !anchored
	return TRUE
