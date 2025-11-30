/turf/closed/constructed_wall/proc/get_connections()
	var/connections = alist()
	for(var/cardinal in GLOB.cardinals)
		var/turf/neighbor = get_step(src, cardinal)
		if(isnull(neighbor))
			connections[cardinal] = null
			continue
		if(allow_connection(neighbor))
			connections[cardinal] = neighbor
			continue
	var/list/valid_diags
	if(NORTH in connections)
		valid_diags |= NORTHEAST_JUNCTION|NORTHWEST_JUNCTION
	if(SOUTH in connections)
		valid_diags |= SOUTHEAST_JUNCTION|SOUTHWEST_JUNCTION
	if(EAST in connections)
		valid_diags |= NORTHEAST_JUNCTION|SOUTHEAST_JUNCTION
	if(WEST in connections)
		valid_diags |= NORTHWEST_JUNCTION|SOUTHWEST_JUNCTION
	for(var/diag in bitfield_to_list(valid_diags))
		var/turf/neighbor = get_step(src, reverse_ndir(diag))
		if(isnull(neighbor))
			connections[diag] = null
			continue
		if(allow_connection(neighbor))
			connections[diag] = neighbor
			continue
	return connections

/turf/closed/constructed_wall/proc/allow_connection(turf/connection)
	if(istype(connection, /turf/closed/constructed_wall))
		var/turf/closed/constructed_wall/wall = connection
		return wall.material_plating == material_plating
	var/obj/structure/window/window = locate() in connection
	return window?.anchored || FALSE

/turf/closed/constructed_wall/proc/update_connections(from_changeturf = FALSE)
	var/old_connections = wall_connections
	wall_connections = 0
	var/list/new_connections = from_changeturf ? list() : get_connections()
	for(var/ndir in new_connections)
		wall_connections |= ndir
	if(wall_connections == old_connections)
		return
	if(!from_changeturf)
		update_appearance(UPDATE_ICON_STATE)
	for(var/atom/neighbor as anything in new_connections)
		neighbor = new_connections[neighbor]
		if(istype(neighbor, /turf/closed/constructed_wall))
			var/turf/closed/constructed_wall/wall = neighbor
			wall.update_connections()
		else
			neighbor.update_appearance()
	for(var/old_ndir in (old_connections & ~wall_connections))
		var/ndir = reverse_ndir(old_ndir)
		var/turf/neighbor = get_step(src, ndir)
		if(istype(neighbor, /turf/closed/constructed_wall))
			var/turf/closed/constructed_wall/wall = neighbor
			wall.update_connections()
		else
			neighbor.update_appearance()
