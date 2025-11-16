#define GIRDER_NOTHING "nothing"
#define GIRDER_STRUCTURAL "structural"
#define GIRDER_PLATED "plated"

#define GIRDER_WALL_FULL "full"
#define GIRDER_WALL_HALF "half"

/obj/structure/girder
    name = "girder"
    desc = "An interconnected network of metal rods."
    icon = 'icons/obj/structures.dmi'
    icon_state = "girder"
    density = TRUE
    /// The material that the girder walls are made of.
    var/datum/material/material_plate = null
    /// the material that the reinforcement rods are made of.
    var/datum/material/material_reinforce = null
    /// The current state the girder is in; used for construction of walls.
    var/girder_state = GIRDER_NOTHING
    /// The current shape of the girder. Currently only used for walls.
    var/girder_shape = GIRDER_WALL_FULL

/obj/structure/girder/proc/attempt_finish(mob/user)
    var/turf/turf_loc = get_turf(src)
    if(loc != turf_loc)
        balloon_alert(user, "can't build here!")
        return TRUE
    if(!isopenturf(turf_loc))
        balloon_alert(user, "can't build here!")
        return TRUE
    balloon_alert_to_viewers("finishing wall...")
    if(!do_after(user, src, 2 SECONDS, DO_PUBLIC|DO_RESTRICT_CLICKING, TRUE))
        balloon_alert(user, "interrupted!")
        return TRUE
    switch(girder_shape)
        if(GIRDER_WALL_FULL)
            var/turf/closed/wall/new_wall = turf_loc.ChangeTurf(/turf/closed/wall)
            new_wall.set_materials(material_plate, material_reinforce, TRUE)
            qdel(src)
            return TRUE
        if(GIRDER_WALL_HALF)
            var/obj/structure/low_wall/new_wall = new /obj/structure/low_wall(turf_loc)
            qdel(src)
            return TRUE

/obj/structure/girder/proc/attempt_reinforce(mob/user, obj/item/stack/sheet/material)
    switch(girder_state)
        if(GIRDER_NOTHING)
            balloon_alert(user, "nothing to reinforce!")
            return TRUE
        if(GIRDER_PLATED)
            balloon_alert(user, "can't reach!")
            return TRUE
        if(GIRDER_STRUCTURAL)
            var/amount_needed = 10
            if(girder_shape == GIRDER_WALL_HALF)
                amount_needed = 5
            if(!isnull(material_reinforce))
                balloon_alert(user, "already reinforced!")
                return TRUE
            if(material.get_amount() < amount_needed)
                balloon_alert(user, "not enough!")
                return TRUE
            balloon_alert_to_viewers("reinforcing...")
            if(!do_after(user, src, 2 SECONDS, DO_PUBLIC|DO_RESTRICT_CLICKING, TRUE))
                balloon_alert(user, "interrupted!")
                return TRUE
            if(!material.use(amount_needed))
                balloon_alert(user, "not enough!")
                return TRUE
            material_reinforce = material
            return TRUE
        else
            var/err_message = "BUG: reinforcement attempted on a girder in an invalid state ([girder_state])!"
            to_chat(user, span_warning(err_message))
            stack_trace(err_message)
            return TRUE

/obj/structure/girder/proc/attempt_plate(mob/user, obj/item/stack/sheet/material)
    switch(girder_state)
        if(GIRDER_NOTHING)
            if(material.material_type != /datum/material/iron)
                balloon_alert(user, "nothing to plate!")
                return TRUE

            if(material.get_amount() < 10)
                balloon_alert(user, "not enough!")
                return TRUE

            var/obj/item/weldingtool/welder = locate() in user.held_items
            if(isnull(welder) || !welder.isOn())
                balloon_alert(user, "can't weld!")

            balloon_alert_to_viewers("welding structure...")
            if(!welder.use_tool(src, user, 2 SECONDS))
                return

            if(!material.use(10))
                balloon_alert(user, "not enough!")
                return TRUE

            girder_state = GIRDER_STRUCTURAL
            return TRUE

        if(GIRDER_PLATED)
            balloon_alert(user, "already plated!")
            return TRUE

        if(GIRDER_STRUCTURAL)
            if(!isnull(material_plate))
                balloon_alert(user, "already plated!")
                return TRUE
            if(material.get_amount() < 10)
                balloon_alert(user, "not enough!")
                return TRUE
            balloon_alert_to_viewers("plating...")
            if(!do_after(user, src, 2 SECONDS, DO_PUBLIC|DO_RESTRICT_CLICKING, TRUE))
                balloon_alert(user, "interrupted!")
                return TRUE
            if(!material.use(10))
                balloon_alert(user, "not enough!")
                return TRUE
            material_plate = material
            return TRUE
        else
            var/err_message = "BUG: plate attempted on a girder in an invalid state ([girder_state])!"
            to_chat(user, span_warning(err_message))
            stack_trace(err_message)
            return TRUE

