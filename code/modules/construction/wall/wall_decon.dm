/turf/closed/constructed_wall/welder_act(mob/living/user, obj/item/tool)
	if(!Adjacent(tool))
		return ..()
	switch(deconstruction_stage)
		if(DECON_NONE)
			if(material_trim_high || material_trim_low)
				balloon_alert("remove the trim!")
				return TRUE
			balloon_alert_to_viewers("cutting frame...")
			if(!tool.use_tool(src, user, WALL_DECON_STEP_TIME, volume = 50))
				return TRUE
			deconstruction_stage = DECON_WALL_WEAKENED
			update_appearance(UPDATE_OVERLAYS)
			return TRUE
		if(DECON_WALL_WEAKENED)
			if(material_reinforcement && deconstruction_r_step == DECON_REINF_GRILLE_REMOVED)
				balloon_alert_to_viewers("removing bracing...")
				if(!tool.use_tool(src, user, WALL_DECON_STEP_REINF_TIME, volume = 50))
					return TRUE
				deconstruction_r_step = DECON_REINF_BRACING_REMOVED
				update_appearance(UPDATE_OVERLAYS)
				return TRUE
	return ..()

/turf/closed/constructed_wall/crowbar_act(mob/living/user, obj/item/tool)
	if(material_trim_high)
		balloon_alert_to_viewers("removing trim...")
		if(!tool.use_tool(src, user, WALL_DECON_STEP_TIME, volume = 50))
			return TRUE
		user.put_in_hands(new material_trim_high.sheet_type(drop_location(), 1))
		material_trim_high = null
		update_appearance(UPDATE_OVERLAYS)
		return TRUE
	if(material_trim_low)
		balloon_alert_to_viewers("removing trim...")
		if(!tool.use_tool(src, user, WALL_DECON_STEP_TIME, volume = 50))
			return TRUE
		user.put_in_hands(new material_trim_low.sheet_type(drop_location(), 1))
		material_trim_low = null
		update_appearance(UPDATE_OVERLAYS)
		return TRUE
	switch(deconstruction_stage)
		if(DECON_WALL_WEAKENED)
			// if we are reinforced, we need to remove the bulkhead first
			if(material_reinforcement && deconstruction_r_step != DECON_REINF_BOLTS_UNDONE)
				if(deconstruction_r_step == DECON_REINF_NONE)
					balloon_alert_to_viewers("removing bulkhead...")
					if(!tool.use_tool(src, user, WALL_DECON_STEP_REINF_TIME, volume = 50))
						return TRUE
					deconstruction_r_step = DECON_REINF_BULKHEAD_REMOVED
					update_appearance(UPDATE_OVERLAYS)
				return TRUE
			balloon_alert_to_viewers("removing plating...")
			if(!tool.use_tool(src, user, WALL_DECON_STEP_TIME, volume = 50))
				return TRUE
			deconstruct_to_girder()
			return TRUE
	return ..()

/turf/closed/constructed_wall/wrench_act(mob/living/user, obj/item/tool)
	if(!Adjacent(tool))
		return ..()
	if(deconstruction_r_step != DECON_REINF_BRACING_REMOVED)
		return ..()
	balloon_alert_to_viewers("undoing bolts...")
	if(!tool.use_tool(src, user, WALL_DECON_STEP_REINF_TIME, volume = 50))
		return TRUE
	deconstruction_r_step = DECON_REINF_BOLTS_UNDONE
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/turf/closed/constructed_wall/wirecutter_act(mob/living/user, obj/item/tool)
	if(!Adjacent(tool))
		return ..()
	switch(deconstruction_stage)
		if(DECON_WALL_WEAKENED)
			if(material_reinforcement && deconstruction_r_step == DECON_REINF_BULKHEAD_REMOVED)
				balloon_alert_to_viewers("removing grille...")
				if(!tool.use_tool(src, user, WALL_DECON_STEP_REINF_TIME, volume = 50, extra_checks = CALLBACK(src, PROC_REF(check_shock), user)))
					return TRUE
				deconstruction_r_step = DECON_REINF_GRILLE_REMOVED
				update_appearance(UPDATE_OVERLAYS)
				return TRUE
	return ..()

/turf/closed/constructed_wall/proc/deconstruct_to_girder()
	var/obj/structure/girder/girder = new(src)
	girder.material_plating = material_plating
	girder.material_reinforce = material_reinforcement
	if(material_reinforcement)
		girder.reinforcement_secure = TRUE
	girder.anchored = TRUE
	girder.density = TRUE
	girder.start_smoothing()
	ScrapeAway()

/turf/closed/constructed_wall/proc/check_shock(mob/living/user)
	var/obj/structure/cable/cable = locate() in src
	if(isnull(cable))
		return TRUE
	return !cable.shock(user, 75)
