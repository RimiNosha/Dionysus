/obj/structure/girdern
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

/obj/structure/girdern/update_overlays()
	. = ..()
	if(girder_state == GIRDER_NOTHING)
		return
	. += "girder"
	if(!isnull(material_reinforce))
		. += "girder_reinforced"
	if(girder_state == GIRDER_PLATED)
		. += "girder_plate"

/obj/structure/girdern/proc/do_finish(mob/user)
	var/turf/my_turf = get_turf(src)
	if(my_turf != loc)
		balloon_alert(user, "can't reach!")
		return
	var/turf/closed/wall/new_wall = my_turf.ChangeTurf(/turf/closed/wall)
	new_wall.set_materials(material_plate, material_reinforce, TRUE)
	qdel(src)

/obj/structure/girdern/proc/use_sheet(mob/user, obj/item/stack/sheet/material_sheet)
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
/obj/structure/girdern/proc/create_structure(mob/user, obj/item/stack/sheet/structure_material)
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
/obj/structure/girdern/proc/apply_plating(mob/user, obj/item/stack/sheet/material)
	if(girder_state != GIRDER_STRUCTURAL)
		balloon_alert(user, "no") // shouldn't be able to get here anyway
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
/obj/structure/girdern/proc/create_reinforcement(mob/user, obj/item/stack/sheet/reinforcement_material)
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
	update_appearance()
	return TRUE

/obj/structure/girdern/attackby(obj/item/object, mob/user, params)
	if(!Adjacent(object))
		return ..()
	if(istype(object, /obj/item/stack/sheet))
		use_sheet(user, object)
		return TRUE
	return ..()

/obj/structure/girdern/attackby_secondary(obj/item/object, mob/user, params)
	if(!Adjacent(object))
		return ..()
	if(istype(object, /obj/item/stack/sheet))
		create_reinforcement(user, object)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/structure/girdern/welder_act_secondary(mob/living/user, obj/item/tool)
	if(!Adjacent(tool))
		return ..()
	if(girder_state != GIRDER_STRUCTURAL)
		return ..()
	balloon_alert_to_viewers("dismantling...")
	if(!tool.use_tool(src, user, 2 SECONDS))
		return TRUE
	user.put_in_hands(new /obj/item/stack/sheet/iron(drop_location(), STRUCTURE_COST))
	qdel(src)
	return TRUE

/obj/structure/girdern/crowbar_act(mob/living/user, obj/item/tool)
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

/obj/structure/girdern/screwdriver_act(mob/user, obj/item/tool)
	if(!Adjacent(tool))
		return ..()
	if(girder_state != GIRDER_PLATED)
		return ..()
	balloon_alert_to_viewers("finishing...")
	if(!tool.use_tool(src, user, 2 SECONDS))
		return TRUE
	do_finish(user)
	return TRUE

/obj/structure/girdern/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	if(!Adjacent(tool))
		return ..()
	if(girder_state != GIRDER_STRUCTURAL)
		return ..()
	if(isnull(material_reinforce))
		return ..()
	balloon_alert_to_viewers("removing reinforcement...")
	if(!tool.use_tool(src, user, 2 SECONDS))
		return TRUE
	user.put_in_hands(new material_reinforce.sheet_type(drop_location(), REINFORCEMENT_COST))
	material_reinforce = null
	return TRUE

/obj/structure/girdern/wrench_act(mob/user, obj/item/tool)
	if(!Adjacent(tool))
		return ..()
	if(girder_state != GIRDER_NOTHING)
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