/obj/structure/girder/crowbar_act(mob/living/user, obj/item/tool)
    if(!Adjacent(tool))
        return ..()
    switch(girder_state)
        if(GIRDER_NOTHING, GIRDER_STRUCTURAL)
            balloon_alert(user, "nothing to remove!")
            return TRUE
        if(GIRDER_PLATED)
            ASSERT(!isnull(material_plate))
            balloon_alert_to_viewers("removing plating...")
            if(!do_after(user, src, 2 SECONDS, DO_PUBLIC|DO_RESTRICT_CLICKING, TRUE))
                balloon_alert(user, "interrupted!")
                return TRUE
            material_plate = null
            return TRUE
        else
            var/err_message = "BUG: crowbar attempted on a girder in an invalid state ([girder_state])!"
            to_chat(user, span_warning(err_message))
            stack_trace(err_message)
            return TRUE

/obj/structure/girder/wrench_act(mob/user, obj/item/tool)
    if(!Adjacent(tool))
        return ..()
    switch(girder_state)
        if(GIRDER_PLATED)
            balloon_alert(user, "can't reach!")
            return TRUE
        if(GIRDER_STRUCTURAL, GIRDER_NOTHING)
            if(!istype(loc, /turf/open/floor))
                balloon_alert(user, "what floor?")
                return TRUE
            balloon_alert(user, "adjusting floor bolts!")
            if(!tool.use_tool(src, user, 2 SECONDS))
                return TRUE
            anchored = !anchored
            return TRUE
        else
            var/err_message = "BUG: wrench attempted on a girder in an invalid state ([girder_state])!"
            to_chat(user, span_warning(err_message))
            stack_trace(err_message)

/obj/structure/girder/welder_act(mob/living/user, obj/item/tool)
    if(!Adjacent(tool))
        return ..()
    switch(girder_state)
        if(GIRDER_STRUCTURAL)
            if(girder_shape != GIRDER_WALL_FULL)
                balloon_alert(user, "already sliced!")
                return TRUE
            balloon_alert(user, "slicing...")
            if(!tool.use_tool(src, user, 2 SECONDS))
                return TRUE
            new /obj/item/stack/sheet/iron(user.drop_location(), 5)
            return TRUE

/obj/structure/girder/screwdriver_act(mob/user, obj/item/tool)
    if(!Adjacent(tool))
        return ..()
    switch(girder_state)
        if(GIRDER_PLATED)
            return attempt_finish(user)
        if(GIRDER_STRUCTURAL, GIRDER_NOTHING)
            balloon_alert(user, "not ready!")
            return TRUE
        else
            var/err_message = "BUG: screwdriver attempted on a girder in an invalid state ([girder_state])!"
            to_chat(user, span_warning(err_message))
            stack_trace(err_message)
            return TRUE

/obj/structure/girder/attackby(obj/item/object, mob/user, params)
    if(!Adjacent(object))
        return ..()
    if(istype(object, /obj/item/stack/sheet))
        return attempt_plate(user, object)
    return ..()

/obj/structure/girder/attackby_secondary(obj/item/object, mob/user, params)
    if(!Adjacent(object))
        return ..()
    if(istype(object, /obj/item/stack/sheet))
        return attempt_reinforce(user, object)
    return ..()
