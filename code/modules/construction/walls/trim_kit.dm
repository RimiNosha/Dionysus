
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
