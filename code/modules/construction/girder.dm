#define GIRDER_NOTHING "nothing"
#define GIRDER_STRUCTURAL "structural"

#define STRUCTURE_COST 2
#define PLATING_COST 2
#define REINFORCEMENT_COST 2

/obj/structure/girder
	name = "girder frame"
	desc = "A frame for a wall girder."
	icon = 'icons/walls/girder.dmi'
	icon_state = "girder-base"
	base_icon_state = "girder"
	density = FALSE
	can_atmos_pass = CANPASS_ALWAYS
	smoothing_groups = SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_WALLS
	/// The material that the girder walls are made of.
	var/datum/material/material_plating = null
	/// The material that the reinforcement rods are made of.
	var/datum/material/material_reinforce = null
	/// Are the reinforcement rods secured?
	var/reinforcement_secure = FALSE

/obj/structure/girder/update_overlays()
	. = ..()
	if(!isnull(material_reinforce))
		. += "reinf-temp"
	if(!isnull(material_plating))
		return
	if(anchored)
		. += "girder-anchor"

/obj/structure/girder/examine(mob/user)
	. = ..()
	if(isnull(material_plating))
		. += "The floor anchor bolts can be <b>wrenched</b> [anchored ? "loose" : "secure"]."
		. += "The structure can be cut apart using a <b>welder</b>."
		. += "Plating can be <b>welded</b> onto the structure."
		return .
	if(isnull(material_reinforce))
		. += "The plating can be cut apart using a <b>welder</b>."
		. += "Reinforcement can be <b>welded</b> onto the structure."
		return .
	. += "The reinforcement rods can be [reinforcement_secure ? "" : "un"]secured using a <b>screwdriver</b>."
	if(!reinforcement_secure)
		. += "The reinforcement rods can be cut apart using a <b>welder</b>."
		return .
	. += "The girder can be finished using a <b>screwdriver</b>."

/obj/structure/girder/proc/start_smoothing()
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_OBJ
	// todo: actually have different bitmask states, plz bimmer
	// if(material_reinforce)
	// 	base_icon_state = "girder-reinf"
	// else
	// 	base_icon_state = "girder"
	QUEUE_SMOOTH(src)
	QUEUE_SMOOTH_NEIGHBORS(src)
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/girder/proc/stop_smoothing()
	smoothing_flags = initial(smoothing_flags)
	icon_state = initial(icon_state)
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/girder/attackby(obj/item/object, mob/user, params)
	if(!Adjacent(object))
		return ..()
	if(istype(object, /obj/item/stack/sheet))
		if(isnull(material_plating))
			add_plating(user, object)
			return TRUE
		if(isnull(material_reinforce))
			add_reinforcement(user, object)
			return TRUE
	return ..()

/obj/structure/girder/proc/add_plating(mob/user, obj/item/stack/sheet/material_sheet)
	if(!anchored)
		balloon_alert(user, "not anchored!")
		return
	if(material_sheet.amount < PLATING_COST)
		balloon_alert(user, "not enough!")
		return
	var/obj/item/weldingtool/welder = locate() in user.held_items
	if(!istype(welder))
		balloon_alert(user, "need welder!")
		return
	user.balloon_alert_to_viewers("welding...")
	if(!welder.use_tool(src, user, 2 SECONDS, volume = 50))
		balloon_alert(user, "interrupted!")
		return
	if(!material_sheet.use(PLATING_COST))
		balloon_alert(user, "not enough!")
		return
	material_plating = material_sheet.material_type
	density = TRUE
	start_smoothing()

/obj/structure/girder/proc/add_reinforcement(mob/user, obj/item/stack/sheet/reinforcement_material)
	if(reinforcement_material.amount < PLATING_COST)
		balloon_alert(user, "not enough!")
		return
	var/obj/item/weldingtool/welder = locate() in user.held_items
	if(!istype(welder))
		balloon_alert(user, "need welder!")
		return
	user.balloon_alert_to_viewers("welding...")
	if(!welder.use_tool(src, user, 2 SECONDS, volume = 50))
		balloon_alert(user, "interrupted!")
		return
	if(!reinforcement_material.use(PLATING_COST))
		balloon_alert(user, "not enough!")
		return
	material_reinforce = reinforcement_material.material_type
	start_smoothing()

/obj/structure/girder/wrench_act(mob/user, obj/item/tool)
	if(!Adjacent(user))
		return ..()
	if(!isnull(material_plating))
		balloon_alert(user, "already plated!")
		return TRUE
	balloon_alert_to_viewers("[anchored ? "unsecuring" : "securing"]...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 50))
		return TRUE
	anchored = !anchored
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/structure/girder/screwdriver_act(mob/user, obj/item/tool)
	if(!Adjacent(user))
		return ..()
	if(isnull(material_reinforce))
		return ..()
	balloon_alert_to_viewers("[reinforcement_secure ? "unsecuring" : "securing"] reinforcements...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 50))
		return TRUE
	reinforcement_secure = !reinforcement_secure
	// todo: change base_icon_state and re-smooth
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/structure/girder/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	if(!Adjacent(user))
		return ..()
	if(isnull(material_plating))
		return ..()
	if(!isnull(material_reinforce) && !reinforcement_secure)
		balloon_alert(user, "secure the reinforcements first!")
		return TRUE
	var/turf/my_loc = get_turf(src)
	if(!istype(my_loc, /turf/open/floor))
		balloon_alert(user, "how?")
		return TRUE
	for(var/atom/movable/other in my_loc)
		if(other == src)
			continue
		if(other.density)
			balloon_alert(user, "no room!")
			return TRUE
	balloon_alert_to_viewers("finishing...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 50))
		return TRUE
	my_loc.ChangeTurf(/turf/closed/constructed_wall, args_turf_new = list(material_plating = material_plating, material_reinforcement = material_reinforce))
	qdel(src)
	return TRUE

/obj/structure/girder/welder_act_secondary(mob/living/user, obj/item/tool)
	if(!Adjacent(user))
		return ..()
	if(!isnull(material_reinforce))
		if(reinforcement_secure)
			balloon_alert(user, "secured!")
			return TRUE
		balloon_alert_to_viewers("cutting...")
		if(!tool.use_tool(src, user, 2 SECONDS, volume = 50))
			return TRUE
		user.put_in_hands(new material_reinforce.sheet_type(loc, REINFORCEMENT_COST))
		material_reinforce = null
		reinforcement_secure = FALSE
		// todo: change base_icon_state and re-smooth
		update_appearance(UPDATE_OVERLAYS)
		return TRUE
	if(!isnull(material_plating))
		balloon_alert_to_viewers("cutting...")
		if(!tool.use_tool(src, user, 2 SECONDS, volume = 50))
			return TRUE
		user.put_in_hands(new material_plating.sheet_type(loc, PLATING_COST))
		material_plating = null
		smoothing_flags = initial(smoothing_flags)
		icon_state = initial(icon_state)
		update_appearance(UPDATE_OVERLAYS)
		return TRUE
	balloon_alert_to_viewers("dismantling...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 50))
		return TRUE
	user.put_in_hands(new material_reinforce.sheet_type(loc, 2)) // keep in sync with code/game/objects/items/stacks/sheets/sheet_types.dm:75
	qdel(src)
	return TRUE
