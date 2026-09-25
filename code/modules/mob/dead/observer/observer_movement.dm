/mob/dead/observer/up()
	set name = "Move Upwards"
	set category = "IC"

	if(src.z >= length(SSmapping.z_list))
		src.z = 1
	else
		src.z += 1

	to_chat(src, span_notice("You move upwards."))

/mob/dead/observer/down()
	set name = "Move Down"
	set category = "IC"

	if(src.z <= 1)
		src.z = length(SSmapping.z_list)
	else
		src.z -= 1

	to_chat(src, span_notice("You move down."))
